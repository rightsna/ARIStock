import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../../../../shared/theme.dart';

class AnalysisHistorySelector extends StatelessWidget {
  final List<AnalysisLog> logs;
  final AnalysisLog? selectedLog;
  final Function(AnalysisLog) onSelect;

  const AnalysisHistorySelector({
    super.key,
    required this.logs,
    required this.selectedLog,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '과거 분석 이력 (날짜별)',
          style: TextStyle(color: AppTheme.textMain54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isSelected = selectedLog == log;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => onSelect(log),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : AppTheme.textMain10,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      log.date,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textMain54,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
