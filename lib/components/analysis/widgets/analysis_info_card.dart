import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../shared/theme.dart';

class AnalysisInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color themeColor;

  const AnalysisInfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.themeColor = AppTheme.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: themeColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: themeColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              h2: const TextStyle(
                color: AppTheme.textMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              h3: const TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              p: const TextStyle(
                color: AppTheme.textMain70,
                fontSize: 15,
                height: 1.6,
              ),
              listBullet: const TextStyle(color: AppTheme.primaryBlue),
              blockquote: const TextStyle(
                color: AppTheme.textMain,
                fontStyle: FontStyle.italic,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              blockquotePadding: const EdgeInsets.all(20),
              blockquoteDecoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              code: TextStyle(
                backgroundColor: AppTheme.textMain.withValues(alpha: 0.05),
                color: AppTheme.accentGreen,
                fontFamily: 'monospace',
              ),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.textMain.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            softLineBreak: true,
          ),
        ),
      ],
    );
  }
}
