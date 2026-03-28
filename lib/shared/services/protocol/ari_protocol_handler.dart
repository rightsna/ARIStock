import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ari_plugin/ari_plugin.dart';
import 'package:aristock/components/analysis/models/stock_analysis_model.dart';
import 'package:aristock/components/analysis/models/investment_issue_model.dart';
import 'package:aristock/components/analysis/providers/analysis_provider.dart';
import 'package:aristock/components/account/providers/account_provider.dart';
import 'package:aristock/components/watchlist/providers/watchlist_provider.dart';
import 'package:aristock/components/portfolio/providers/portfolio_provider.dart';
// import 'package:aristock/components/portfolio/models/stock.dart';
import 'package:aristock/components/account/services/kiwoom_market_data_service.dart';
import 'package:aristock/shared/models/market/market_timeframe.dart';
import 'package:aristock/shared/services/log_provider.dart';
import 'package:aristock/components/watchlist/models/watchlist_model.dart';

/// AriFramework 표준을 준수하는 종목분석 프로토콜 핸들러입니다.
class ARIProtocolHandler {
  final PortfolioProvider portfolioProvider;
  final AnalysisProvider analysisProvider;
  final AccountProvider accountProvider;
  final WatchlistProvider watchlistProvider;
  final KiwoomMarketDataService marketDataService;
  final bool isHeadless;

  ARIProtocolHandler._({
    required this.portfolioProvider,
    required this.analysisProvider,
    required this.accountProvider,
    required this.watchlistProvider,
    required this.marketDataService,
    required this.isHeadless,
  });

  factory ARIProtocolHandler.create({
    required PortfolioProvider portfolioProvider,
    required AnalysisProvider analysisProvider,
    required AccountProvider accountProvider,
    required WatchlistProvider watchlistProvider,
    required KiwoomMarketDataService marketDataService,
    required bool isHeadless,
  }) {
    return ARIProtocolHandler._(
      portfolioProvider: portfolioProvider,
      analysisProvider: analysisProvider,
      accountProvider: accountProvider,
      watchlistProvider: watchlistProvider,
      marketDataService: marketDataService,
      isHeadless: isHeadless,
    );
  }

  late final AppProtocolHandler _protocolHandler;

  void start() {
    debugPrint('ARIProtocolHandler: Starting protocol engine...');

    _protocolHandler = AppProtocolHandler(
      appId: 'aristock',
      onCommand: _handleEvent,
      onGetState: _getState,
      onGetCommands: _getCommands,
    );

    _protocolHandler.start();
  }

  void stop() {
    _protocolHandler.stop();
  }

  Map<String, dynamic> _getState() {
    final bool useApi = accountProvider.hasApiKeys;
    return {
      'isApiConnected': useApi,
      'totalAssets': useApi
          ? accountProvider.totalAssets
          : portfolioProvider.totalAssets,
      'stockCount': useApi
          ? accountProvider.kiwoomStocks.length
          : portfolioProvider.stocks.length,
      'selectedAccountNo': accountProvider.selectedAccountNo,
    };
  }

  Map<String, String> _getCommands() {
    return {
      // --- 투자 분석 및 기록 (Living Timeline) ---
      'SAVE_ANALYSIS_SUMMARY': '종목의 핵심 투자 가설, 분석 본문 및 3단계 투자 점수(단/중/장기) 기록 [params: symbol, content(Markdown), shortTermScore(0-1), mediumTermScore(0-1), longTermScore(0-1), summary(한줄요약)]',
      'SAVE_ANALYSIS_ISSUES': '종목의 주요 투자 이슈(재료) 리스트 일괄 등록 및 병합. 신규 추가 시 자동 하이라이팅 적용 [params: symbol, issues: List<{title, isPositive, impact(1-5), status}>]',
      'UPDATE_ISSUE_PROGRESS': '기존 이슈의 히스토리 추가 및 상태 업데이트. AI 탐지 시 타임라인 상에 시각적 강조 표시 [params: symbol, issueTitle, history: {date, content, detail}, status?]',
      'GET_ANALYSIS_FULL': '특정 종목의 상시 분석 요약, 3단계 점수, 모든 이슈 타임라인 내역 조회 [params: symbol]',
      'GET_ANALYSIS_RECENT': '특정 종목의 최신 요약 및 핵심 점수(단기) 간략 조회 [params: symbol]',

      // --- 계정 및 시장 데이터 ---
      'GET_ACCOUNT_INFO': '연동된 계좌의 자산 총액 및 실보유 종목(평균가, 수량, 수익률 포함) 리스트 조회 [no params]',
      'GET_MARKET_DATA': '차트 데이터 및 실시간 호가 조회 [params: symbol, timeframe: "tick"|"1m"|"5m"|"15m"|"1d", limit: 데이터개수]',

      // --- 관심 종목 및 탐색 ---
      'GET_WATCHLIST': '현재 사용자의 관심 종목(Watchlist) 리스트 및 현재 선택된 종목 확인 [no params]',
      'ADD_WATCH_STOCK': '관심 종목 리스트에 새로운 종목 추가 [params: symbol, name?]',
      'REMOVE_WATCH_STOCK': '관심 종목 리스트에서 특정 종목 제거 [params: symbol]',
      'SELECT_STOCK': '앱 UI의 화면을 특정 종목 상세 화면으로 강제 이동 [params: symbol]',
      'GET_APP_STATUS': '앱의 현재 실행 상태(Headless 여부 등) 조회 [no params]',
    };
  }

