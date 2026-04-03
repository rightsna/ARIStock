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
    final double profit = stock.profitPercentage;
    final bool isPositive = profit >= 0;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: AppTheme.primaryBlue.withOpacity(0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16), // 20 -> 16
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.textMain.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          children: [
            _buildIcon(stock.name),
            const SizedBox(width: 16),
            _buildStockInfo(),
            _buildPriceInfo(profit, isPositive),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String name) {
    final String initial = name.isNotEmpty ? name[0] : '?';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.textMain.withValues(alpha: 0.03),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppTheme.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
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
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${stock.quantity.toInt()} SHARES  ·  ${format.format(stock.purchasePrice).replaceAll('₩', '').trim()}',
            style: TextStyle(
              color: AppTheme.textSub.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(double profit, bool isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          format.format(stock.totalCurrentAmount).replaceAll('₩', '').trim(),
          style: const TextStyle(
            color: AppTheme.textMain,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${isPositive ? '▲' : '▼'} ${profit.abs().toStringAsFixed(2)}%',
          style: TextStyle(
            color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
