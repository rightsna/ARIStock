import 'package:flutter/foundation.dart';
import 'package:ari_plugin/ari_plugin.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../components/portfolio/providers/portfolio_provider.dart';
import '../../../components/analysis/providers/analysis_provider.dart';
import '../../../components/account/providers/account_provider.dart';
import '../../../components/account/services/kiwoom_services.dart';
import '../../../components/watchlist/providers/watchlist_provider.dart';
import '../technical/technical_analysis.dart';

/// AppProtocolHandler의 복잡한 로직을 분리하여 관리합니다.
class ARIProtocolHandler {
  static AppProtocolHandler create({
    required PortfolioProvider portfolioProvider,
    required AnalysisProvider analysisProvider,
    required AccountProvider accountProvider,
    required WatchlistProvider watchlistProvider,
    required KiwoomMarketDataService marketDataService,
  }) {
    return AppProtocolHandler(
      appId: 'aristock',
      onCommand: (command, params) async {
        try {
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
            case 'GET_ANALYSIS':
              final symbol = params['symbol']?.toString() ??
                  watchlistProvider.selectedSymbol;
              if (symbol == null || symbol.isEmpty) {
                return {'status': 'error', 'message': 'No stock selected'};
              }

              await analysisProvider.selectStock(symbol);
              final log = analysisProvider.selectedLog;

              if (log == null) {
                return {
                  'status': 'success',
                  'symbol': symbol,
                  'exists': false,
                  'message': 'No analysis found for this stock'
                };
              }

              return {
                'status': 'success',
                'symbol': symbol,
                'exists': true,
                'date': log.date,
                'summary': log.summary,
                'positive': log.checkPoints
                    ?.where((p) => p.isPositive)
                    .map((p) => {
                          'content': p.content,
                          'impact': p.impact,
                          'checked': p.isChecked
                        })
                    .toList(),
                'negative': log.checkPoints
                    ?.where((p) => !p.isPositive)
                    .map((p) => {
                          'content': p.content,
                          'impact': p.impact,
                          'checked': p.isChecked
                        })
                    .toList(),
                'others': log.otherOpinions,
                'trend': {
                  'short': log.shortTermScore,
                  'medium': log.mediumTermScore,
                  'long': log.longTermScore,
                },
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
              if (candles.isEmpty) {
                return {
                  'status': 'error',
                  'message': 'No candle data found for $symbol ($timeframe)'
                };
              }
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
              debugPrint('Fetching candles for $symbol (limit: $limit)');
              final candles = await marketDataService.fetchCandles(
                symbol: symbol,
                timeframe: timeframe,
                limit: limit,
              );

              if (candles.isEmpty) {
                return {
                  'status': 'error',
                  'message': 'No candle data found for $symbol ($timeframe)'
                };
              }

              debugPrint('Calculating strategy snapshot for $symbol');
              final snapshot = await IndicatorEngine.calculateStrategySnapshot(
                symbol: symbol,
                candles: candles,
              );
              debugPrint('Strategy snapshot calculated successfully');
              return {
                'status': 'success',
                'symbol': symbol,
                'timeframe': timeframe.protocolValue,
                'context': snapshot,
              };

            // ── 데이터 갱신 ──────────────────────────────────────────
            case 'CLEAR_DATABASE':
              await Future.wait([
                Hive.deleteBoxFromDisk('analysis_stock_box'),
                Hive.deleteBoxFromDisk('analysis_log_box'),
                Hive.deleteBoxFromDisk('portfolio_report_box'),
                Hive.deleteBoxFromDisk('watchlist_box'),
              ]);
              analysisProvider.init();
              accountProvider.init();
              watchlistProvider.init(accountProvider);
              return {'status': 'success', 'message': 'Database cleared'};

            // ── 데이터 저장 ──────────────────────────────────────────
            case 'SAVE_ANALYSIS':
              final symbol = params['symbol']?.toString();
              if (symbol != null && symbol.isNotEmpty) {
                final name = params['name']?.toString() ?? symbol;

                // 관심종목에 없으면 추가
                await watchlistProvider.addStock(symbol, name);

                await analysisProvider.saveAnalysis(
                  symbol,
                  name,
                  params['content']?.toString() ?? '', // 호환성 위해 유지하되 UI에서는 안씀
                  shortTermScore: double.tryParse(
                    params['trend_short']?.toString() ?? '',
                  ),
                  mediumTermScore: double.tryParse(
                    params['trend_medium']?.toString() ?? '',
                  ),
                  longTermScore: double.tryParse(
                    params['trend_long']?.toString() ?? '',
                  ),
                  summary: params['summary']?.toString(),
                  positive: params['positive'] is List
                      ? params['positive'] as List
                      : params['positive']
                          ?.toString()
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                  negative: params['negative'] is List
                      ? params['negative'] as List
                      : params['negative']
                          ?.toString()
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .toList(),
                  otherOpinions: params['others']?.toString(),
                );
                return {'status': 'success', 'message': 'Analysis saved'};
              }
              return {'status': 'error', 'message': 'Symbol is missing'};
            case 'SAVE_PORTFOLIO_REPORT':
              if (params['content'] != null) {
                accountProvider.saveReport(params['content'].toString());
                return {'status': 'success', 'message': 'Portfolio report saved'};
              }
              return {'status': 'error', 'message': 'Content is missing'};

            default:
              return {'status': 'error', 'message': 'Unknown command: $command'};
          }
        } catch (e) {
          return {'status': 'error', 'message': 'Execution failed: $e'};
        }
      },
      onGetState: () {
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
          'selectedStock': watchlistProvider.selectedSymbol,
          'hasLatestReport': accountProvider.latestReport != null,
          'apiLimits': {
            'kiwoom': {
              'requestsPerSecond': 5,
              'requestsPerMinute': 100,
              'currentRequestsLastMinute': marketDataService.getRequestsInLastMinute(),
              'advice': 'Reduce frequency of GET_MARKET_DATA and CALCULATE_INDICATORS. Current usage is high. Stop calling if currentRequestsLastMinute is near 90.',
            }
          }
        };
      },
      onGetCommands: () => ({
        'GET_ACCOUNT_INFO':
            'Fetch latest account info (API sync + stocks list). No params.',
        'GET_ANALYSIS':
            'Get the selected stock\'s analysis log. No params.',
        'GET_PORTFOLIO_REPORT':
            'Get the latest portfolio diagnosis report. No params.',
        'GET_MARKET_DATA':
            'Fetch standardized market data. Params: {symbol: String, timeframe: String[tick|1m|3m|5m|10m|15m|30m|45m|60m|1d], limit?: int}. Returns {candles} for OHLCV timeframes or {ticks} for tick timeframe.',
        'CALCULATE_INDICATORS':
            'Calculate atomic indicators from market data. Params: {symbol: String, timeframe: String, limit?: int, indicators?: List<{type:String,key:String,params?:Map}>}. Supported types: sma, ema, rsi, macd, bollinger, atr, volume, trend, vwap, price_change.',
        'GET_TRADING_CONTEXT':
            'Fetch strategy-ready snapshot with OHLCV-derived trend, momentum, volatility, and volume context. Params: {symbol: String, timeframe: String, limit?: int}.',
        'CLEAR_DATABASE': 'Delete all local data and reset the app. No params.',
        'SAVE_ANALYSIS':
            'Save a structured stock analysis. [IMPORTANT] DO NOT use Markdown "content" field. Use structured parameters instead. Params: {symbol: String, name: String, summary: String, positive: List<Map{content,impact:1-5}>, negative: List<Map{content,impact:1-5}>, others: String, trend_short: 0.0-1.0, trend_medium: 0.0-1.0, trend_long: 0.0-1.0}',
        'SAVE_PORTFOLIO_REPORT':
            'Save a portfolio diagnosis report. Params: {content: String (Markdown)}',
      }),
    );
  }
}
