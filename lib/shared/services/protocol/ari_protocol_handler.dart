import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ari_plugin/ari_plugin.dart';
import 'package:aristock/components/analysis/models/analysis_model.dart';
import 'package:aristock/components/analysis/providers/analysis_provider.dart';
import 'package:aristock/components/account/providers/account_provider.dart';
import 'package:aristock/components/watchlist/providers/watchlist_provider.dart';
import 'package:aristock/components/portfolio/providers/portfolio_provider.dart';
import 'package:aristock/components/portfolio/models/stock.dart';
import 'package:aristock/components/account/services/kiwoom_market_data_service.dart';
import 'package:aristock/shared/models/market/market_timeframe.dart';
import 'package:aristock/shared/services/log_provider.dart';

/// AriFramework 표준을 준수하는 종목분석 프로토콜 핸들러입니다.
class ARIProtocolHandler {
  final PortfolioProvider portfolioProvider;
  final AnalysisProvider analysisProvider;
  final AccountProvider accountProvider;
  final WatchlistProvider watchlistProvider;
  final KiwoomMarketDataService marketDataService;

  ARIProtocolHandler._({
    required this.portfolioProvider,
    required this.analysisProvider,
    required this.accountProvider,
    required this.watchlistProvider,
    required this.marketDataService,
  });

  factory ARIProtocolHandler.create({
    required PortfolioProvider portfolioProvider,
    required AnalysisProvider analysisProvider,
    required AccountProvider accountProvider,
    required WatchlistProvider watchlistProvider,
    required KiwoomMarketDataService marketDataService,
  }) {
    return ARIProtocolHandler._(
      portfolioProvider: portfolioProvider,
      analysisProvider: analysisProvider,
      accountProvider: accountProvider,
      watchlistProvider: watchlistProvider,
      marketDataService: marketDataService,
    );
  }

  late final AppProtocolHandler _protocolHandler;

  void start() {
    debugPrint('ARIProtocolHandler: Starting protocol engine...');
    
    _protocolHandler = AppProtocolHandler(
      appId: 'aristock',
      onCommand: (command, params) => _handleEvent(command, params),
      onGetState: () => {
        'isApiConnected': true,
        'totalAssets': portfolioProvider.totalAssets,
        'stockCount': portfolioProvider.stocks.length,
      },
      onGetCommands: () => {
        'SAVE_ANALYSIS': 'Living Timeline 기록 및 병합',
        'UPDATE_ISSUE': '특정 이슈의 히스토리/상태 업데이트',
        'GET_ACCOUNT_INFO': '자산 및 포트폴리오 통합 조회',
        'GET_MARKET_DATA': '실시간/차트 데이터 추출',
      },
    );

    _protocolHandler.start();

    // 초기 연결 시 프로토콜 요약 보고 (에이전트 인지용)
    WsManager.connectionStream.listen((isConnected) {
      if (isConnected) {
        LogProvider.info('ARI_PROTOCOL', 'WebSocket Connected. Syncing usage...');
        _syncUsage();
      }
    });
  }

  void stop() {
    _protocolHandler.stop();
  }

  void _syncUsage() {
    // 표준 /APP.REPORT를 사용하여 에이전트에게 기능을 브리핑합니다.
    WsManager.sendAsync('/APP.REPORT', {
      'appId': 'aristock',
      'type': 'info',
      'message': 'ARIStock Investment Suite v2.1 준비됨. [SAVE_ANALYSIS], [GET_ACCOUNT_INFO] 등의 명령이 가능합니다.',
    });
  }