  Future<Map<String, dynamic>> _handleEvent(
    String event,
    Map<String, dynamic> data,
  ) async {
    LogProvider.debug('ARI_EVENT', 'Handling event: $event');
    switch (event) {
      // --- 앱 상태 관리 ---
      case 'GET_APP_STATUS':
        return {
          'status': 'success',
          'data': {
            'isHeadless': isHeadless,
            'appId': 'aristock',
            'version': '1.0.3',
          }
        };

      // 종합 분석 본문 및 점수 저장
      case 'SAVE_ANALYSIS_SUMMARY':
        final symbol = data['symbol'] as String;
        final name = data['name'] as String? ?? watchlistProvider.items.firstWhere((e) => e.symbol == symbol, orElse: () => WatchlistStock(symbol: symbol, name: symbol)).name;
        
        final analysis = StockAnalysis.fromMap(Map<String, dynamic>.from({
          ...data,
          'symbol': symbol,
          'stockName': name,
          'date': DateTime.now().toString().split(' ')[0],
        }));
        await analysisProvider.addAnalysisLog(analysis);
        LogProvider.info('ANALYSIS', 'Summary updated for $symbol');
        return {'status': 'success'};

      // 주요 이슈(재료) 일괄 등록 및 병합
      case 'SAVE_ANALYSIS_ISSUES':
        final symbol = data['symbol'] as String;
        final name = data['name'] as String? ?? watchlistProvider.items.firstWhere((e) => e.symbol == symbol, orElse: () => WatchlistStock(symbol: symbol, name: symbol)).name;

        final analysis = StockAnalysis.fromMap(Map<String, dynamic>.from({
          'symbol': symbol,
          'stockName': name,
          'issues': data['issues'],
          'date': DateTime.now().toString().split(' ')[0],
        }));
        await analysisProvider.addAnalysisLog(analysis);
        LogProvider.info('ANALYSIS', 'Issues updated for $symbol');
        return {'status': 'success'};

      // 특정 이슈의 진행 상황 기록 히스토리 업데이트
      case 'UPDATE_ISSUE_PROGRESS':
        final symbol = data['symbol'] as String;
        final issueTitle = data['issueTitle'] as String;
        final status = data['status'] as String?;
        final historyData = data['history'] as Map<String, dynamic>?;
        final name = data['name'] as String? ?? watchlistProvider.items.firstWhere((e) => e.symbol == symbol, orElse: () => WatchlistStock(symbol: symbol, name: symbol)).name;

        IssueHistory? history;
        if (historyData != null) {
          history = IssueHistory.fromMap(
            Map<String, dynamic>.from(historyData),
          );
        }

        await analysisProvider.addIssueHistory(
          symbol,
          issueTitle,
          history,
          newStatus: status,
          stockName: name,
        );
        LogProvider.info('ANALYSIS', 'Issue progress updated: $issueTitle ($symbol)');
        return {'status': 'success'};

      // 특정 종목의 모든 분석 내역 조회
      case 'GET_ANALYSIS_FULL':
        final symbol = data['symbol'] as String;
        final analysis = analysisProvider.getAnalysisForSymbol(symbol);
        return {'status': 'success', 'data': analysis?.toMap()};

      // 특정 종목의 요약 정보 및 점수만 조회
      case 'GET_ANALYSIS_RECENT':
        final symbol = data['symbol'] as String;
        final analysis = analysisProvider.getAnalysisForSymbol(symbol);
        if (analysis == null) return {'status': 'success', 'data': null};
        
        return {
          'status': 'success',
          'data': {
            'symbol': analysis.symbol,
            'date': analysis.date,
            'summary': analysis.summary,
            'shortTermScore': analysis.shortTermScore,
            'content': analysis.content,
          }
        };

      // --- 2. 계정(Portfolio) 및 자산 관리 ---
      case 'GET_ACCOUNT_INFO':
        return {
          'status': 'success',
          'data': {
            'holdings': accountProvider.hasApiKeys
                ? accountProvider.kiwoomStocks.map((e) => e.toMap()).toList()
                : portfolioProvider.stocks.map((e) => e.toMap()).toList(),
            'summary': {
              'totalAssets': accountProvider.hasApiKeys
                  ? accountProvider.totalAssets
                  : portfolioProvider.totalAssets,
              'deposit': accountProvider.deposit,
              'selectedAccountNo': accountProvider.selectedAccountNo,
              'isRealAccount': accountProvider.hasApiKeys,
            },
          },
        };

      // --- 3. 관심 종목(Watchlist) 관리 ---
      case 'GET_WATCHLIST':
        return {
          'status': 'success',
          'data': {
            'items': watchlistProvider.items.map((e) => e.toMap()).toList(),
          },
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

      // --- 4. 시장 데이터 조회 ---
      case 'GET_MARKET_DATA':
        final symbol = data['symbol'] as String;
        final timeframeStr = data['timeframe'] as String? ?? 'day';
        final limit = data['limit'] as int? ?? 120;
        final timeframe = MarketTimeframe.values.firstWhere(
          (t) => t.protocolValue == timeframeStr,
          orElse: () => MarketTimeframe.day,
        );
        final marketData = await marketDataService.fetchMarketData(
          symbol: symbol,
          timeframe: timeframe,
          limit: limit,
        );
        return {'status': 'success', 'data': marketData};

      default:
        return {'status': 'error', 'message': 'Unknown event [$event]'};
    }
  }
}
