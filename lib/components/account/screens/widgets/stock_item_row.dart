import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/theme.dart';

class StockItemRow extends StatelessWidget {
  final dynamic stock;
  final NumberFormat format;
  final VoidCallback? onTap;

  const StockItemRow({
    super.key,
    required this.stock,
    required this.format,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.textMain.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 16),
            _buildStockInfo(),
            _buildPriceInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.show_chart_rounded, color: AppTheme.primaryBlue),
    );
  }

  Widget _buildStockInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock.name,
            style: const TextStyle(
              color: AppTheme.textMain,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${stock.quantity.toInt()}주  ·  평단 ${format.format(stock.purchasePrice)}',
            style: TextStyle(
              color: AppTheme.textMain.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    final profit = stock.profitPercentage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          format.format(stock.totalCurrentAmount),
          style: const TextStyle(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${profit > 0 ? '+' : ''}${profit.toStringAsFixed(2)}%',
          style: TextStyle(
            color: profit > 0
                ? AppTheme.accentGreen
                : (profit < 0 ? AppTheme.accentRed : AppTheme.textMain54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
