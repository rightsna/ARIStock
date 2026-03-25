import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/analysis_model.dart';
import '../../../../shared/theme.dart';

class AnalysisCheckPointCard extends StatelessWidget {
  final List<AnalysisCheckPoint> checkPoints;
  final Function(AnalysisCheckPoint) onToggle;
  final Function(AnalysisCheckPoint)? onInvestigate;

  const AnalysisCheckPointCard({
    super.key,
    required this.checkPoints,
    required this.onToggle,
    this.onInvestigate,
  });

  @override
  Widget build(BuildContext context) {
    if (checkPoints.isEmpty) return const SizedBox.shrink();

    final positives = checkPoints.where((p) => p.isPositive).toList();
    final negatives = checkPoints.where((p) => !p.isPositive).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (positives.isNotEmpty)
          Expanded(
            child: _buildCheckPointGroup(
              '상승 관점',
              positives,
              Icons.trending_up,
              AppTheme.accentGreen,
            ),
          ),
        if (positives.isNotEmpty && negatives.isNotEmpty)
          const SizedBox(width: 16),
        if (negatives.isNotEmpty)
          Expanded(
            child: _buildCheckPointGroup(
              '하락 관점',
              negatives,
              Icons.trending_down,
              AppTheme.accentRed,
            ),
          ),
      ],
    );
  }

  Widget _buildCheckPointGroup(
    String title,
    List<AnalysisCheckPoint> points,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...points.map((p) => _CheckPointItem(
              point: p,
              color: color,
              onToggle: () => onToggle(p),
              onInvestigate: onInvestigate != null ? () => onInvestigate!(p) : null,
            )),
      ],
    );
  }
}

class _CheckPointItem extends StatefulWidget {
  final AnalysisCheckPoint point;
  final Color color;
  final VoidCallback onToggle;
  final VoidCallback? onInvestigate;

  const _CheckPointItem({
    required this.point,
    required this.color,
    required this.onToggle,
    this.onInvestigate,
  });

  @override
  State<_CheckPointItem> createState() => _CheckPointItemState();
}

class _CheckPointItemState extends State<_CheckPointItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.point;
    final color = widget.color;
    final hasInvestigation = p.investigationResult != null && p.investigationResult!.isNotEmpty;
    final hasQuestions = p.relatedQuestions != null && p.relatedQuestions!.isNotEmpty;
    const hasContent = true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.1),
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: _isExpanded ? 0.08 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasContent ? () => setState(() => _isExpanded = !_isExpanded) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: p.isChecked,
                          onChanged: (_) => widget.onToggle(),
                          activeColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.content,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMain,
                            fontWeight: _isExpanded ? FontWeight.bold : FontWeight.normal,
                            decoration: p.isChecked ? TextDecoration.lineThrough : null,
                            decorationColor: AppTheme.textMain38,
                          ),
                        ),
                      ),
                      if (hasContent)
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppTheme.textMain38,
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Row(
                      children: [
                        ...List.generate(5, (index) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            index < p.impactValue ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 10,
                            color: index < p.impactValue ? Colors.orange : AppTheme.textMain10,
                          ),
                        )),
                        const SizedBox(width: 8),
                        if (p.status != 'pending')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: _getStatusColor(p.status ?? '').withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusLabel(p.status ?? ''),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(p.status ?? ''),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  if (hasInvestigation) ...[
                    Row(
                      children: [
                        const Icon(Icons.manage_search, size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 6),
                        const Text('심화 조사 결과', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        const Spacer(),
                        if (widget.onInvestigate != null)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 14, color: AppTheme.textSub),
                            onPressed: widget.onInvestigate,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: p.investigationResult!,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 12, color: AppTheme.textMain, height: 1.5),
                        code: const TextStyle(backgroundColor: AppTheme.backgroundLight, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (hasQuestions) ...[
                    const Row(
                      children: [
                        Icon(Icons.help_outline, size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Text('함께 브레인스토밍', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...p.relatedQuestions!.map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.orange)),
                          Expanded(child: Text(q, style: const TextStyle(fontSize: 12, color: AppTheme.textMain))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                  ],
                  if (p.userNote != null && p.userNote!.isNotEmpty) ...[
                    const Text('나의 메모', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSub)),
                    const SizedBox(height: 4),
                    Text(p.userNote!, style: const TextStyle(fontSize: 12, color: AppTheme.textMain, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 12),
                  ],
                  if (!hasInvestigation && widget.onInvestigate != null)
                    Center(
                      child: TextButton.icon(
                        onPressed: widget.onInvestigate,
                        icon: const Icon(Icons.psychology_outlined, size: 18),
                        label: const Text('AI와 심화 분석하기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'investigating': return AppTheme.primaryBlue;
      case 'completed': return AppTheme.accentGreen;
      case 'refuted': return AppTheme.accentRed;
      default: return AppTheme.textSub;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'investigating': return '조사 중';
      case 'completed': return '확인됨';
      case 'refuted': return '반박됨';
      default: return '대기 중';
    }
  }
}
