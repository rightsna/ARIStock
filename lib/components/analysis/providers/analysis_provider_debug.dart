import '../models/stock_analysis_model.dart';
import '../models/investment_issue_model.dart';
import 'analysis_provider.dart';

extension AnalysisProviderDebug on AnalysisProvider {
  // DEBUG 전용 샘플 생성
  Future<void> loadSampleTimeline(String symbol, String name) async {
    final today = DateTime.now();
    final d1 = today.subtract(const Duration(days: 5)).toString().split(' ')[0];
    final d2 = today.subtract(const Duration(days: 3)).toString().split(' ')[0];
    final d3 = today.subtract(const Duration(days: 1)).toString().split(' ')[0];
    final nowStr = today.toString().split(' ')[0];

    final issues = [
      InvestmentIssue(
        id: 'sample_1',
        title: '반도체 공급 과잉 해소',
        startDate: d1,
        endDate: d3,
        isPositive: true,
        impact: 4,
        status: 'resolved',
        history: [
          IssueHistory(
            date: d1,
            content: '재고 감소 추세 포착',
            detail: '주요 제조사들의 재고가 10% 이상 감소했습니다.',
          ),
          IssueHistory(
            date: d2,
            content: '공급 조절 가속화',
            detail: 'D램 생산량 조절이 성공적으로 진행 중입니다.',
          ),
          IssueHistory(
            date: d3,
            content: '이슈 완료: 정상 수급 도달',
            detail: '이제는 수요 급증을 대비해야 할 시점입니다.',
          ),
        ],
      ),
      InvestmentIssue(
        id: 'sample_2',
        title: 'HBM 독점 공급 가능성',
        startDate: d2,
        isPositive: true,
        impact: 5,
        status: 'evolving',
        history: [
          IssueHistory(
            date: d2,
            content: '인증 통과 소식',
            detail: '북미 고객사로부터 최종 인증 통보를 받았습니다.',
          ),
        ],
        lastInvestigation: '현재 수주 확정 단계입니다.',
      ),
    ];

    final analysis = StockAnalysis(
      symbol: symbol,
      stockName: name,
      date: nowStr,
      content: '샘플 데이터',
      issues: issues,
      shortTermScore: 0.85,
    );

    await addAnalysisLog(analysis);
    await selectStock(symbol);
  }

  // DEBUG 토글 기능들 유지
  void toggleAiModificationDebug() {
    if (selectedAnalysis == null ||
        (selectedAnalysis!.issues?.isEmpty ?? true))
      return;
    final firstIssue = selectedAnalysis!.issues!.first;
    if (firstIssue.isAiModified) {
      approveIssueUpdate(firstIssue);
    } else {
      addIssueHistory(
        selectedAnalysis!.symbol,
        firstIssue.title,
        IssueHistory(
          date: DateTime.now().toString().split(' ')[0],
          content: 'AI 분석 포인트 탐지',
          detail: '실시간 시장 데이터를 바탕으로 새로운 이슈 흐름이 포착되었습니다.',
        ),
      );
    }
  }

  void toggleAiAdditionDebug() {
    if (selectedAnalysis == null) return;
    final symbol = selectedAnalysis!.symbol;
    const debugTitle = '[DEBUG] AI 발견 신규 이슈';
    final existing =
        selectedAnalysis!.issues?.any((i) => i.title == debugTitle) ?? false;

    if (existing) {
      final issue = selectedAnalysis!.issues!.firstWhere(
        (i) => i.title == debugTitle,
      );
      rejectIssueUpdate(issue);
    } else {
      final nowStr = DateTime.now().toString().split(' ')[0];
      final newIssue = InvestmentIssue(
        id: 'debug_${DateTime.now().microsecondsSinceEpoch}',
        title: debugTitle,
        startDate: nowStr,
        isPositive: true,
        impact: 4,
        history: [
          IssueHistory(
            date: nowStr,
            content: '신규 모멘텀 포착',
            detail: 'AI 알고리즘이 새로운 상승 트리거를 발견했습니다.',
          ),
        ],
      );
      addAnalysisLog(
        StockAnalysis(
          symbol: symbol,
          stockName: selectedAnalysis!.stockName,
          date: nowStr,
          content: '',
          issues: [newIssue],
        ),
      );
    }
  }
}
