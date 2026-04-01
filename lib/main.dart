import 'package:aristock/shared/repository/kiwoom/trading_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/theme.dart';
import 'components/layout/main_layout.dart';

import 'shared/models/stock/stock.dart';
import 'shared/repository/kiwoom/market_data_repository.dart';
import 'components/analysis/providers/analysis_provider.dart';
import 'components/analysis/models/stock_analysis_model.dart';
import 'components/analysis/models/investment_issue_model.dart';
import 'components/account/providers/account_provider.dart';

import 'package:aristock/shared/infra/kiwoom_api_client.dart';
import 'package:aristock/shared/repository/kiwoom/account_repository.dart';
import 'package:aristock/shared/repository/kiwoom/market_repository.dart';
import 'components/watchlist/providers/watchlist_provider.dart';
import 'components/watchlist/models/watchlist_model.dart';
import 'components/strategy/models/trading_strategy_model.dart';
import 'components/strategy/providers/trading_strategy_provider.dart';
import 'components/strategy/providers/stock_chart_provider.dart';
import 'components/chat/chat_provider.dart';
import 'package:ari_plugin/ari_plugin.dart';

import 'shared/services/protocol/ari_protocol_handler.dart';
import 'components/trading/models/trading_record_model.dart';
import 'components/trading/providers/trading_record_provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 어댑터 등록
  Hive.registerAdapter(StockAnalysisAdapter());
  Hive.registerAdapter(InvestmentIssueAdapter());
  Hive.registerAdapter(IssueHistoryAdapter());

  Hive.registerAdapter(StockAdapter());
  Hive.registerAdapter(WatchlistStockAdapter());
  Hive.registerAdapter(TradingStrategyAdapter());
  Hive.registerAdapter(TradingRecordAdapter());

  // Provider 인스턴스 생성 및 초기화 대기

  await Hive.openBox('settings');

  final analysisProvider = AnalysisProvider();
  await analysisProvider.init();

  final tradingRecordProvider = TradingRecordProvider();
  await tradingRecordProvider.init();

  final kiwoomClient = KiwoomApiClient();
  final kiwoomAccount = KiwoomAccountRepository(kiwoomClient);
  final kiwoomMarket = KiwoomMarketRepository(kiwoomClient);
  final kiwoomTrading = KiwoomTradingRepository(kiwoomClient);

  final accountProvider = AccountProvider(
    apiClient: kiwoomClient,
    accountService: kiwoomAccount,
    marketService: kiwoomMarket,
    tradingService: kiwoomTrading,
  );
  await accountProvider.init();

  final watchlistProvider = WatchlistProvider();
  await watchlistProvider.init(accountProvider);

  final tradingStrategyProvider = TradingStrategyProvider();
  final chatProvider = ChatProvider();

  final marketDataService = KiwoomMarketDataRepository(kiwoomMarket);

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
    AriAgent.init(host: host, port: int.parse(port));
    AriAgent.connect();

    final isHeadless = args.contains('--headless');

    final handler = ARIProtocolHandler.create(
      analysisProvider: analysisProvider,
      accountProvider: accountProvider,
      watchlistProvider: watchlistProvider,
      tradingStrategyProvider: tradingStrategyProvider,
      tradingRecordProvider: tradingRecordProvider,
      chatProvider: chatProvider,
      marketDataService: marketDataService,
      isHeadless: isHeadless,
    );
    handler.start();

    // Headless 모드 체크 (UI 없이 백그라운드 서비스로 동작)
    if (isHeadless) {
      debugPrint('ARIStock: Running in headless mode...');
      // 프로세스 유지를 위해 무한 대기
      return;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: analysisProvider),
        ChangeNotifierProvider.value(value: accountProvider),
        ChangeNotifierProvider.value(value: watchlistProvider),
        ChangeNotifierProvider.value(value: tradingStrategyProvider),
        ChangeNotifierProvider.value(value: tradingRecordProvider),
        ChangeNotifierProvider.value(value: chatProvider),
        ChangeNotifierProvider(create: (_) => StockChartProvider(marketDataService)),
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
