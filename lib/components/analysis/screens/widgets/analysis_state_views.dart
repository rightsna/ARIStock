import 'package:flutter/material.dart';
import '../../../../shared/theme.dart';

class NoStockSelectedView extends StatelessWidget {
  const NoStockSelectedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: AppTheme.textMain24,
          ),
          const SizedBox(height: 24),
          const Text(
            '분석할 종목을 먼저 선택해 주세요.',
            style: TextStyle(
              color: AppTheme.textMain54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '우측 상단의 종목 버튼을 눌러 관심종목을 선택하세요.',
            style: TextStyle(color: AppTheme.textMain38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class EmptyAnalysisView extends StatelessWidget {
  final String? symbol;
  final VoidCallback onRequestAnalysis;

  const EmptyAnalysisView({
    super.key,
    required this.symbol,
    required this.onRequestAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppTheme.textMain24,
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 통합 분석 내역이 없습니다.',
              style: TextStyle(color: AppTheme.textMain54),
            ),
            const SizedBox(height: 24),
            if (symbol != null)
              ElevatedButton.icon(
                onPressed: onRequestAnalysis,
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text('AI 첫 분석 시작하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
