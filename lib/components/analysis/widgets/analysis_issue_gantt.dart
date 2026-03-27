import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analysis_model.dart';
import '../../../shared/theme.dart';

class AnalysisIssueGantt extends StatefulWidget {
  final List<InvestmentIssue> issues;
  final Function(InvestmentIssue)? onIssueTap;
  final VoidCallback? onAddRequest; // 새 이슈 추가/수정 요청 콜백

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
  final double _rowHeight = 70.0;
  final double _titleWidth = 150.0;
  final Set<String> _expandedIssueTitles = {};

  double _getRowHeight(InvestmentIssue issue) {
    if (_expandedIssueTitles.contains(issue.title)) {
      final historyCount = issue.history?.length ?? 0;
      return _rowHeight + (historyCount * 45.0) + 10.0;
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
                decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text(
                '투자 이슈 매니지먼트 보드',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const Spacer(),
              // 이슈 추가/수정 요청 버튼 (+)
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
          border: Border.all(color: AppTheme.textMain10, width: 1.5, style: BorderStyle.none), // 점선 지원이 안되므로 간단히 처리
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
    // 텍스트 라벨들을 위한 충분한 여유 공간(250px) 확보
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
          _buildStickyTitles(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                width: chartWidth,
                child: Column(
                  children: [
                    _buildTimeAxis(),
                    ...widget.issues.map((issue) => _buildGanttRow(issue)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyTitles() {
    return Container(
      width: _titleWidth,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(right: BorderSide(color: AppTheme.textMain10, width: 1.5)),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.textMain10, width: 1.5)),
            ),
            child: const Text('INVESTMENT ISSUE', style: TextStyle(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: AppTheme.textSub)),
          ),
          ...widget.issues.map((issue) {
            final isExpanded = _expandedIssueTitles.contains(issue.title);
            return GestureDetector(
              onTap: () => widget.onIssueTap?.call(issue),
              child: Container(
                width: _titleWidth,
                height: _getRowHeight(issue),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.5))),
                  color: issue.isResolved ? Colors.grey.withValues(alpha: 0.03) : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            issue.isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 14,
                            color: issue.isPositive ? AppTheme.accentRed : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: issue.isResolved ? AppTheme.textMain38 : AppTheme.textMain,
                                  decoration: issue.isResolved ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildImpactBadge(issue.impact),
                            ],
                          ),
                        ),
                        // 토글 버튼
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedIssueTitles.remove(issue.title);
                              } else {
                                _expandedIssueTitles.add(issue.title);
                              }
                            });
                          },
                          icon: Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppTheme.textSub,
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded && issue.history != null) ...[
                      const SizedBox(height: 12),
                      ...issue.history!.reversed.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.date.substring(5), // MM-DD
                              style: const TextStyle(fontSize: 9, color: AppTheme.textSub, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              h.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMain),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImpactBadge(int impact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.textMain10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate( impact, (index) => const Icon(
          Icons.star,
          size: 8,
          color: Colors.orange,
        )),
      ),
    );
  }

  Widget _buildTimeAxis() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(bottom: BorderSide(color: AppTheme.textMain10, width: 1.5)),
      ),
      child: Stack(
        children: List.generate(_totalDays, (index) {
          final date = _startDate.add(Duration(days: index));
          final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
          
          return Positioned(
            left: index * _dayWidth,
            top: 0, bottom: 0, width: _dayWidth,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.5))),
                color: isToday ? AppTheme.primaryBlue.withValues(alpha: 0.03) : null,
              ),
              child: Text(
                DateFormat('MM/dd').format(date),
                style: TextStyle(fontSize: 10, color: isToday ? AppTheme.primaryBlue : AppTheme.textSub, fontWeight: isToday ? FontWeight.bold : FontWeight.w500),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGanttRow(InvestmentIssue issue) {
    final start = DateTime.parse(issue.startDate);
    final end = issue.endDate != null ? DateTime.parse(issue.endDate!) : DateTime.now();
    
    final startOffset = start.difference(_startDate).inDays * _dayWidth;
    final durationWidth = (end.difference(start).inDays + 1) * _dayWidth;
    
    Color color = issue.isPositive ? AppTheme.accentRed : AppTheme.primaryBlue;
    if (issue.isResolved) color = AppTheme.accentGreen;
    if (issue.status == 'evolving') color = Colors.orange;

    final isExpanded = _expandedIssueTitles.contains(issue.title);

    return GestureDetector(
      onTap: () => widget.onIssueTap?.call(issue),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _getRowHeight(issue),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppTheme.textMain10.withValues(alpha: 0.3))),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(_totalDays, (index) => Positioned(
              left: index * _dayWidth,
              top: 0, bottom: 0, width: 0.5,
              child: Container(color: AppTheme.textMain10.withValues(alpha: 0.3)),
            )),
            
            Positioned(
              left: startOffset + 4,
              top: 25,
              width: durationWidth - 8,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1.5),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    if (issue.isPositive) 
                      Icon(Icons.add_circle_outline, size: 10, color: color)
                    else 
                      Icon(Icons.remove_circle_outline, size: 10, color: color),
                    const SizedBox(width: 4),
                    if (issue.status == 'evolving') Icon(Icons.auto_fix_high, size: 10, color: color),
                  ],
                ),
              ),
            ),
          
            if (issue.history != null) 
              ...issue.history!.asMap().entries.map((entry) {
                final h = entry.value;
                final hDate = DateTime.parse(h.date);
                final hOffset = hDate.difference(_startDate).inDays * _dayWidth + (_dayWidth / 2);
                
                // 히스토리 목록의 인덱스 계산 (reversed 기준)
                final historyList = issue.history!.reversed.toList();
                final visibleIndex = historyList.indexOf(h);

                return Stack(
                  children: [
                    // 상단 포인트
                    Positioned(
                      left: hOffset - 3,
                      top: 32,
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 1.5),
                        ),
                      ),
                    ),
                    // 확장 모드에서 날짜칸에 수직선 및 텍스트 표시
                    if (isExpanded && visibleIndex != -1) ...[
                      // 수직 연결선
                      Positioned(
                        left: hOffset - 0.5,
                        top: 38,
                        height: _rowHeight - 38 + (visibleIndex * 45.0) + 15.0,
                        width: 1,
                        child: Container(color: color.withValues(alpha: 0.2)),
                      ),
                      // 텍스트 내용
                      Positioned(
                        left: hOffset + 6,
                        top: _rowHeight + (visibleIndex * 45.0) + 15.0,
                        width: 200,
                        child: Text(
                          h.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.normal),
                        ),
                      ),
                    ],
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
