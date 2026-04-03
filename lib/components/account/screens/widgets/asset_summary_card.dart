import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../../../shared/theme.dart';

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
    final bool isPositive = profitRate >= 0;
    final String currencySymbol = 'KRW';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Balance',
          style: TextStyle(
            color: AppTheme.textSub.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4), // 8 -> 4
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              format.format(totalAssets).replaceAll('₩', '').trim(),
              style: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              currencySymbol,
              style: TextStyle(
                color: AppTheme.textMain.withValues(alpha: 0.4),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // 32 -> 20
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16), // 20 -> 16
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: AppTheme.textMain.withValues(alpha: 0.05)),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'PROFIT',
                    '${isPositive ? '+' : ''}${profitRate.toStringAsFixed(2)}%',
                    valueColor: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildStatItem(
                    'DEPOSIT',
                    format.format(deposit).replaceAll('₩', '').trim(),
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildStatItem('HOLDINGS', '$stockCount'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 20,
      color: AppTheme.textMain.withValues(alpha: 0.05),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSub.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textMain,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
