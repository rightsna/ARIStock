import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';
import '../../../models/investment_issue_model.dart';

class IssueActionButtons extends StatelessWidget {
  final InvestmentIssue issue;
  final VoidCallback onToggleResolved;

  const IssueActionButtons({
    super.key,
    required this.issue,
    required this.onToggleResolved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onToggleResolved,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: issue.isResolved ? AppTheme.textMain54 : AppTheme.accentGreen,
          side: BorderSide(
            color: issue.isResolved ? AppTheme.textMain10 : AppTheme.accentGreen,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          issue.isResolved ? '이슈 재활성화 (Active 전환)' : '이슈 종료 처리 (Resolved 전환)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
