import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../analysis/screens/analysis_screen.dart';
import '../account/screens/account_screen.dart';
import '../strategy/screens/trading_strategy_screen.dart';
import '../watchlist/screens/watchlist_screen.dart';
import '../chat/chat_panel.dart';
import 'package:provider/provider.dart';
import '../watchlist/providers/watchlist_provider.dart';
import '../../../shared/theme.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../trading/screens/trading_history_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isChatOpen = true;
  double _chatWidth = 360;
  late final TabController _tabController;

  static const _settingsBox = 'settings';
  static const _chatOpenKey = 'isChatOpen';
  static const _minChatWidth = 240.0;
  static const _maxChatWidthRatio = 0.6;
  static const _tabLabels = ['종목분석', '매매전략', '매매기록', '계좌'];

  @override
  void initState() {
    super.initState();
    _isChatOpen = Hive.box(_settingsBox).get(_chatOpenKey, defaultValue: true) as bool;
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

  @override
  Widget build(BuildContext context) {
    final maxChatWidth = MediaQuery.of(context).size.width * _maxChatWidthRatio;

    return Scaffold(
      body: Row(
        children: [
          // ── 왼쪽: 기존 앱 전체 ──
          Expanded(
            child: Scaffold(
              key: _scaffoldKey,
              endDrawer: const Drawer(
                width: 340,
                backgroundColor: Colors.transparent,
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
                      child: const Icon(Icons.auto_graph, color: AppTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ARIStock',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const SizedBox(width: 8),
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
                  Consumer<WatchlistProvider>(
                    builder: (context, provider, child) {
                      final stock = provider.selectedStock;
                      return InkWell(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.show_chart, color: AppTheme.primaryBlue, size: 14),
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
                              const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryBlue, size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: _toggleChat,
                    icon: Icon(
                      _isChatOpen ? Icons.chat_bubble : Icons.chat_bubble_outline,
                      color: _isChatOpen ? AppTheme.primaryBlue : AppTheme.textSub,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: '종목분석'), Tab(text: '매매전략'), Tab(text: '매매기록'), Tab(text: '계좌')],
                  indicatorColor: AppTheme.primaryBlue,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: AppTheme.textSub,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                child: ListenableBuilder(
                  listenable: _tabController,
                  builder: (context, _) => IndexedStack(
                    index: _tabController.index,
                    children: const [
                      AnalysisScreen(),
                      TradingStrategyScreen(),
                      TradingHistoryScreen(),
                      AccountScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 드래그 가능한 구분선 ──
          if (_isChatOpen)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _chatWidth = (_chatWidth - details.delta.dx).clamp(_minChatWidth, maxChatWidth);
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(
                  width: 8,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppTheme.textMain24, width: 1)),
                  ),
                ),
              ),
            ),

          // ── 오른쪽: 채팅 패널 ──
          if (_isChatOpen)
            SizedBox(
              width: _chatWidth,
              child: ChatPanel(
                tabController: _tabController,
                tabLabels: _tabLabels,
              ),
            ),
        ],
      ),
    );
  }
}
