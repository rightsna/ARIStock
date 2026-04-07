import 'package:flutter/material.dart';
import 'package:aristock/shared/theme.dart';

class MockInvestmentToggle extends StatelessWidget {
  final bool isMock;
  final ValueChanged<bool> onChanged;

  const MockInvestmentToggle({
    super.key,
    required this.isMock,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isMock
            ? Colors.amber.withValues(alpha: 0.08)
            : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMock
              ? Colors.amber.withValues(alpha: 0.3)
              : AppTheme.textMain.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isMock ? Icons.science_rounded : Icons.trending_up_rounded,
            color: isMock ? Colors.amber : AppTheme.textMain38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '모의투자',
                  style: TextStyle(
                    color: AppTheme.textMain70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isMock ? 'mockapi.kiwoom.com 사용' : '실전투자 (api.kiwoom.com)',
                  style: TextStyle(
                    color: AppTheme.textMain.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isMock,
            onChanged: onChanged,
            activeThumbColor: Colors.amber,
          ),
        ],
      ),
    );
  }
}
