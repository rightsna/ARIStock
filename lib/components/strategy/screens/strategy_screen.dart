import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/strategy_provider.dart';
import '../../../shared/theme.dart';

/// 매매전략 화면: 종목별 AI 매매전략과 매매 로그를 마크다운 및 리스트 형식으로 보여줍니다.
class StrategyScreen extends StatelessWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StrategyProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockSelector(context, provider),
                  const SizedBox(height: 32),
                  if (provider.selectedStrategy != null) ...[
                    _buildStrategyHeader(context, provider),
                    const SizedBox(height: 24),
                    _buildMarkdownContent(context, provider.selectedStrategy!.content),
                    const SizedBox(height: 32),
                    _buildTradingLog(context, provider),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('설정된 매매 전략이 없습니다.', style: TextStyle(color: Colors.white54)),
                      ),
                    ),
                  const SizedBox(height: 40),
                  _buildResetButton(context, provider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStockSelector(BuildContext context, StrategyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('보유 종목 전략', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: provider.strategies.map((strategy) {
              final isSelected = provider.selectedStrategy?.symbol == strategy.symbol;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(strategy.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) provider.selectStrategy(strategy.symbol);
                  },
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyHeader(BuildContext context, StrategyProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${provider.selectedStrategy!.name} 매매 전략',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('AI 대규모 언어 모델 기반 실시간 전략 가이드',
                style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String content) {
    final markdownStyle = MarkdownStyleSheet(
      h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      h3: const TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
      p: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
      listBullet: const TextStyle(color: AppTheme.primaryBlue),
      blockquote: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      blockquotePadding: const EdgeInsets.all(20),
      blockquoteDecoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      tableBorder: TableBorder.all(color: Colors.white10, width: 0.5),
      tableBody: const TextStyle(color: Colors.white70),
      tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );

    return MarkdownBody(
      data: content,
      styleSheet: markdownStyle,
    );
  }

  Widget _buildTradingLog(BuildContext context, StrategyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 매매 로그',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('전체보기', style: TextStyle(color: AppTheme.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.tradingLogs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('매매 로그가 없습니다.', style: TextStyle(color: Colors.white38))),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.tradingLogs.length,
              separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              itemBuilder: (context, index) {
                final log = provider.tradingLogs[index];
                final isBuy = log.type == '매수';
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isBuy ? AppTheme.accentRed : AppTheme.primaryBlue).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              log.type,
                              style: TextStyle(
                                color: isBuy ? AppTheme.accentRed : AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.date, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('${log.price} | ${log.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Text(
                            log.status,
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                      if (log.aiReason != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.psychology, size: 14, color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  log.aiReason!,
                                  style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context, StrategyProvider provider) {
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
