import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';
import '../../../models/investment_issue_model.dart';

class IssueHeader extends StatelessWidget {
  final InvestmentIssue issue;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const IssueHeader({
    super.key,
    required this.issue,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          issue.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: issue.isPositive ? AppTheme.accentRed : AppTheme.primaryBlue,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            issue.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSub),
          tooltip: '이슈 삭제',
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          tooltip: '닫기',
        ),
      ],
    );
  }
}
