import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../../../shared/theme.dart';

/// 앱의 메인 대시보드 화면입니다.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ARIStock Portfolio', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            // 상단 요약 카드
            Row(
              children: [
                _buildSummaryCard(
                  context,
                  '총 자산',
                  currencyFormat.format(portfolio.totalAssets),
                  '수익률: ${portfolio.totalProfitPercentage.toStringAsFixed(2)}%',
                  portfolio.totalProfitPercentage >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('보유 종목', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // 종목 리스트
            Expanded(
              child: portfolio.stocks.isEmpty
                  ? const Center(
                      child: Text('보유 종목이 없습니다.', style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.builder(
                      itemCount: portfolio.stocks.length,
                      itemBuilder: (context, index) {
                        final stock = portfolio.stocks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(stock.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${stock.symbol} • ${stock.quantity} 주'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currencyFormat.format(stock.totalCurrentAmount),
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${stock.profitPercentage >= 0 ? '+' : ''}${stock.profitPercentage.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: stock.profitPercentage >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            _buildResetButton(context, portfolio),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 종목 추가 팝업 구현
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, String subtitle, Color subtitleColor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, PortfolioProvider provider) {
    return Center(
      child: TextButton.icon(
        onPressed: () => provider.clearAll(),
        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
        label: const Text('데이터 초기화', style: TextStyle(color: Colors.white38, fontSize: 12)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
