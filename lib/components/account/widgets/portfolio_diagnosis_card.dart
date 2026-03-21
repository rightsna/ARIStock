import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/portfolio_report_model.dart';
import '../providers/account_provider.dart';
import '../../../shared/theme.dart';

class PortfolioDiagnosisCard extends StatelessWidget {
  final AccountProvider accountProvider;
  final PortfolioReport report;

  const PortfolioDiagnosisCard({
    super.key,
    required this.accountProvider,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.psychology_outlined, color: AppTheme.primaryBlue, size: 22),
            SizedBox(width: 8),
            Text(
              'AI 포트폴리오 진단',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 12, color: Colors.white38),
                  const SizedBox(width: 6),
                  Text(
                    '진단 일시: ${report.date}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MarkdownBody(
                data: report.content,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  h2: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  h3: const TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold),
                  p: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                  listBullet: const TextStyle(color: AppTheme.primaryBlue),
                  blockquote: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                  blockquotePadding: const EdgeInsets.all(16),
                  blockquoteDecoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(left: BorderSide(color: AppTheme.primaryBlue, width: 4)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildResetButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _showResetDialog(context),
        icon: const Icon(Icons.refresh_outlined, size: 14, color: Colors.white38),
        label: const Text('진단 데이터 삭제', style: TextStyle(color: Colors.white38, fontSize: 12)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('진단 결과 초기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('저장된 AI 포트폴리오 진단 결과를 삭제하시겠습니까?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              accountProvider.clearReport(); 
              Navigator.pop(ctx);
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}
