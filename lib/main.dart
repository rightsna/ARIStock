import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/theme.dart';
import 'components/layout/main_layout.dart';
import 'components/portfolio/providers/portfolio_provider.dart';
import 'components/portfolio/models/stock.dart';
import 'components/analysis/providers/analysis_provider.dart';
import 'components/analysis/models/analysis_model.dart';
import 'components/account/providers/account_provider.dart';
import 'components/account/models/portfolio_report_model.dart';
import 'components/account/services/kiwoom_services.dart';
import 'components/watchlist/providers/watchlist_provider.dart';
import 'components/watchlist/models/watchlist_model.dart';
import 'package:ari_plugin/ari_plugin.dart';

import 'shared/services/protocol/ari_protocol_handler.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 어댑터 등록
  Hive.registerAdapter(AnalysisStockAdapter());
  Hive.registerAdapter(AnalysisLogAdapter());
  Hive.registerAdapter(InvestmentIssueAdapter());
  Hive.registerAdapter(IssueHistoryAdapter());

  Hive.registerAdapter(PortfolioReportAdapter());
  Hive.registerAdapter(StockAdapter());
  Hive.registerAdapter(WatchlistStockAdapter());

  // Provider 인스턴스 생성 및 초기화 대기
  final portfolioProvider = PortfolioProvider();
  await portfolioProvider.init();
  
  final analysisProvider = AnalysisProvider();
  await analysisProvider.init();
  
  final kiwoom = KiwoomServiceBundle();
  final accountProvider = AccountProvider(kiwoom: kiwoom);
  await accountProvider.init();
  
  final watchlistProvider = WatchlistProvider();
  await watchlistProvider.init(accountProvider);
  
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

    final isHeadless = args.contains('--headless');

    final handler = ARIProtocolHandler.create(
      portfolioProvider: portfolioProvider,
      analysisProvider: analysisProvider,
      accountProvider: accountProvider,
      watchlistProvider: watchlistProvider,
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
        ChangeNotifierProvider.value(value: portfolioProvider),
        ChangeNotifierProvider.value(value: analysisProvider),
        ChangeNotifierProvider.value(value: accountProvider),
        ChangeNotifierProvider.value(value: watchlistProvider),
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
