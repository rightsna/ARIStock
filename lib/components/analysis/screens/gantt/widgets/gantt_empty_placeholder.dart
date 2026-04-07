import 'package:flutter/material.dart';
import '../../../../../shared/theme.dart';

class GanttEmptyPlaceholder extends StatelessWidget {
  final VoidCallback? onAddRequest;

  const GanttEmptyPlaceholder({
    super.key,
    this.onAddRequest,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddRequest,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.textMain10, 
            width: 1.5, 
            style: BorderStyle.none,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_chart_rounded, size: 32, color: AppTheme.textMain24),
            SizedBox(height: 12),
            Text(
              '여기를 눌러 첫 투자 이슈를 생성해 보세요.', 
              style: TextStyle(color: AppTheme.textMain38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
