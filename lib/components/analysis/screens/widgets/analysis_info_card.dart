import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../../shared/theme.dart';

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
            Icon(icon, size: 16, color: themeColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: themeColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.textMain10,
              width: 1.5,
            ), // 그림자 대신 실선 테두리
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 좌측 상단 강조선 (노트 스타일)
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  p: const TextStyle(
                    color: AppTheme.textMain70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  listBullet: const TextStyle(color: AppTheme.primaryBlue),
                  blockquotePadding: const EdgeInsets.all(16),
                  blockquoteDecoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(color: themeColor, width: 4),
                    ),
                  ),
                ),
                softLineBreak: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
