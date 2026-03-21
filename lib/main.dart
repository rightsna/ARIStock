import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/theme.dart';
import 'components/layout/main_layout.dart';
import 'components/portfolio/providers/portfolio_provider.dart';
import 'components/portfolio/models/stock.dart';
import 'components/briefing/providers/briefing_provider.dart';
import 'components/briefing/models/briefing_model.dart';
import 'components/consultation/providers/consultation_provider.dart';
import 'components/consultation/models/consultation_model.dart';
import 'components/strategy/providers/strategy_provider.dart';
import 'components/strategy/models/strategy_model.dart';
import 'components/account/providers/account_provider.dart';
import 'components/account/models/portfolio_report_model.dart';
import 'components/account/services/kiwoom_services.dart';
import 'services/technical/technical_analysis.dart';

import 'package:ari_plugin/ari_plugin.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 어댑터 등록
  Hive.registerAdapter(BriefingAdapter());
  Hive.registerAdapter(ConsultationStockAdapter());
  Hive.registerAdapter(ConsultationLogAdapter());
  Hive.registerAdapter(StrategyAdapter());
  Hive.registerAdapter(TradingLogAdapter());
  Hive.registerAdapter(PortfolioReportAdapter());
  Hive.registerAdapter(StockAdapter());

  // Provider 인스턴스 미리 생성
  final portfolioProvider = PortfolioProvider()..init();
  final briefingProvider = BriefingProvider()..loadTodayBriefing();
  final consultationProvider = ConsultationProvider()..init();
  final strategyProvider = StrategyProvider()..init();
  final kiwoom = KiwoomServiceBundle();
  final accountProvider = AccountProvider(kiwoom: kiwoom)..init();
  final marketDataService = KiwoomMarketDataService(kiwoom.market);

  // ARI Plugin 연동 설정
  String? readArg(String prefix) {
    for (final arg in args) {
      if (arg.startsWith(prefix)) return arg.substring(prefix.length);
    }
    return null;
  }

  final port =
      readArg('--port=') ??
      const String.fromEnvironment('ARI_PORT', defaultValue: '29277');
  final host =
      readArg('--host=') ??
      const String.fromEnvironment('ARI_HOST', defaultValue: '127.0.0.1');

  if (port.isNotEmpty) {
    WsManager.init(host: host, port: int.parse(port));
    WsManager.connect();

    final handler = AppProtocolHandler(
      appId: 'aristock',
      onCommand: (command, params) async {
        switch (command) {
          // ── 데이터 조회 ──────────────────────────────────────────
          case 'GET_ACCOUNT_INFO':
            if (accountProvider.hasApiKeys) {
              await accountProvider.manualFetchAccounts();
            }
            final useApi =
                accountProvider.hasApiKeys && accountProvider.totalAssets > 0;
            final stocks = useApi
                ? accountProvider.kiwoomStocks
                : portfolioProvider.stocks;
            return {
              'status': 'success',
              'isApiConnected': accountProvider.hasApiKeys,
              'totalAssets': useApi
                  ? accountProvider.totalAssets
                  : portfolioProvider.totalAssets,
              'deposit': useApi ? accountProvider.deposit : 0,
              'profitPercentage': useApi
                  ? accountProvider.totalProfitRate
                  : portfolioProvider.totalProfitPercentage,
              'stocks': stocks
                  .map(
                    (s) => {
                      'id': s.id,
                      'symbol': s.symbol,
                      'name': s.name,
                      'quantity': s.quantity,
                      'purchasePrice': s.purchasePrice,
                      'currentPrice': s.currentPrice,
                      'profit': s.profitPercentage,
                    },
                  )
                  .toList(),
            };
          case 'GET_BRIEFING':
            return {
              'status': 'success',
              'content': briefingProvider.currentBriefing?.content,
            };
          case 'GET_CONSULTATION':
            return {
              'status': 'success',
              'symbol': consultationProvider.selectedLog?.stockSymbol,
              'content': consultationProvider.selectedLog?.content,
            };
          case 'GET_PORTFOLIO_REPORT':
            return {
              'status': 'success',
              'content': accountProvider.latestReport?.content,
            };
          case 'GET_MARKET_DATA':
            final symbol = params['symbol']?.toString();
            if (symbol == null || symbol.isEmpty) {
              return {'status': 'error', 'message': 'Symbol is missing'};
            }
            if (!accountProvider.hasApiKeys) {
              return {'status': 'error', 'message': 'Kiwoom API is not connected'};
            }

            final timeframe = MarketTimeframeX.parse(
              params['timeframe']?.toString() ?? '1d',
            );
            final limit = int.tryParse(params['limit']?.toString() ?? '') ?? 120;
            final payload = await marketDataService.fetchMarketData(
              symbol: symbol,
              timeframe: timeframe,
              limit: limit,
            );
            return {
              'status': 'success',
              ...payload,
            };
          case 'CALCULATE_INDICATORS':
            final symbol = params['symbol']?.toString();
            if (symbol == null || symbol.isEmpty) {
              return {'status': 'error', 'message': 'Symbol is missing'};
            }
            if (!accountProvider.hasApiKeys) {
              return {'status': 'error', 'message': 'Kiwoom API is not connected'};
            }

            final timeframe = MarketTimeframeX.parse(
              params['timeframe']?.toString() ?? '1d',
            );
            if (timeframe.isTick) {
              return {
                'status': 'error',
                'message': 'Tick timeframe is not supported for indicator calculation',
              };
            }

            final limit = int.tryParse(params['limit']?.toString() ?? '') ?? 120;
            final candles = await marketDataService.fetchCandles(
              symbol: symbol,
              timeframe: timeframe,
              limit: limit,
            );
            final rawIndicators = params['indicators'];
            final indicators = rawIndicators is List
                ? rawIndicators.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
                : <Map<String, dynamic>>[
                    {'type': 'sma', 'key': 'ma20', 'params': {'period': 20}},
                    {'type': 'ema', 'key': 'ema20', 'params': {'period': 20}},
                    {'type': 'rsi', 'key': 'rsi14', 'params': {'period': 14}},
                    {'type': 'macd', 'key': 'macd'},
                    {'type': 'atr', 'key': 'atr14', 'params': {'period': 14}},
                    {'type': 'volume', 'key': 'volume20', 'params': {'period': 20}},
                    {'type': 'trend', 'key': 'trend20', 'params': {'period': 20}},
                  ];

            final result = IndicatorEngine.calculateAtomic(
              candles: candles,
              indicators: indicators,
            );
            return {
              'status': 'success',
              'symbol': symbol,
              'timeframe': timeframe.protocolValue,
              'result': result,
            };
          case 'GET_TRADING_CONTEXT':
            final symbol = params['symbol']?.toString();
            if (symbol == null || symbol.isEmpty) {
              return {'status': 'error', 'message': 'Symbol is missing'};
            }
            if (!accountProvider.hasApiKeys) {
              return {'status': 'error', 'message': 'Kiwoom API is not connected'};
            }

            final timeframe = MarketTimeframeX.parse(
              params['timeframe']?.toString() ?? '1d',
            );
            if (timeframe.isTick) {
              return {
                'status': 'error',
                'message': 'Tick timeframe is not supported for trading context',
              };
            }

            final limit = int.tryParse(params['limit']?.toString() ?? '') ?? 200;
            final candles = await marketDataService.fetchCandles(
              symbol: symbol,
              timeframe: timeframe,
              limit: limit,
            );
            final snapshot = await IndicatorEngine.calculateStrategySnapshot(
              symbol: symbol,
              candles: candles,
            );
            return {
              'status': 'success',
              'symbol': symbol,
              'timeframe': timeframe.protocolValue,
              'context': snapshot,
            };

          // ── 데이터 갱신 ──────────────────────────────────────────
          case 'REFRESH_ALL':
            briefingProvider.loadTodayBriefing();
            consultationProvider.init();
            return {'status': 'success', 'message': 'Data refreshed'};
          case 'CLEAR_DATABASE':
            await Future.wait([
              Hive.deleteBoxFromDisk('briefing_box'),
              Hive.deleteBoxFromDisk('consultation_stock_box'),
              Hive.deleteBoxFromDisk('consultation_log_box'),
              Hive.deleteBoxFromDisk('strategy_box'),
              Hive.deleteBoxFromDisk('trading_log_box'),
              Hive.deleteBoxFromDisk('portfolio_report_box'),
            ]);
            briefingProvider.loadTodayBriefing();
            consultationProvider.init();
            strategyProvider.init();
            accountProvider.init();
            return {'status': 'success', 'message': 'Database cleared'};

          // ── 데이터 저장 ──────────────────────────────────────────
          case 'SAVE_BRIEFING':
            if (params['content'] != null) {
              final today = DateTime.now().toIso8601String().split('T')[0];
              briefingProvider.saveBriefing(today, params['content']);
              return {'status': 'success', 'message': 'Briefing saved'};
            }
            return {'status': 'error', 'message': 'Content is missing'};
          case 'SAVE_CONSULTATION':
            if (params['symbol'] != null && params['content'] != null) {
              consultationProvider.saveConsultation(
                params['symbol'],
                params['name'] ?? params['symbol'],
                params['content'],
              );
              return {'status': 'success', 'message': 'Consultation saved'};
            }
            return {'status': 'error', 'message': 'Symbol or content missing'};
          case 'SAVE_STRATEGY':
            if (params['symbol'] != null && params['content'] != null) {
              strategyProvider.saveStrategy(
                params['symbol'],
                params['name'] ?? params['symbol'],
                params['content'],
              );
              return {'status': 'success', 'message': 'Strategy saved'};
            }
            return {'status': 'error', 'message': 'Symbol or content missing'};
          case 'SAVE_PORTFOLIO_REPORT':
            if (params['content'] != null) {
              accountProvider.saveReport(params['content']);
              return {'status': 'success', 'message': 'Portfolio report saved'};
            }
            return {'status': 'error', 'message': 'Content is missing'};

          default:
            return {'status': 'error', 'message': 'Unknown command: $command'};
        }
      },
      onGetState: () {
        // 가벼운 앱 상태 스냅샷만 반환. 상세 데이터는 GET_* 커맨드로 요청.
        final bool connected = accountProvider.hasApiKeys;
        final bool useApi = connected && accountProvider.totalAssets > 0;
        return {
          'isApiConnected': connected,
          'totalAssets': useApi
              ? accountProvider.totalAssets
              : portfolioProvider.totalAssets,
          'profitPercentage': useApi
              ? accountProvider.totalProfitRate
              : portfolioProvider.totalProfitPercentage,
          'stockCount': useApi
              ? accountProvider.kiwoomStocks.length
              : portfolioProvider.stocks.length,
          'selectedStock': consultationProvider.selectedLog?.stockSymbol,
          'hasBriefingToday': briefingProvider.currentBriefing != null,
          'hasLatestReport': accountProvider.latestReport != null,
        };
      },
      onGetCommands: () => {
        // 조회
        'GET_ACCOUNT_INFO':
            'Fetch latest account info (API sync + stocks list). No params.',
        'GET_BRIEFING': 'Get today\'s briefing content. No params.',
        'GET_CONSULTATION':
            'Get the selected stock\'s consultation log. No params.',
        'GET_PORTFOLIO_REPORT':
            'Get the latest portfolio diagnosis report. No params.',
        'GET_MARKET_DATA':
            'Fetch standardized market data. Params: {symbol: String, timeframe: String[tick|1m|3m|5m|10m|15m|30m|45m|60m|1d], limit?: int}. Returns {candles} for OHLCV timeframes or {ticks} for tick timeframe.',
        'CALCULATE_INDICATORS':
            'Calculate atomic indicators from market data. Params: {symbol: String, timeframe: String, limit?: int, indicators?: List<{type:String,key:String,params?:Map}>}. Supported types: sma, ema, rsi, macd, bollinger, atr, volume, trend, vwap, price_change.',
        'GET_TRADING_CONTEXT':
            'Fetch strategy-ready snapshot with OHLCV-derived trend, momentum, volatility, and volume context. Params: {symbol: String, timeframe: String, limit?: int}.',
        // 갱신
        'REFRESH_ALL': 'Reload all data from local DB. No params.',
        'CLEAR_DATABASE': 'Delete all local data and reset the app. No params.',
        // 저장
        'SAVE_BRIEFING':
            'Save today\'s investment briefing. Params: {content: String (Markdown)}',
        'SAVE_CONSULTATION':
            'Save a stock consultation log. Params: {symbol: String, name: String, content: String (Markdown)}',
        'SAVE_STRATEGY':
            'Save a trading strategy for a stock. Params: {symbol: String, name: String, content: String (Markdown)}',
        'SAVE_PORTFOLIO_REPORT':
            'Save a portfolio diagnosis report. Params: {content: String (Markdown)}',
      },
    );
    handler.start();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: portfolioProvider),
        ChangeNotifierProvider.value(value: briefingProvider),
        ChangeNotifierProvider.value(value: consultationProvider),
        ChangeNotifierProvider.value(value: strategyProvider),
        ChangeNotifierProvider.value(value: accountProvider),
      ],
      child: const ARIStockApp(),
    ),
  );
}

class ARIStockApp extends StatelessWidget {
  const ARIStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ARIStock',
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
    );
  }
}
