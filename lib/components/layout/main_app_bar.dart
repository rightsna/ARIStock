import 'package:aristock/components/watchlist/models/watchlist_model.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final WatchlistStock? stock;
  final TabController tabController;
  final bool isChatOpen;
  final VoidCallback onToggleChat;
  final VoidCallback onMenuPressed;

  const MainAppBar({
    super.key,
    required this.stock,
    required this.tabController,
    required this.isChatOpen,
    required this.onToggleChat,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onMenuPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onToggleChat,
          icon: Icon(
            isChatOpen ? Icons.chat_bubble : Icons.chat_bubble_outline,
            color: isChatOpen ? AppTheme.primaryBlue : AppTheme.textSub,
          ),
        ),
        const SizedBox(width: 8),
      ],
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottom: TabBar(
        controller: tabController,
        tabs: const [
          Tab(text: '종목분석'),
          Tab(text: '매매전략'),
          Tab(text: '매매기록'),
          Tab(text: '계좌'),
        ],
        indicatorColor: AppTheme.primaryBlue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.textSub,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}
