import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../../shared/theme.dart';
import '../providers/trading_record_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';

class TradingHistoryScreen extends StatelessWidget {
  const TradingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final selectedStock = watchlistProvider.selectedStock;

    if (selectedStock == null) {
      return const Center(child: Text('종목을 선택해주세요.'));
    }

    final recordProvider = context.watch<TradingRecordProvider>();
    final records = recordProvider.getRecordsForSymbol(selectedStock.symbol);

    return Container(
      color: AppTheme.surfaceWhite,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${selectedStock.name} 매매기록',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textMain,
                  ),
                ),
                const Spacer(),
                Text(
                  '총 ${records.length}건',
                  style: const TextStyle(color: AppTheme.textSub, fontSize: 13),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.read<TradingRecordProvider>().refresh(),
                  icon: const Icon(Icons.refresh, size: 18, color: AppTheme.textSub),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '갱신',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.textMain10),
          Expanded(
            child: records.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: records.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.textMain10, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isBuy = record.side.toUpperCase() == 'BUY';
                      final priceStr = record.price > 0
                          ? '${record.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원'
                          : '시장가';
                      final qtyStr = record.quantity == record.quantity.toInt()
                          ? '${record.quantity.toInt()}주'
                          : '${record.quantity}주';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(
                                color: isBuy
                                    ? Colors.red.withValues(alpha: 0.08)
                                    : Colors.blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isBuy ? '매수' : '매도',
                                style: TextStyle(
                                  color: isBuy ? Colors.red : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              record.date,
                              style: const TextStyle(
                                color: AppTheme.textSub,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (record.reason.isNotEmpty)
                              Expanded(
                                child: Text(
                                  record.reason,
                                  style: const TextStyle(
                                    color: AppTheme.textMain54,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            else
                              const Spacer(),
                            const SizedBox(width: 8),
                            Text(
                              '$priceStr · $qtyStr',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textMain,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppTheme.textSub.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            '등록된 매매기록이 없습니다.',
            style: TextStyle(color: AppTheme.textSub),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              AriAgent.report(
                appId: 'aristock',
                type: 'CHAT_MESSAGE',
                message: '매매전략대로 자동매매 해줘',
              );
            },
            icon: const Icon(Icons.bolt, size: 14),
            label: const Text(
              '자동매매 요청',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              foregroundColor: AppTheme.primaryBlue,
              side: const BorderSide(color: AppTheme.primaryBlue, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
