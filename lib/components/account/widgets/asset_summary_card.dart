import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../../../shared/theme.dart';

class AssetSummaryCard extends StatelessWidget {
  final AccountProvider accountProvider;
  final double totalAssets;
  final double deposit;
  final double profitRate;
  final int stockCount;
  final NumberFormat format;

  const AssetSummaryCard({
    super.key,
    required this.accountProvider,
    required this.totalAssets,
    required this.deposit,
    required this.profitRate,
    required this.stockCount,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 자산 가치',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              _buildRefreshButton(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            format.format(totalAssets),
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSimpleStat(
                '수익률',
                '${profitRate > 0 ? '+' : ''}${profitRate.toStringAsFixed(2)}%',
                valueColor: profitRate > 0
                    ? AppTheme.accentGreen
                    : (profitRate < 0 ? AppTheme.accentRed : Colors.white),
              ),
              const SizedBox(width: 24),
              _buildSimpleStat('예수금', format.format(deposit)),
              const SizedBox(width: 24),
	              _buildSimpleStat('보유 종목', '$stockCount개'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: accountProvider.isRefreshing
          ? null
          : () => accountProvider.manualFetchAccounts(),
      icon: accountProvider.isRefreshing
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
          : const Icon(
              Icons.refresh_rounded,
              color: Colors.white70,
              size: 18,
            ),
      tooltip: '새로고침',
    );
  }

  Widget _buildSimpleStat(String label, String value, {Color valueColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
