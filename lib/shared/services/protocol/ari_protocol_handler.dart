import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ari_plugin/ari_plugin.dart';
import 'package:aristock/components/analysis/models/stock_analysis_model.dart';
import 'package:aristock/components/analysis/models/investment_issue_model.dart';
import 'package:aristock/components/analysis/providers/analysis_provider.dart';
import 'package:aristock/components/account/providers/account_provider.dart';
import 'package:aristock/components/watchlist/providers/watchlist_provider.dart';
import 'package:aristock/components/strategy/models/trading_strategy_model.dart';
import 'package:aristock/components/strategy/providers/trading_strategy_provider.dart';
import 'package:aristock/components/trading/models/trading_record_model.dart';
import 'package:aristock/components/trading/providers/trading_record_provider.dart';

import 'package:aristock/shared/repository/kiwoom/market_data_repository.dart';
import 'package:aristock/shared/models/market/market_timeframe.dart';
import 'package:aristock/shared/services/tools/technical_tools.dart';
import 'package:aristock/shared/services/log_provider.dart';
import 'package:aristock/components/watchlist/models/watchlist_model.dart';
import 'package:aristock/components/chat/chat_provider.dart';

/// AriFramework 표준을 준수하는 종목분석 프로토콜 핸들러입니다.
/// ARI 플랫폼과 통신하는 표준 프로토콜 핸들러입니다.
/// AI 에이전트의 명령을 수신하여 앱의 기능을 실행하고 상태를 반환합니다.
class ARIProtocolHandler {
  final AnalysisProvider analysisProvider;
  final AccountProvider accountProvider;
  final WatchlistProvider watchlistProvider;
  final TradingStrategyProvider tradingStrategyProvider;
  final TradingRecordProvider tradingRecordProvider;
  final ChatProvider chatProvider;
  final KiwoomMarketDataRepository marketDataService;
  final TechnicalTools technicalTools;
  final bool isHeadless;

  ARIProtocolHandler._({
    required this.analysisProvider,
    required this.accountProvider,
    required this.watchlistProvider,
    required this.tradingStrategyProvider,
    required this.tradingRecordProvider,
    required this.chatProvider,
    required this.marketDataService,
    required this.isHeadless,
  }) : technicalTools = TechnicalTools(marketDataService);

  factory ARIProtocolHandler.create({
    required AnalysisProvider analysisProvider,
    required AccountProvider accountProvider,
    required WatchlistProvider watchlistProvider,
    required TradingStrategyProvider tradingStrategyProvider,
    required TradingRecordProvider tradingRecordProvider,
    required ChatProvider chatProvider,
    required KiwoomMarketDataRepository marketDataService,
    required bool isHeadless,
  }) {
    return ARIProtocolHandler._(
      analysisProvider: analysisProvider,
      accountProvider: accountProvider,
      watchlistProvider: watchlistProvider,
      tradingStrategyProvider: tradingStrategyProvider,
      tradingRecordProvider: tradingRecordProvider,
      chatProvider: chatProvider,
      marketDataService: marketDataService,
      isHeadless: isHeadless,
    );
  }

  late final AppProtocolHandler _protocolHandler;

  /// 프로토콜 엔진을 시작합니다.
  void start() {
    debugPrint('ARIProtocolHandler: Starting protocol engine...');

    _protocolHandler = AppProtocolHandler(
      appId: 'aristock',
      onCommand: _handleEvent,
      onGetState: _getState,
    );

    _protocolHandler.start();
  }

  /// 프로토콜 엔진을 중지합니다.
  void stop() {
    _protocolHandler.stop();
  }

  /// 에이전트에게 제공할 앱의 현재 요약 상태를 반환합니다.
  Map<String, dynamic> _getState() {
    final bool useApi = accountProvider.hasApiKeys;
    return {
      'isApiConnected': useApi,
      'totalAssets': accountProvider.totalAssets,
      'stockCount': accountProvider.kiwoomStocks.length,
      'selectedAccountNo': accountProvider.selectedAccountNo,
    };
  }

  /// 모든 수신 이벤트를 분기 처리하고 에러 시 로깅을 수행하는 중앙 집선 장치입니다.
  Future<Map<String, dynamic>> _handleEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    LogProvider.debug('ARI_EVENT', 'Handling event: $event');

