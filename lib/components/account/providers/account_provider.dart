import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:aristock/shared/models/kiwoom/credentials_model.dart';
import 'package:aristock/shared/models/stock/stock.dart';
import 'package:aristock/shared/infra/kiwoom_api_client.dart';
import 'package:aristock/shared/repository/kiwoom/account_repository.dart';
import 'package:aristock/shared/repository/kiwoom/market_repository.dart';
import 'package:aristock/shared/repository/kiwoom/trading_repository.dart';

/// 계좌 및 포트폴리오 데이터를 관리하는 Provider입니다.
class AccountProvider with ChangeNotifier {
  final KiwoomApiClient apiClient;
  final KiwoomAccountRepository accountService;
  final KiwoomMarketRepository marketService;
  final KiwoomTradingRepository tradingService;

  AccountProvider({
    required this.apiClient,
    required this.accountService,
    required this.marketService,
    required this.tradingService,
  });

  bool _isLoading = false;
  KiwoomCredentials? _credentials;
  List<Map<String, dynamic>> _accounts = [];
  String? _selectedAccountNo;
  String? _lastError;
  bool _isRefreshing = false;

  // 파싱된 자산 데이터
  double _totalAssets = 0;
  double _totalInvestment = 0;
  double _totalProfitLoss = 0;
  double _totalProfitRate = 0;
  double _deposit = 0;
  List<Stock> _kiwoomStocks = [];

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  KiwoomCredentials? get credentials => _credentials;
  List<Map<String, dynamic>> get accounts => _accounts;
  String? get selectedAccountNo => _selectedAccountNo;
  String? get lastError => _lastError;

  double get totalAssets => _totalAssets;
  double get totalInvestment => _totalInvestment;
  double get totalProfitLoss => _totalProfitLoss;
  double get totalProfitRate => _totalProfitRate;
  double get deposit => _deposit;
  List<Stock> get kiwoomStocks => _kiwoomStocks;

  /// API 키가 설정되어 있는지 여부
  bool get hasApiKeys => _credentials != null;

  /// 유효한 토큰이 있는지 여부
  bool get hasValidToken => _credentials?.hasValidToken ?? false;

