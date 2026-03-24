import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/consultation_provider.dart';
import '../../../shared/theme.dart';

/// 종목상담 화면: AI 애널리스트가 생성한 마크다운 리포트를 렌더링합니다.
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsultationProvider>();

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchHeader(context, provider),
                  const SizedBox(height: 24),
                  if (provider.currentStockLogs.length > 1) ...[
                    _buildDateHistory(context, provider),
                    const SizedBox(height: 24),
                  ],
                  if (provider.selectedLog != null) ...[
                    _buildStockHeader(context, provider),
                    const SizedBox(height: 16),
                    _buildMarkdownContent(context, provider.selectedLog!.content),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('상담 내역이 없습니다.', style: TextStyle(color: Colors.white54)),
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

  Widget _buildDateHistory(BuildContext context, ConsultationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('상담 이력 (날짜별)', style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.currentStockLogs.length,
            itemBuilder: (context, index) {
              final log = provider.currentStockLogs[index];
              final isSelected = provider.selectedLog == log;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => provider.selectLog(log),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white10),
                    ),
                    child: Text(
                      log.date,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryBlue : Colors.white54,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(BuildContext context, ConsultationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history, size: 16, color: Colors.white54),
            SizedBox(width: 8),
            Text('상담 히스토리', style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: provider.stocks.map((stock) {
              final isSelected = provider.selectedLog?.stockSymbol == stock.symbol;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(stock.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) provider.selectStock(stock.symbol);
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

  Widget _buildStockHeader(BuildContext context, ConsultationProvider provider) {
    final stock = provider.stocks.firstWhere((s) => s.symbol == provider.selectedLog!.stockSymbol);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stock.name} 종목 상담',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('상담일자: ${provider.selectedLog!.date} | AI 애널리스트: ARI',
                style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.analytics, color: AppTheme.primaryBlue),
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
      blockquote: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 18, fontWeight: FontWeight.bold),
      blockquotePadding: const EdgeInsets.all(20),
      blockquoteDecoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      code: TextStyle(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        color: AppTheme.accentGreen,
        fontFamily: 'monospace',
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
    );

    return MarkdownBody(
      data: content,
      styleSheet: markdownStyle,
      softLineBreak: true,
    );
  }

  Widget _buildResetButton(BuildContext context, ConsultationProvider provider) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showResetConfirmDialog(context, provider),
        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
        label: const Text('데이터 초기화', style: TextStyle(color: Colors.white38, fontSize: 12)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, ConsultationProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('상담 데이터 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '모든 종목 상담 내역과 히스토리가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('초기화', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}
