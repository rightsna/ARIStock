import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../../shared/theme.dart';
import '../providers/trading_record_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';

class TradingHistoryScreen extends StatefulWidget {
  const TradingHistoryScreen({super.key});

  @override
  State<TradingHistoryScreen> createState() => _TradingHistoryScreenState();
}

class _TradingHistoryScreenState extends State<TradingHistoryScreen> {
  String? _expandedTaskId;

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
                const Icon(
                  Icons.history,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
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
                  onPressed: () =>
                      context.read<TradingRecordProvider>().refresh(),
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                    color: AppTheme.textSub,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '갱신',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.textMain10),
          _buildTaskBanner(context),
          Expanded(
            child: records.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: AppTheme.textMain10,
                      indent: 16,
                      endIndent: 16,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
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

  Widget _buildTaskBanner(BuildContext context) {
    final taskProvider = context.watch<AriTaskProvider>();
    final stockTasks = taskProvider.tasksForApp('aristock');

    if (stockTasks.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                '예약된 자동매매',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textMain,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${stockTasks.length}개 활성',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stockTasks.map((task) {
            final isExpanded = _expandedTaskId == task.id;
            return Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedTaskId = isExpanded ? null : task.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  task.cronDescription,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppTheme.textSub,
                          ),
                          const SizedBox(width: 8),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: task.enabled,
                              onChanged: (val) =>
                                  taskProvider.toggleTask(task.id),
                              activeColor: AppTheme.primaryBlue,
                              inactiveTrackColor: Colors.grey.withValues(
                                alpha: 0.1,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showDeleteConfirm(
                              context,
                              taskProvider,
                              task.id,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: Colors.red.withValues(alpha: 0.6),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            tooltip: '삭제',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8, top: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.textMain.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.prompt,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMain54,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    AriTaskProvider provider,
    String taskId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('태스크 삭제'),
        content: const Text('이 자동매매 태스크를 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppTheme.textSub)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(taskId);
              Navigator.pop(context);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
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
              context.read<AriChatProvider>().sendAgentMessage(
                '매매전략대로 자동매매 해줘',
                appId: 'aristock',
                platform: 'aristock',
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
