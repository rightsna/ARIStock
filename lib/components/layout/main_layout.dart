import 'package:flutter/material.dart';
import '../analysis/screens/analysis_screen.dart';
import '../account/screens/account_screen.dart';
import '../strategy/screens/trading_strategy_screen.dart';
import '../watchlist/screens/watchlist_screen.dart';
import 'package:provider/provider.dart';
import '../watchlist/providers/watchlist_provider.dart';
import '../../../shared/theme.dart';
import 'package:ari_plugin/ari_plugin.dart';

/// 앱의 메인 레이아웃을 담당합니다.
/// 상단 탭 메뉴(종목분석-계좌)를 포함하며 프리미엄한 디자인을 지향합니다.
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: GlobalKey<ScaffoldState>(), // Drawer 제어용
        endDrawer: const Drawer(
          width: 340,
          backgroundColor: Colors.transparent, // 내부 Container의 둥근 모서리를 위해
          elevation: 0,
          child: SafeArea(child: WatchlistScreen()),
        ),
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_graph,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ARIStock',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              // 서버 접속 상태 표시 (녹색점) - StreamBuilder로 실시간 감지
              StreamBuilder<bool>(
                stream: AriAgent.connectionStream,
                initialData: AriAgent.isConnected,
                builder: (context, snapshot) {
                  final isConnected = snapshot.data ?? false;
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => Consumer<WatchlistProvider>(
                builder: (context, provider, child) {
                  final stock = provider.selectedStock;
                  return InkWell(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.show_chart,
                            color: AppTheme.primaryBlue,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stock?.name ?? '종목 선택',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.primaryBlue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: TabBar(
            tabs: const [
              Tab(text: '종목분석'),
              Tab(text: '매매전략'),
              Tab(text: '계좌'),
            ],
            indicatorColor: AppTheme.primaryBlue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSub,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                AppTheme.surfaceWhite.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: const TabBarView(
            children: [AnalysisScreen(), TradingStrategyScreen(), AccountScreen()],
          ),
        ),
      ),
    );
  }
}
