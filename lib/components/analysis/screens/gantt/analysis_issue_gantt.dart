import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/investment_issue_model.dart';
import '../../providers/analysis_provider.dart';
import '../../../../shared/theme.dart';
import 'widgets/gantt_empty_placeholder.dart';
import 'widgets/gantt_chart_container.dart';
import '../issue/issue_detail_sheet.dart';
import '../issue/add_issue_request_dialog.dart';

class AnalysisIssueGantt extends StatefulWidget {
  final String symbol;
  final List<InvestmentIssue> issues;

  const AnalysisIssueGantt({
    super.key,
    required this.symbol,
    required this.issues,
  });

  @override
  State<AnalysisIssueGantt> createState() => _AnalysisIssueGanttState();
}

class _AnalysisIssueGanttState extends State<AnalysisIssueGantt> {
  late DateTime _startDate;
  late DateTime _endDate;
  late int _totalDays;
  bool _hideResolved = false;
  bool _sortByImpact = false;
  final double _dayWidth = 60.0;
  final double _rowHeight = 85.0;
  final double _titleWidth = 160.0;

  @override
  void initState() {
    super.initState();
    _calculateRange();
  }

  @override
  void didUpdateWidget(covariant AnalysisIssueGantt oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 이슈 상태 변화(컬러 등)를 즉시 반영하기 위해 항상 recalculate를 수행합니다.
    setState(() {
      _calculateRange();
    });
  }

  void _calculateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (widget.issues.isEmpty) {
      _startDate = today.subtract(const Duration(days: 7));
      _endDate = today.add(const Duration(days: 7));
    } else {
      DateTime minDate = today;
      DateTime maxDate = today;

      for (var issue in widget.issues) {
        final issueStart = DateTime.parse(issue.startDate);
        final start = DateTime(
          issueStart.year,
          issueStart.month,
          issueStart.day,
        );

        if (start.isBefore(minDate)) minDate = start;
        if (start.isAfter(maxDate)) maxDate = start;

        if (issue.endDate != null) {
          final issueEnd = DateTime.parse(issue.endDate!);
          final end = DateTime(issueEnd.year, issueEnd.month, issueEnd.day);
          if (end.isAfter(maxDate)) maxDate = end;
          if (end.isBefore(minDate)) minDate = end;
        }

        if (issue.history != null) {
          for (var h in issue.history!) {
            final hDateRaw = DateTime.parse(h.date);
            final hDate = DateTime(hDateRaw.year, hDateRaw.month, hDateRaw.day);
            if (hDate.isBefore(minDate)) minDate = hDate;
            if (hDate.isAfter(maxDate)) maxDate = hDate;
          }
        }
      }

      _startDate = minDate.subtract(const Duration(days: 3));
      _endDate = maxDate.add(const Duration(days: 7));
    }

    _totalDays = _endDate.difference(_startDate).inDays + 1;
    if (_totalDays < 20) {
      _totalDays = 20;
      _endDate = _startDate.add(const Duration(days: 20));
    }
  }

  void _showDetails(InvestmentIssue issue) {
    // 기본 동작: 이슈 상세 시트 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IssueDetailSheet(
        symbol: widget.symbol,
        issue: issue,
        provider: context.read<AnalysisProvider>(),
      ),
    );
  }

  void _showAddRequest() {
    // 기본 동작: 이슈 추가 요청 다이얼로그 표시
    showDialog(
      context: context,
      builder: (ctx) => AddIssueRequestDialog(symbol: widget.symbol),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<InvestmentIssue> visibleIssues = _hideResolved
        ? widget.issues.where((i) => !i.isResolved).toList()
        : List.from(widget.issues);

    if (_sortByImpact) {
      visibleIssues.sort((a, b) => b.impact.compareTo(a.impact));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '투자 이슈 매니지먼트 보드',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
              const Spacer(),
              if (widget.issues.isNotEmpty) ...[
                IconButton(
                  onPressed: () =>
                      setState(() => _sortByImpact = !_sortByImpact),
                  icon: Icon(
                    _sortByImpact ? Icons.sort : Icons.sort_outlined,
                    size: 18,
                    color: _sortByImpact
                        ? AppTheme.primaryBlue
                        : AppTheme.textSub,
                  ),
                  tooltip: _sortByImpact ? '원래 순서로 보기' : '중요도 순으로 정렬',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () =>
                      setState(() => _hideResolved = !_hideResolved),
                  icon: Icon(
                    _hideResolved
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: _hideResolved
                        ? AppTheme.primaryBlue
                        : AppTheme.textSub,
                  ),
                  tooltip: _hideResolved ? '해결된 이슈 숨김 중' : '해결된 이슈 표시 중',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              IconButton(
                onPressed: _showAddRequest,
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
                tooltip: '이슈 추가 또는 편집 요청',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        if (widget.issues.isNotEmpty)
          GanttChartContainer(
            issues: visibleIssues,
            startDate: _startDate,
            totalDays: _totalDays,
            dayWidth: _dayWidth,
            titleWidth: _titleWidth,
            rowHeight: _rowHeight,
            onIssueTap: _showDetails,
          )
        else
          GanttEmptyPlaceholder(onAddRequest: _showAddRequest),
      ],
    );
  }
}
