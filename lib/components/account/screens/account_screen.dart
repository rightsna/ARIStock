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

/// 계좌 화면: API 연동 상태에 따라 설정 화면 또는 포트폴리오 메인 화면을 표시합니다.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    // API 키 연동 상태만 확인 (수동 입력 기능 제거)
    final bool hasData = accountProvider.hasApiKeys;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
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
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '나의 계좌',
                      style: TextStyle(
                        color: AppTheme.textMain,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: accountProvider.isRefreshing
                          ? null
                          : () => accountProvider.manualFetchAccounts(),
                      icon: accountProvider.isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryBlue,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: AppTheme.textMain54,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ApiStatusBar(
                  accountProvider: accountProvider,
                  onDisconnect: _showDisconnectDialog,
                ),
                const SizedBox(height: 24),
                AssetSummaryCard(
                  accountProvider: accountProvider,
                  totalAssets: displayTotalAssets,
                  deposit: accountProvider.deposit,
                  profitRate: displayProfitRate,
                  stockCount: displayStocks.length,
                  format: format,
                ),
                const SizedBox(height: 32),
                const Text(
                  '보유 종목 내역',
                  style: TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildStockList(context, displayStocks, format),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
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
              DefaultTabController.of(context).animateTo(0);
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
