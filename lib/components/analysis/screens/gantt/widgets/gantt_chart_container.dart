import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/analysis_model.dart';
import '../../../providers/analysis_provider.dart';
import '../../../../../shared/theme.dart';
import 'gantt_sticky_titles.dart';
import 'gantt_time_axis.dart';
import 'gantt_row.dart';

class GanttChartContainer extends StatefulWidget {
  final List<InvestmentIssue> issues;
  final DateTime startDate;
  final int totalDays;
  final double dayWidth;
  final double titleWidth;
  final double rowHeight;
  final Function(InvestmentIssue)? onIssueTap;

  const GanttChartContainer({
    super.key,
    required this.issues,
    required this.startDate,
    required this.totalDays,
    required this.dayWidth,
    required this.titleWidth,
    required this.rowHeight,
    this.onIssueTap,
  });

  @override
  State<GanttChartContainer> createState() => _GanttChartContainerState();
}

class _GanttChartContainerState extends State<GanttChartContainer> {
  final Set<String> _expandedIssueIds = {};
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  double get _chartWidth => (widget.totalDays * widget.dayWidth) + 250.0;

  double _getRowHeight(InvestmentIssue issue) {
    final isAiUpdated = issue.isAiModified || issue.isAiAdded;
    if (_expandedIssueIds.contains(issue.id) || isAiUpdated) {
      final historyCount = issue.history?.length ?? 0;
      return widget.rowHeight + (historyCount * 30.0) + 10.0;
    }
    return widget.rowHeight;
  }

  void _onToggleExpand(String id) {
    setState(() {
      if (_expandedIssueIds.contains(id)) {
        _expandedIssueIds.remove(id);
      } else {
        _expandedIssueIds.add(id);
      }
    });
  }

  void _handleApprove(BuildContext context, InvestmentIssue issue) {
    setState(() => _expandedIssueIds.add(issue.id));
    context.read<AnalysisProvider>().approveIssueUpdate(issue);
  }

  void _handleReject(BuildContext context, InvestmentIssue issue) {
    context.read<AnalysisProvider>().rejectIssueUpdate(issue);
  }

  void _handleApproveHistory(BuildContext context, InvestmentIssue issue, IssueHistory history) {
    setState(() => _expandedIssueIds.add(issue.id));
    context.read<AnalysisProvider>().approveHistoryUpdate(issue, history);
  }

  void _handleRejectHistory(BuildContext context, InvestmentIssue issue, IssueHistory history) {
    context.read<AnalysisProvider>().rejectHistoryUpdate(issue, history);
  }

  @override
  Widget build(BuildContext context) {
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
          _buildStickyTitles(context),
          _buildScrollableArea(context),
        ],
      ),
    );
  }

  Widget _buildStickyTitles(BuildContext context) {
    return GanttStickyTitles(
      issues: widget.issues,
      titleWidth: widget.titleWidth,
      rowHeight: widget.rowHeight,
      expandedTitles: _expandedIssueIds,
      onIssueTap: (issue) => widget.onIssueTap?.call(issue),
      getRowHeight: _getRowHeight,
      onToggleExpand: (issue) => _onToggleExpand(issue.id),
      onApprove: (issue) => _handleApprove(context, issue),
      onReject: (issue) => _handleReject(context, issue),
      onApproveHistory: (issue, history) => _handleApproveHistory(context, issue, history),
      onRejectHistory: (issue, history) => _handleRejectHistory(context, issue, history),
    );
  }

  Widget _buildScrollableArea(BuildContext context) {
    return Expanded(
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
            width: _chartWidth,
            child: Column(
              children: [
                GanttTimeAxis(
                  startDate: widget.startDate,
                  totalDays: widget.totalDays,
                  dayWidth: widget.dayWidth,
                ),
                ...widget.issues.map((issue) {
                  final isAiUpdated = issue.isAiModified || issue.isAiAdded;
                  return GanttRow(
                    issue: issue,
                    startDate: widget.startDate,
                    dayWidth: widget.dayWidth,
                    rowHeight: widget.rowHeight,
                    totalDays: widget.totalDays,
                    isExpanded: _expandedIssueIds.contains(issue.id) || isAiUpdated,
                    onIssueTap: widget.onIssueTap,
                    getRowHeight: _getRowHeight,
                    onApprove: (issue) => _handleApprove(context, issue),
                    onReject: (issue) => _handleReject(context, issue),
                    onApproveHistory: (issue, history) => _handleApproveHistory(context, issue, history),
                    onRejectHistory: (issue, history) => _handleRejectHistory(context, issue, history),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