  Future<Map<String, dynamic>> _handleEvent(String event, Map<String, dynamic> data) async {
    LogProvider.debug('ARI_EVENT', 'Handling event: $event');
    switch (event) {
      // --- 투자 이슈 및 타임라인 분석 ---
      case 'SAVE_ANALYSIS':
        final log = AnalysisLog.fromMap(Map<String, dynamic>.from(data));
        await analysisProvider.addAnalysisLog(log);
        LogProvider.info('ANALYSIS', 'Living Timeline updated: ${log.symbol}');
        return {'status': 'success'};

      case 'UPDATE_ISSUE':
        // (이하 로직 동일하게 유지)
        final symbol = data['symbol'] as String;
        final issueTitle = data['issueTitle'] as String;
        final status = data['status'] as String?;
        final historyData = data['history'] as Map<String, dynamic>?;
        
        IssueHistory? history;
        if (historyData != null) {
          history = IssueHistory.fromMap(Map<String, dynamic>.from(historyData));
        }
        
        await analysisProvider.addIssueHistory(symbol, issueTitle, history, newStatus: status);
        return {'status': 'success'};

      case 'GET_ANALYSIS':
        final symbol = data['symbol'] as String;
        final log = analysisProvider.getLogForSymbol(symbol);
        return {'status': 'success', 'data': log?.toMap()};

      // --- 계정(Portfolio) 및 자산 관리 ---
      case 'ADD_ACCOUNT_STOCK':
        final stock = Stock(
          id: data['symbol'] as String,
          symbol: data['symbol'] as String,
          name: data['name'] as String,
          quantity: (data['quantity'] ?? 0).toDouble(),
          purchasePrice: (data['purchasePrice'] ?? 0).toDouble(),
          currentPrice: (data['currentPrice'] ?? 0).toDouble(),
        );
        await portfolioProvider.addStock(stock);
        LogProvider.info('ACCOUNT', 'Stock added to manual portfolio: ${stock.symbol}');
        return {'status': 'success'};

      case 'REMOVE_ACCOUNT_STOCK':
        final symbol = data['symbol'] as String;
        await portfolioProvider.removeStock(symbol);
        LogProvider.info('ACCOUNT', 'Stock removed from manual portfolio: $symbol');
        return {'status': 'success'};

      case 'GET_ACCOUNT_INFO':
        return {
          'status': 'success',
          'data': {
            'kiwoomHoldings': accountProvider.kiwoomStocks.map((e) => e.toMap()).toList(),
            'manualPortfolio': portfolioProvider.stocks.map((e) => e.toMap()).toList(),
            'summary': {
              'totalAssets': accountProvider.totalAssets + portfolioProvider.totalAssets,
              'deposit': accountProvider.deposit,
              'selectedAccountNo': accountProvider.selectedAccountNo,
            }
          }
        };

      // --- 관심 종목(Watchlist) 관리 ---
      case 'GET_WATCHLIST':
        return {
          'status': 'success',
          'data': {
            'items': watchlistProvider.items.map((e) => e.toMap()).toList(),
          }
        };

      case 'ADD_WATCH_STOCK':
        final symbol = data['symbol'] as String;
        final name = data['name'] as String? ?? '분석 종목';
        await watchlistProvider.addStock(symbol, name);
        return {'status': 'success'};

      case 'REMOVE_WATCH_STOCK':
        final symbol = data['symbol'] as String;
        await watchlistProvider.removeStock(symbol);
        return {'status': 'success'};

      case 'SELECT_STOCK':
        final symbol = data['symbol'] as String;
        watchlistProvider.selectStock(symbol);
        analysisProvider.selectStock(symbol);
        return {'status': 'success'};

      // --- 시장 데이터 조회 ---
      case 'GET_MARKET_DATA':
        final symbol = data['symbol'] as String;
        final timeframeStr = data['timeframe'] as String? ?? 'day';
        final limit = data['limit'] as int? ?? 120;
        final timeframe = MarketTimeframe.values.firstWhere(
          (t) => t.protocolValue == timeframeStr,
          orElse: () => MarketTimeframe.day,
        );
        final marketData = await marketDataService.fetchMarketData(symbol: symbol, timeframe: timeframe, limit: limit);
        return {'status': 'success', 'data': marketData};

      default:
        return {'status': 'error', 'message': 'Unknown event [$event]'};
    }
  }
}
