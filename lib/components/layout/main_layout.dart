import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../analysis/screens/analysis_screen.dart';
import '../account/screens/account_screen.dart';
import '../strategy/screens/trading_strategy_screen.dart';
import '../watchlist/screens/watchlist_screen.dart';
import 'package:provider/provider.dart';
import '../watchlist/providers/watchlist_provider.dart';
import '../../../shared/theme.dart';
import 'package:ari_plugin/ari_plugin.dart';
import 'main_app_bar.dart';
import '../trading/screens/trading_history_screen.dart';
import '../analysis/providers/analysis_provider.dart';
import '../analysis/screens/issue/issue_detail_sheet.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isChatOpen = true;
  late final TabController _tabController;

  static const _settingsBox = 'settings';
  static const _chatOpenKey = 'isChatOpen';
  static const _tabLabels = ['종목분석', '매매전략', '매매기록', '계좌'];

  @override
  void initState() {
    super.initState();
    _isChatOpen =
        Hive.box(_settingsBox).get(_chatOpenKey, defaultValue: true) as bool;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() => _isChatOpen = !_isChatOpen);
    Hive.box(_settingsBox).put(_chatOpenKey, _isChatOpen);
  }

  Future<void> _sendAgentMessageWithContext(
    BuildContext context,
    AriChatProvider chatProvider,
    String text,
  ) async {
    final selectedStock = context.read<WatchlistProvider>().selectedStock;
    final currentTab = _tabLabels[_tabController.index];

    try {
      await chatProvider.sendAgentMessage(
        text,
        appId: 'aristock',
        platform: 'aristock',
        details: {
          'currentTab': currentTab,
          if (selectedStock != null) ...{
            'selectedSymbol': selectedStock.symbol,
            'selectedName': selectedStock.name,
          },
        },
      );
    } catch (e) {
      chatProvider.addMessage(
        AriChatMessage(
          text: '에이전트에 연결할 수 없습니다. ($e)',
          isUser: false,
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, _) {
        final selectedIssue = analysisProvider.selectedIssue;
        final selectedStock = context.read<WatchlistProvider>().selectedStock;

        return AriBaseLayout(
          scaffoldKey: _scaffoldKey,
          appId: 'aristock',
          appName: 'ARIStock',
          showChat: _isChatOpen,
          drawer: const Drawer(
            width: 340,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SafeArea(child: WatchlistScreen()),
          ),
          appBar: MainAppBar(
            stock: selectedStock,
            tabController: _tabController,
            isChatOpen: _isChatOpen,
            onToggleChat: _toggleChat,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          chatContextLabel: selectedStock != null
              ? '${selectedStock.name} > ${_tabLabels[_tabController.index]}'
              : _tabLabels[_tabController.index],
          chatHeaderTitle: 'AI 에이전트 분석',
          chatHintText: '분석 요청...',
          chatProvider: context.read<AriChatProvider>(),
          onChatSend: (text) => _sendAgentMessageWithContext(
            context,
            context.read<AriChatProvider>(),
            text,
          ),
          body: Stack(
            children: [
              Container(
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
                child: ListenableBuilder(
                  listenable: _tabController,
                  builder: (context, _) => IndexedStack(
                    index: _tabController.index,
                    children: [
                      const AnalysisScreen(),
                      const TradingStrategyScreen(),
                      const TradingHistoryScreen(),
                      AccountScreen(
                        onNavigateToAnalysis: () {
                          _tabController.animateTo(0);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Dim background effect
              if (selectedIssue != null && selectedStock != null)
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: GestureDetector(
                          onTap: () => analysisProvider.selectIssue(null),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Slide-up Popup
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: (selectedIssue != null && selectedStock != null)
                    ? Align(
                        key: ValueKey(selectedIssue.id),
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: IssueDetailSheet(
                            symbol: selectedStock.symbol,
                            issue: selectedIssue,
                            provider: analysisProvider,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