  Future<void> init() async {
    debugPrint('AccountProvider: Initializing...');
    _isLoading = true;
    notifyListeners();

    _credentials = await KiwoomCredentials.load();

    if (_credentials != null) {
      apiClient.setCredentials(_credentials!);
      if (_credentials!.hasValidToken) {
        manualFetchAccounts();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 계좌 선택 업데이트
  void selectAccount(String accountNo) {
    if (_selectedAccountNo == accountNo) return;
    _selectedAccountNo = accountNo;
    manualFetchAccounts();
  }

  /// 계좌 정보 및 상세 자산 조회
  Future<void> manualFetchAccounts() async {
    if (_credentials == null) return;

    _isRefreshing = true;
    _lastError = null;
    notifyListeners();

    try {
      // 1. 토큰 보장
      final tokenOk = await apiClient.ensureToken(_credentials!);
      if (!tokenOk) {
        _lastError = '토큰 갱신 실패';
        debugPrint('Kiwoom Error: Token refresh failed.');
        _isRefreshing = false;
        notifyListeners();
        return;
      }

      // 2. 계좌 목록 로드 (선택된 계좌가 없을 경우만)
      if (_selectedAccountNo == null) {
        final accountResponse = await accountService.getAccounts();
        if (accountResponse.isSuccess) {
          final body = accountResponse.body;
          debugPrint('Kiwoom Account List Response: $body');

          if (body['acnt_list'] != null &&
              (body['acnt_list'] as List).isNotEmpty) {
            final list = body['acnt_list'] as List;
            _accounts = list.map((e) {
              if (e is String) {
                return {'accNo': e, 'accNm': '주계좌'};
              } else if (e is Map) {
                return Map<String, dynamic>.from(e);
              }
              return {'accNo': e.toString(), 'accNm': '주계좌'};
            }).toList();
            _selectedAccountNo = _accounts[0]['accNo'];
          } else if (body['acctNo'] != null) {
            _accounts = [
              {
                'accNo': body['acctNo'].toString(),
                'accNm': body['acctNm'] ?? '주계좌',
              },
            ];
            _selectedAccountNo = body['acctNo'].toString();
          } else if (body['accNo'] != null) {
            _accounts = [
              {
                'accNo': body['accNo'].toString(),
                'accNm': body['accNm'] ?? '주계좌',
              },
            ];
            _selectedAccountNo = body['accNo'].toString();
          }

          if (_selectedAccountNo == null) {
            _lastError = '연동된 계좌를 찾을 수 없습니다.';
            debugPrint(
              'Kiwoom Error: No selected account no found in body: $body',
            );
          }
        } else {
          _lastError =
              '계좌 목록 조회 실패: ${accountResponse.body['message'] ?? accountResponse.statusCode}';
          debugPrint(
            'Kiwoom API Error [getAccounts]: Status ${accountResponse.statusCode}, Body: ${accountResponse.body}',
          );
        }
      }

      // 3. 상세 자산 및 잔고 조회
      if (_selectedAccountNo != null) {
        await _fetchAccountDetails(_selectedAccountNo!);
      }
    } catch (e, stack) {
      _lastError = '조회 중 오류 발생: $e';
      debugPrint('Kiwoom Unexpected Error: $e');
      debugPrint(stack.toString());
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// 특정 계좌의 상세 데이터 가져오기 (내부 메서드)
  Future<void> _fetchAccountDetails(String accountNo) async {
    // 1. 계좌 평가 현황 (kt00004)
    final evaluationResponse = await accountService.getAccountEvaluation(
      accountNo: accountNo,
    );
    debugPrint('Kiwoom API Log [kt00004]: ${evaluationResponse.body}');

    // 2. 예수금 상세 현황 (kt00001)
    final depositResponse = await accountService.getDepositDetails(
      accountNo: accountNo,
    );
    debugPrint('Kiwoom API Log [kt00001]: ${depositResponse.body}');

    if (evaluationResponse.isSuccess) {
      final evalBody = evaluationResponse.body;
      final depBody = depositResponse.isSuccess ? depositResponse.body : {};

      // 금액 데이터 파싱
      // 금액 데이터 파싱 (다양한 필드 시도)
      _totalAssets = _parseDouble(
        evalBody['aset_evlt_amt'] ??
            evalBody['tot_evlt_amt'] ??
            evalBody['asset_ev_amt'] ??
            '0',
      );
      _totalInvestment = _parseDouble(
        evalBody['tot_pur_amt'] ??
            evalBody['pchs_amt_tot'] ??
            evalBody['pur_amt'] ??
            '0',
      );

      // 예수금 데이터 파싱 (최대한 다양한 필드 시도)
      final List<String> depositKeys = [
        'fc_stk_krw_repl_set_amt', // 외화주식원화대용설정금액 (실제 로그에서 확인된 필드)
        'd2_pres_cash', // kt00001 (D+2)
        'dnca_tot_amt', // kt00001, kt00004
        'd2_entra', // kt00001, kt00004 (D+2)
        'pres_cash_amt', // kt00004 (현금)
        'd2_evl_evlt_amt', // kt00004
        'd1_pres_cash', // kt00001
        'elwdpst_evlta', // kt00001
        'psbl_dpst_amt', // 인출가능금액
      ];

      double foundDeposit = 0;

      // 1. kt00001 데이터에서 확인
      for (final key in depositKeys) {
        if (depBody[key] != null) {
          final val = _parseDouble(depBody[key]);
          if (val != 0) {
            foundDeposit = val;
            debugPrint('Found Deposit in kt00001 [$key]: $val');
            break;
          }
        }
      }

      // 2. kt00001에서 못찾으면 kt00004에서 확인
      if (foundDeposit == 0) {
        for (final key in depositKeys) {
          if (evalBody[key] != null) {
            final val = _parseDouble(evalBody[key]);
            if (val != 0) {
              foundDeposit = val;
              debugPrint('Found Deposit in kt00004 [$key]: $val');
              break;
            }
          }
        }
      }

      // 3. 마지막 수단: 총자산 - 종목평가금액 (Fallback)
      if (foundDeposit == 0) {
        double stockEvalAmt = _parseDouble(evalBody['tot_est_amt']);
        foundDeposit = _totalAssets - stockEvalAmt;
        if (foundDeposit != 0) {
          debugPrint(
            'Using calculated Deposit (Total - Stocks): $foundDeposit',
          );
        }
      }

      _deposit = foundDeposit;
      debugPrint('Final Parsed Deposit: $_deposit');

      // 수익률 계산 (API 값이 0일 경우 직접 산출)
      double apiProfitRate = _parseDouble(evalBody['pft_rt']) != 0
          ? _parseDouble(evalBody['pft_rt'])
          : _parseDouble(evalBody['evlt_pft_rt']) != 0
          ? _parseDouble(evalBody['evlt_pft_rt'])
          : _parseDouble(evalBody['lspft_rt']);

      if (apiProfitRate == 0 && _totalInvestment > 0) {
        _totalProfitRate =
            ((_totalAssets - _totalInvestment) / _totalInvestment) * 100;
      } else {
        _totalProfitRate = apiProfitRate;
      }

      _totalProfitLoss = _totalAssets - _totalInvestment;

      // 종목 리스트 파싱
      if (evalBody['stk_acnt_evlt_prst'] != null) {
        final stockList = evalBody['stk_acnt_evlt_prst'] as List;
        _kiwoomStocks = stockList.map((s) {
          final map = Map<String, dynamic>.from(s);
          final rawCode = map['stk_cd']?.toString() ?? '';
          final cleanCode = rawCode.startsWith('A')
              ? rawCode.substring(1)
              : rawCode;

          return Stock(
            id: cleanCode,
            symbol: cleanCode,
            name: map['stk_nm'] ?? '알 수 없음',
            quantity: _parseDouble(map['rmnd_qty']),
            purchasePrice: _parseDouble(map['avg_prc']),
            currentPrice: _parseDouble(map['cur_prc']),
          );
        }).toList();
      }
    } else {
      _lastError = evaluationResponse.body['message']?.toString() ?? '상세 조회 실패';
      debugPrint(
        'Kiwoom API Error [_fetchAccountDetails]: Status ${evaluationResponse.statusCode}, Body: ${evaluationResponse.body}',
      );
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    // 콤마 제거 및 앞자리 0 제거
    String valStr = value
        .toString()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'^0+'), '');
    if (valStr.isEmpty) {
      // "0"이나 "000" 같은 경우 처리
      if (value.toString().contains('0')) return 0;
      return 0;
    }
    return double.tryParse(valStr) ?? 0;
  }

  /// 계좌 연동 시나리오
  Future<String?> connectAndFetchAccounts(
    String appKey,
    String appSecret, {
    bool isMock = false,
  }) async {
    _lastError = null;
    final creds = KiwoomCredentials(
      appKey: appKey,
      appSecret: appSecret,
      isMock: isMock,
    );
    apiClient.setCredentials(creds);

    try {
      final tokenResponse = await apiClient.issueToken(creds);
      if (!tokenResponse.isSuccess) {
        _lastError = tokenResponse.body['message']?.toString() ?? '토큰 발급 실패';
        notifyListeners();
        return _lastError;
      }

      await KiwoomCredentials.save(creds);
      _credentials = creds;
      _selectedAccountNo = null; // 계좌 연동 시 초기화
      await manualFetchAccounts();

      notifyListeners();
      return _lastError;
    } catch (e) {
      return '연동 오류: $e';
    }
  }

  Future<void> clearApiKeys() async {
    await KiwoomCredentials.clear();
    apiClient.clearToken();
    _credentials = null;
    _accounts = [];
    _selectedAccountNo = null;
    _totalAssets = 0;
    _totalInvestment = 0;
    _totalProfitLoss = 0;
    _totalProfitRate = 0;
    _kiwoomStocks = [];
    notifyListeners();
  }
}
