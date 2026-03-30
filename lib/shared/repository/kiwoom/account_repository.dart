import 'package:aristock/shared/infra/kiwoom_api_client.dart';

/// 계좌/잔고 관련 조회 전용 서비스
class KiwoomAccountRepository {
  static const String trAccountList = 'ka00001';
  static const String trEvaluationStatus = 'kt00004';
  static const String trDepositDetails = 'kt00001';
  static const String trBalanceDetails = 'kt00018';

  final KiwoomApiClient _client;

  KiwoomAccountRepository(this._client);

  Future<KiwoomResponse> getAccounts() {
    return _client.callApi(endpoint: '/api/dostk/acnt', apiId: trAccountList);
  }

  Future<KiwoomResponse> getAccountEvaluation({required String accountNo}) {
    return _client.callApi(
      endpoint: '/api/dostk/acnt',
      apiId: trEvaluationStatus,
      params: {
        'accNo': accountNo,
        'itg_accNo': accountNo,
        'pw': '',
        'qry_tp': KiwoomApiClient.queryTypeDetail,
        'dmst_stex_tp': KiwoomApiClient.exchangeKrx,
        'f_id': '',
      },
    );
  }

  Future<KiwoomResponse> getDepositDetails({required String accountNo}) {
    return _client.callApi(
      endpoint: '/api/dostk/acnt',
      apiId: trDepositDetails,
      params: {
        'accNo': accountNo,
        'itg_accNo': accountNo,
        'pw': '',
        'qry_tp': KiwoomApiClient.queryTypeDetail,
        'dmst_stex_tp': KiwoomApiClient.exchangeKrx,
      },
    );
  }

  Future<KiwoomResponse> getAccountBalance({required String accountNo}) {
    return _client.callApi(
      endpoint: '/api/dostk/acnt',
      apiId: trBalanceDetails,
      params: {
        'accNo': accountNo,
        'itg_accNo': accountNo,
        'pw': '',
        'idx': '',
        'stk_itg_tp': '1',
        'dmst_stex_tp': KiwoomApiClient.exchangeKrx,
        'qry_tp': KiwoomApiClient.queryTypeDetail,
      },
    );
  }
}
