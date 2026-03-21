import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/briefing_provider.dart';
import '../../../shared/theme.dart';

/// 브리핑 화면: Hive DB에서 마크다운 형식의 투자 보고서를 불러와 보여줍니다.
class BriefingScreen extends StatelessWidget {
  const BriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final briefingProvider = context.watch<BriefingProvider>();

    return Scaffold(
      body: briefingProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : briefingProvider.currentBriefing == null
              ? const Center(child: Text('오늘의 브리핑 데이터가 없습니다.', style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportHeader(context, briefingProvider.currentBriefing!.date),
                      const SizedBox(height: 16),
                      _buildMarkdownContent(context, briefingProvider.currentBriefing!.content),
                      const SizedBox(height: 40),
                      _buildReportFooter(context),
                      const SizedBox(height: 32),
                      _buildResetButton(context, briefingProvider),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReportHeader(BuildContext context, String date) {
    // date: YYYY-MM-DD -> YYYY. MM. DD
    final parts = date.split('-');
    final dateStr = parts.length == 3 ? '${parts[0]}. ${parts[1]}. ${parts[2]}' : date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'DAILY REPORT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '오늘의 투자 브리핑',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '발행일자: $dateStr | 분석 에이전트: ARI',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
      ],
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String content) {
    // 테마에 맞춘 마크다운 스타일 설정
    final markdownStyle = MarkdownStyleSheet(
      h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      h3: const TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold),
      p: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
      listBullet: const TextStyle(color: AppTheme.primaryBlue),
      blockquote: const TextStyle(color: Colors.white60, fontStyle: FontStyle.italic),
      blockquoteDecoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: AppTheme.primaryBlue, width: 4)),
      ),
      code: TextStyle(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        color: AppTheme.accentGreen,
        fontFamily: 'monospace',
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      tableBorder: TableBorder.all(color: Colors.white10, width: 0.5),
      tableBody: const TextStyle(color: Colors.white70),
      tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );

    return MarkdownBody(
      data: content,
      styleSheet: markdownStyle,
      softLineBreak: true,
    );
  }

  Widget _buildReportFooter(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Divider(color: Colors.white10),
          SizedBox(height: 16),
          Text(
            'ARI AI Investment Management System',
            style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1),
          ),
          SizedBox(height: 8),
          Text(
            '본 보고서는 AI 분석 결과로 최종 투자 결정은 사용자에게 있습니다.',
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, BriefingProvider provider) {
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
