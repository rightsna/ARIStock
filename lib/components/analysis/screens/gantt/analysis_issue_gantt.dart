import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analysis_provider.dart';
import '../../models/analysis_model.dart';
import '../../../../shared/theme.dart';
import 'widgets/gantt_sticky_titles.dart';
import 'widgets/gantt_time_axis.dart';
import 'widgets/gantt_row.dart';

class AnalysisIssueGantt extends StatefulWidget {
  final List<InvestmentIssue> issues;
  final Function(InvestmentIssue)? onIssueTap;
  final VoidCallback? onAddRequest;

  const AnalysisIssueGantt({
    super.key,
    required this.issues,
    this.onIssueTap,
    this.onAddRequest,
  });

  @override
  State<AnalysisIssueGantt> createState() => _AnalysisIssueGanttState();
}

class _AnalysisIssueGanttState extends State<AnalysisIssueGantt> {
  late DateTime _startDate;
  late DateTime _endDate;
  late int _totalDays;
  final double _dayWidth = 60.0;
  final double _rowHeight = 85.0;
  final double _titleWidth = 160.0;
  final Set<String> _expandedIssueTitles = {};
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  double _getRowHeight(InvestmentIssue issue) {
    final isAiUpdated = issue.isAiModified || issue.isAiAdded;
    if (_expandedIssueTitles.contains(issue.title) || isAiUpdated) {
      final historyCount = issue.history?.length ?? 0;
      return _rowHeight + (historyCount * 30.0) + 10.0;
    }
    return _rowHeight;
  }

  @override
  void initState() {
    super.initState();
    _calculateRange();
  }

  void _calculateRange() {
    if (widget.issues.isEmpty) {
      _startDate = DateTime.now().subtract(const Duration(days: 7));
      _endDate = DateTime.now();
    } else {
      DateTime minDate = DateTime.now();
      DateTime maxDate = DateTime.now();

      for (var issue in widget.issues) {
        final start = DateTime.parse(issue.startDate);
        if (start.isBefore(minDate)) minDate = start;
        
        if (issue.endDate != null) {
          final end = DateTime.parse(issue.endDate!);
          if (end.isAfter(maxDate)) maxDate = end;
        }
      }
      
      _startDate = minDate.subtract(const Duration(days: 2));
      _endDate = maxDate.add(const Duration(days: 2));
    }
    _totalDays = _endDate.difference(_startDate).inDays + 1;
    if (_totalDays < 14) {
      _totalDays = 14;
      _endDate = _startDate.add(const Duration(days: 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.issues.isEmpty && widget.onAddRequest == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue, 
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '투자 이슈 매니지먼트 보드',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const Spacer(),
              if (widget.onAddRequest != null)
                IconButton(
                  onPressed: widget.onAddRequest,
                  icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primaryBlue),
                  tooltip: '이슈 추가 또는 편집 요청',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
        if (widget.issues.isNotEmpty)
          _buildGanttContainer()
        else
          _buildEmptyPlaceholder(),
      ],
    );
  }

  Widget _buildEmptyPlaceholder() {
    return GestureDetector(
      onTap: widget.onAddRequest,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.textMain10, width: 1.5, style: BorderStyle.none),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_chart_rounded, size: 32, color: AppTheme.textMain24),
            SizedBox(height: 12),
            Text('여기를 눌러 첫 투자 이슈를 생성해 보세요.', style: TextStyle(color: AppTheme.textMain38, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildGanttContainer() {
    final chartWidth = (_totalDays * _dayWidth) + 250.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textMain10, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GanttStickyTitles(
            issues: widget.issues,
            titleWidth: _titleWidth,
            rowHeight: _rowHeight,
            expandedTitles: _expandedIssueTitles,
            onIssueTap: (issue) => widget.onIssueTap?.call(issue),
            getRowHeight: _getRowHeight,
            onToggleExpand: (issue) {
              setState(() {
                if (_expandedIssueTitles.contains(issue.title)) {
                  _expandedIssueTitles.remove(issue.title);
                } else {
                  _expandedIssueTitles.add(issue.title);
                }
              });
            },
            onApprove: (issue) {
              setState(() => _expandedIssueTitles.add(issue.title));
              context.read<AnalysisProvider>().approveIssueUpdate(issue);
            },
            onReject: (issue) => context.read<AnalysisProvider>().rejectIssueUpdate(issue),
            onApproveHistory: (issue, history) {
              setState(() => _expandedIssueTitles.add(issue.title));
              context.read<AnalysisProvider>().approveHistoryUpdate(issue, history);
            },
            onRejectHistory: (issue, history) => context.read<AnalysisProvider>().rejectHistoryUpdate(issue, history),
          ),
          Expanded(
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(4),
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  width: chartWidth,
                  child: Column(
                    children: [
                      GanttTimeAxis(
                        startDate: _startDate,
                        totalDays: _totalDays,
                        dayWidth: _dayWidth,
                      ),
                      ...widget.issues.map((issue) {
                        final isAiUpdated = issue.isAiModified || issue.isAiAdded;
                        return GanttRow(
                          issue: issue,
                          startDate: _startDate,
                          dayWidth: _dayWidth,
                          rowHeight: _rowHeight,
                          totalDays: _totalDays,
                          isExpanded: _expandedIssueTitles.contains(issue.title) || isAiUpdated,
                          onIssueTap: widget.onIssueTap,
                          getRowHeight: _getRowHeight,
                          onApprove: (issue) {
                            setState(() => _expandedIssueTitles.add(issue.title));
                            context.read<AnalysisProvider>().approveIssueUpdate(issue);
                          },
                          onReject: (issue) => context.read<AnalysisProvider>().rejectIssueUpdate(issue),
                          onApproveHistory: (issue, history) {
                            setState(() => _expandedIssueTitles.add(issue.title));
                            context.read<AnalysisProvider>().approveHistoryUpdate(issue, history);
                          },
                          onRejectHistory: (issue, history) => context.read<AnalysisProvider>().rejectHistoryUpdate(issue, history),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
