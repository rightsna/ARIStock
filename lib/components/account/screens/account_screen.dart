import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../../analysis/providers/analysis_provider.dart';
import '../../../shared/theme.dart';
import 'kiwoom_setup/kiwoom_setup_screen.dart';
import 'widgets/api_status_bar.dart';
import 'widgets/asset_summary_card.dart';
import 'widgets/stock_item_row.dart';
import 'debug/kiwoom_debug_screen.dart';

/// 계좌 화면: API 연동 상태에 따라 설정 화면 또는 포트폴리오 메인 화면을 표시합니다.
class AccountScreen extends StatelessWidget {
  final VoidCallback? onNavigateToAnalysis;

  const AccountScreen({super.key, this.onNavigateToAnalysis});

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    // API 키 연동 상태만 확인 (수동 입력 기능 제거)
    final bool hasData = accountProvider.hasApiKeys;

    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite, // 더 깔끔하고 고급스러운 순백색 배경
      body: hasData
          ? _buildMainView(context, accountProvider)
          : const ApiKeySetupScreen(),
      floatingActionButton: null,
    );
  }

  Widget _buildMainView(BuildContext context, AccountProvider accountProvider) {
    final format = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    final displayTotalAssets = accountProvider.totalAssets;
    final displayProfitRate = accountProvider.totalProfitRate;
    final displayStocks = accountProvider.kiwoomStocks;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), // 상단 및 측면 여백 축소
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApiStatusBar(
                  accountProvider: accountProvider,
                  onDisconnect: _showDisconnectDialog,
                ),
                const SizedBox(height: 24), // 32 -> 24
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PORTFOLIO',
                      style: TextStyle(
                        color: AppTheme.textMain.withValues(alpha: 0.15),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    _buildTopActions(context, accountProvider),
                  ],
                ),
                const SizedBox(height: 16), // 24 -> 16
                AssetSummaryCard(
                  accountProvider: accountProvider,
                  totalAssets: displayTotalAssets,
                  deposit: accountProvider.deposit,
                  profitRate: displayProfitRate,
                  stockCount: displayStocks.length,
                  format: format,
                ),
                const SizedBox(height: 48), // 56 -> 48
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HOLDINGS',
                      style: TextStyle(
                        color: AppTheme.textMain,
                        fontSize: 17, // 18 -> 17
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildCountBadge(displayStocks.length),
                  ],
                ),
                const SizedBox(height: 8), // 12 -> 8
              ],
            ),
          ),
        ),
        _buildStockList(context, displayStocks, format),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 24), // 48 -> 24
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KiwoomDebugScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMain.withValues(alpha: 0.3),
                    side: BorderSide(color: AppTheme.textMain.withValues(alpha: 0.05)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('DEBUG SYSTEM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textMain.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppTheme.textMain,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context, AccountProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textMain.withOpacity(0.05)),
      ),
      child: IconButton(
        onPressed: provider.isRefreshing ? null : () => provider.manualFetchAccounts(),
        icon: provider.isRefreshing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryBlue,
                ),
              )
            : const Icon(
                Icons.refresh_rounded,
                color: AppTheme.textMain,
                size: 22,
              ),
      ),
    );
  }

  Widget _buildStockList(
    BuildContext context,
    List<dynamic> stocks,
    NumberFormat format,
  ) {
    if (stocks.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: AppTheme.textMain.withValues(alpha: 0.1),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '보유 중인 종목이 없습니다.',
                  style: TextStyle(
                    color: AppTheme.textMain.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final stock = stocks[index];
          return StockItemRow(
            stock: stock,
            format: format,
            onTap: () {
              context.read<AnalysisProvider>().selectStock(stock.symbol);
              if (onNavigateToAnalysis != null) {
                onNavigateToAnalysis!();
              }
            },
          );
        }, childCount: stocks.length),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          'API 연동 해제',
          style: TextStyle(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '키움 API 연동을 해제하시겠습니까?\n저장된 App Key와 App Secret이 삭제됩니다.',
          style: TextStyle(color: AppTheme.textMain70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textMain54),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountProvider>().clearApiKeys();
              Navigator.pop(ctx);
            },
            child: const Text(
              '해제',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
