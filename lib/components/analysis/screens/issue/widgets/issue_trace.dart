import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';
import '../../../models/investment_issue_model.dart';

class IssueTrace extends StatelessWidget {
  final InvestmentIssue issue;
  final Function(IssueHistory) onHistoryDelete;

  const IssueTrace({
    super.key,
    required this.issue,
    required this.onHistoryDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (issue.history == null || issue.history!.isEmpty) {
      return const SizedBox.shrink();
    }

    final reversedHistory = issue.history!.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이슈 트레이스', 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSub),
        ),
        const SizedBox(height: 16),
        ...reversedHistory.asMap().entries.map((entry) {
          final h = entry.value;
          final isLast = entry.key == reversedHistory.length - 1;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 4, 
                      backgroundColor: AppTheme.textMain38,
                    ),
                    if (!isLast) 
                      Container(width: 1, height: 40, color: AppTheme.textMain10),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            h.date, 
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSub),
                          ),
                          GestureDetector(
                            onTap: () => onHistoryDelete(h),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppTheme.textMain24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        h.content, 
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                      ),
                      if (h.detail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          h.detail!, 
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSub, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
