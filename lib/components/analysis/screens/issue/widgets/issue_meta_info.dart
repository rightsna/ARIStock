import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';
import '../../../models/investment_issue_model.dart';

class IssueMetaInfo extends StatelessWidget {
  final InvestmentIssue issue;

  const IssueMetaInfo({
    super.key,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildInfoItem(Icons.calendar_today_rounded, '시작일', issue.startDate),
        if (issue.endDate != null) 
          _buildInfoItem(Icons.event_available_rounded, '종료일', issue.endDate!),
        _buildInfoItem(Icons.analytics_rounded, '임팩트', 'Level ${issue.impact}'),
        _buildStatusTag(issue.status),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSub),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textSub)),
        Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.textMain, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'active':
        color = AppTheme.accentGreen;
        label = '실시간 관찰 중';
        break;
      case 'watch':
        color = Colors.orange;
        label = '요주의';
        break;
      case 'monitor':
        color = AppTheme.primaryBlue;
        label = '모니터링';
        break;
      case 'resolved':
      case 'closed':
        color = AppTheme.textSub;
        label = '종료된 이슈';
        break;
      default:
        color = AppTheme.textSub;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