    try {
      // 1. 투자 분석 관련 (Issue Trace)
      if (event.contains('ANALYSIS')) {
        return await _handleAnalysisEvent(event, data);
      }

      // 2. 계좌 및 자산 관련
      if (event.startsWith('GET_ACCOUNT')) {
        return await _handleAccountEvent(event, data);
      }

      // 3. 관심 종목 및 탐색 관련
      if (event == 'GET_WATCHLIST') {
        return await _handleWatchlistEvent(event, data);
      }

      // 4. 시장 데이터 및 기술 지표 관련
      if (event == 'GET_MARKET_DATA' || event == 'CALCULATE_INDICATOR') {
        return await _handleMarketEvent(event, data);
      }

      // 5. 매매전략 관련
      if (event == 'SET_STRATEGY' || event == 'GET_STRATEGY') {
        return await _handleStrategyEvent(event, data);
      }

      // 6. 실거래 주문 및 매매기록 관련
      if (event == 'BUY_STOCK' || event == 'SELL_STOCK' || event == 'ADD_TRADING_RECORD') {
        return await _handleTradingEvent(event, data);
      }

      // 7. 시스템 상태 관련
      if (event == 'GET_APP_STATUS') {
        return {
          'status': 'success',
          'data': {
            'isHeadless': isHeadless,
            'appId': 'aristock',
            'version': '1.0.4',
          },
        };
      }

      return {'status': 'error', 'message': 'Unknown event [$event]'};
    } catch (e, stack) {
      LogProvider.error('ARI_EVENT', 'Error handling event $event: $e');
      return {
        'status': 'error',
        'message': e.toString(),
        'stack': stack.toString(),
      };
    }
  }

  // --------------------------------------------------------------------------
  // 세부 이벤트 핸들러 (분할 관리)
  // --------------------------------------------------------------------------

  /// [Issue Trace] 투자 분석, 가설 저장 및 이슈 업데이트를 처리합니다.
  Future<Map<String, dynamic>> _handleAnalysisEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    final symbol = data['symbol'] as String?;
    if (symbol == null)
      throw Exception('Symbol is required for analysis events');

    // 1. 이름이 없는 경우 로컬 데이터베이스나 서버 API에서 조회 시도
    String name = _resolveStockName(symbol, data['name'] as String?);
    if (name == symbol) {
      // 로컬에 이름 정보가 없는 경우 서버에 실시간 조회를 요청합니다.
      name = await marketDataService.getStockName(symbol);
    }

    switch (event) {
      // 종목 분석 정보 저장 및 종목 선택
      case 'SET_ANALYSIS':
        final analysis = StockAnalysis.fromMap({
          ...data,
          'symbol': symbol,
          'stockName': name,
          'date': DateTime.now().toString().split(' ')[0],
        });

        // 1. 분석 내역 저장/병합
        await analysisProvider.addAnalysisLog(analysis);

        // 2. 종목 리스트(Watchlist)에 자동 추가
        await watchlistProvider.addStock(symbol, name);

        // 3. 해당 종목으로 UI 활성화 (선택 상태 변경)
        watchlistProvider.selectStock(symbol);
        analysisProvider.selectStock(symbol);

        LogProvider.info(
          'ANALYSIS',
          'Analysis SET and selected: $symbol ($name)',
        );
        return {'status': 'success'};

      // 분석 정보 조회
      case 'GET_ANALYSIS':
        final analysis = analysisProvider.getAnalysisForSymbol(symbol);
        if (analysis == null) return {'status': 'success', 'data': null};

        final type = data['type'] as String? ?? 'full';
        if (type == 'recent') {
          return {
            'status': 'success',
            'data': {
              'symbol': analysis.symbol,
              'date': analysis.date,
              'summary': analysis.summary,
              'shortTermScore': analysis.shortTermScore,
              'content': analysis.content,
            },
          };
        }
        return {'status': 'success', 'data': analysis.toMap()};

      // 모든 이슈 목록 조회 (필터링 추가)
      case 'GET_ANALYSIS_ISSUES':
        final includeResolved = data['includeResolved'] as bool? ?? false;
        final analysis = analysisProvider.getAnalysisForSymbol(symbol);

        var issues = analysis?.issues?.toList() ?? [];
        if (!includeResolved) {
          // 종료되거나 해결된 이슈 제외
          issues = issues
              .where(
                (i) =>
                    i.status != 'resolved' &&
                    i.status != 'closed' &&
                    i.endDate == null,
              )
              .toList();
        }

        return {
          'status': 'success',
          'data': issues.map((e) => e.toMap()).toList(),
        };

      // 신규 이슈 추가
      case 'ADD_ANALYSIS_ISSUE':
        final title = data['title'] as String;
        final isPositive = data['isPositive'] as bool? ?? true;
        final impact = data['impact'] as int? ?? 3;
        final status = data['status'] as String? ?? 'active';
        final historyData = data['history'] as Map<String, dynamic>?;

        IssueHistory? initialHistory;
        if (historyData != null) {
          initialHistory = IssueHistory.fromMap(
            Map<String, dynamic>.from(historyData),
          );
        }

        final newIssue = InvestmentIssue(
          id: '',
          title: title,
          isPositive: isPositive,
          impact: impact,
          status: status,
          startDate: DateTime.now().toString().split(' ')[0],
          history: initialHistory != null ? [initialHistory] : null,
        );

        final virtualAnalysis = StockAnalysis(
          symbol: symbol,
          stockName: name,
          issues: [newIssue],
          date: DateTime.now().toString().split(' ')[0],
          content: '',
        );

        await analysisProvider.addAnalysisLog(virtualAnalysis);
        LogProvider.info('ANALYSIS', 'New issue ADDED to $symbol: $title');
        return {'status': 'success'};

      // 이슈 제거
      case 'REMOVE_ANALYSIS_ISSUE':
        final issueTitle = data['issueTitle'] as String;
        await analysisProvider.deleteIssueByTitle(symbol, issueTitle);
        LogProvider.info('ANALYSIS', 'Issue REMOVED from $symbol: $issueTitle');
        return {'status': 'success'};

      // 이슈 업데이트 (상태, 점수, 히스토리 포함)
      case 'UPDATE_ANALYSIS_ISSUE':
        final issueTitle = data['issueTitle'] as String;
        final status = data['status'] as String?;
        final impact = data['impact'] as int?;
        final isPositive = data['isPositive'] as bool?;
        final historyData = data['history'] as Map<String, dynamic>?;

        IssueHistory? history;
        if (historyData != null) {
          history = IssueHistory.fromMap(
            Map<String, dynamic>.from(historyData),
          );
        }

        // impact 업데이트를 위해 StockAnalysis 병합 방식을 사용하거나 addIssueHistory 사용
        if (impact != null) {
          final updatedIssue = InvestmentIssue(
            id: '',
            title: issueTitle,
            isPositive: isPositive ?? true, // 기본값 부여 또는 기존값 유지가 필요할 수 있음
            impact: impact,
            status: status ?? 'active',
            startDate: DateTime.now().toString().split(' ')[0],
            history: history != null ? [history] : null,
          );
          await analysisProvider.addAnalysisLog(
            StockAnalysis(
              symbol: symbol,
              stockName: name,
              issues: [updatedIssue],
              date: DateTime.now().toString().split(' ')[0],
              content: '',
            ),
          );
        } else {
          await analysisProvider.addIssueHistory(
            symbol,
            issueTitle,
            history,
            newStatus: status,
            stockName: name,
          );
        }

        LogProvider.info('ANALYSIS', 'Issue UPDATED for $symbol: $issueTitle');
        return {'status': 'success'};

      default:
        throw Exception('Unsupported analysis event: $event');
    }
  }

  /// [Account] 계좌 자산, 보유 종목 및 수익률 정보를 처리합니다.
  Future<Map<String, dynamic>> _handleAccountEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    switch (event) {
      case 'GET_ACCOUNT_INFO':
        return {
          'status': 'success',
          'data': {
            'holdings': accountProvider.kiwoomStocks
                .map((e) => e.toMap())
                .toList(),
            'summary': {
              'totalAssets': accountProvider.totalAssets,
              'totalInvestment': accountProvider.totalInvestment,
              'totalProfitLoss': accountProvider.totalProfitLoss,
              'totalProfitRate': accountProvider.totalProfitRate,
              'deposit': accountProvider.deposit,
              'selectedAccountNo': accountProvider.selectedAccountNo,
              'isRealAccount': accountProvider.hasApiKeys,
            },
          },
        };
      default:
        throw Exception('Unsupported account event: $event');
    }
  }

  /// [Watchlist] 관심 종목 리스트 조회를 처리합니다.
  Future<Map<String, dynamic>> _handleWatchlistEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    switch (event) {
      // 전체 관심 종목 리스트 반환
      case 'GET_WATCHLIST':
        return {
          'status': 'success',
          'data': {
            'items': watchlistProvider.items.map((e) => e.toMap()).toList(),
          },
        };

      default:
        throw Exception('Unsupported watchlist event: $event');
    }
  }

  /// [Market] 시장 데이터 조회 및 기술적 지표 계산을 처리합니다.
  Future<Map<String, dynamic>> _handleMarketEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    final symbol = data['symbol'] as String;
    final timeframeStr = data['timeframe'] as String? ?? 'day';
    final limit = data['limit'] as int? ?? 120;

    // 프로토콜 문자열 값을 MarketTimeframe enum으로 변환
    final timeframe = MarketTimeframe.values.firstWhere(
      (t) => t.protocolValue == timeframeStr,
      orElse: () => MarketTimeframe.day,
    );

    switch (event) {
      // 차트 데이터(캔들/틱) 조회
      case 'GET_MARKET_DATA':
        final marketData = await marketDataService.fetchMarketData(
          symbol: symbol,
          timeframe: timeframe,
          limit: limit,
        );
        return {'status': 'success', 'data': marketData};

      // RSI, MACD 등 기술적 지표 계산
      case 'CALCULATE_INDICATOR':
        final indicatorType = data['type'] as String;
        final indicatorParams = Map<String, dynamic>.from(
          data['params'] as Map? ?? {},
        );

        final result = await technicalTools.analyzeStockIndicator(
          symbol: symbol,
          timeframe: timeframe,
          limit: limit,
          indicatorType: indicatorType,
          params: indicatorParams,
        );
        return {'status': 'success', 'data': result};

      default:
        throw Exception('Unsupported market event: $event');
    }
  }

  /// [Strategy] 매매전략 저장 및 조회를 처리합니다.
  Future<Map<String, dynamic>> _handleStrategyEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    final symbol = data['symbol'] as String?;
    if (symbol == null) throw Exception('Symbol is required for strategy events');

    switch (event) {
      case 'SET_STRATEGY':
        final strategy = TradingStrategy.fromMap(data);
        await tradingStrategyProvider.saveStrategy(strategy);
        LogProvider.info('STRATEGY', 'Strategy SET (structured) for ${strategy.symbol}');
        return {'status': 'success'};

      case 'GET_STRATEGY':
        final strategy = tradingStrategyProvider.getStrategyForSymbol(symbol);
        return {'status': 'success', 'data': strategy?.toMap()};

      default:
        throw Exception('Unsupported strategy event: $event');
    }
  }

  /// [Trading] 실제 매수/매도 주문을 실행합니다.
  Future<Map<String, dynamic>> _handleTradingEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    final symbol = data['symbol'] as String?;
    final qty = data['quantity']?.toString() ?? '1';
    final price = data['price']?.toString() ?? '';

    if (symbol == null) throw Exception('Symbol is required for trading');
    if (!accountProvider.hasApiKeys) throw Exception('API 연동이 필요합니다.');

    switch (event) {
      case 'BUY_STOCK':
        LogProvider.info('TRADING', 'Executing BUY for $symbol: $qty shares at $price');
        final response = await accountProvider.tradingService.buyStock(
          stockCode: symbol,
          quantity: qty,
          price: price,
        );
        return {'status': response.isSuccess ? 'success' : 'error', 'data': response.body};

      case 'SELL_STOCK':
        LogProvider.info('TRADING', 'Executing SELL for $symbol: $qty shares at $price');
        final response = await accountProvider.tradingService.sellStock(
          stockCode: symbol,
          quantity: qty,
          price: price,
        );
        return {'status': response.isSuccess ? 'success' : 'error', 'data': response.body};

      case 'ADD_TRADING_RECORD':
        final record = TradingRecord.fromMap(data);
        await tradingRecordProvider.init(); // 보장용
        await tradingRecordProvider.addRecord(record);
        LogProvider.info('TRADING', 'Trade record ADDED for ${record.symbol}: ${record.side} at ${record.price}');
        return {'status': 'success'};

      default:
        throw Exception('Unsupported trading event: $event');
    }
  }

  /// 종목코드(Symbol)만 있을 때 앱 내 데이터로부터 종목명을 유추합니다.
  /// 관심종목 -> 보유종목 순으로 검색하며 없을 시 코드를 그대로 반환합니다.
  String _resolveStockName(String symbol, String? providedName) {
    if (providedName != null && providedName.isNotEmpty) return providedName;

    // 1. 관심종목에서 찾기
    final watchlistStock = watchlistProvider.items.firstWhere(
      (e) => e.symbol == symbol,
      orElse: () => WatchlistStock(symbol: symbol, name: ''),
    );
    if (watchlistStock.name.isNotEmpty) return watchlistStock.name;

    // 2. 보유종목에서 찾기
    for (final stock in accountProvider.kiwoomStocks) {
      if (stock.symbol == symbol) return stock.name;
    }

    return symbol;
  }
}
