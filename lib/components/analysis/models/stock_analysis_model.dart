import 'package:hive/hive.dart';
import 'investment_issue_model.dart';

part 'stock_analysis_model.g.dart';

@HiveType(typeId: 2)
class StockAnalysis {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String date;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final double? shortTermScore;

  @HiveField(4)
  final double? mediumTermScore;

  @HiveField(5)
  final double? longTermScore;

  @HiveField(6)
  final String? summary;

  @HiveField(7)
  final String? otherOpinions;


  @HiveField(9)
  final List<InvestmentIssue>? issues;

  @HiveField(10)
  final String stockName;

  StockAnalysis({
    required this.symbol,
    required this.stockName,
    required this.date,
    required this.content,
    this.shortTermScore,
    this.mediumTermScore,
    this.longTermScore,
    this.summary,
    this.otherOpinions,
    this.issues,
  });

  factory StockAnalysis.fromMap(Map<String, dynamic> map) {
    return StockAnalysis(
      symbol: map['symbol'] ?? '',
      stockName: map['stockName'] ?? map['name'] ?? '',
      date: map['date'] ?? DateTime.now().toString().split(' ')[0],
      content: map['content'] ?? '',
      shortTermScore: _toDouble(map['shortTermScore']),
      mediumTermScore: _toDouble(map['mediumTermScore']),
      longTermScore: _toDouble(map['longTermScore']),
      summary: map['summary'],
      otherOpinions: map['otherOpinions'],
      issues: map['issues'] != null 
          ? (map['issues'] as List).map((i) => InvestmentIssue.fromMap(Map<String, dynamic>.from(i))).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'stockName': stockName,
      'date': date,
      'content': content,
      'shortTermScore': shortTermScore,
      'mediumTermScore': mediumTermScore,
      'longTermScore': longTermScore,
      'summary': summary,
      'otherOpinions': otherOpinions,
      'issues': issues?.map((i) => i.toMap()).toList(),
    };
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }

  StockAnalysis copyWith({
    List<InvestmentIssue>? issues,
    String? stockName,
    String? content,
    double? shortTermScore,
    double? mediumTermScore,
    double? longTermScore,
    String? summary,
    String? otherOpinions,
  }) {
    return StockAnalysis(
      symbol: symbol,
      stockName: stockName ?? this.stockName,
      date: date,
      content: content ?? this.content,
      shortTermScore: shortTermScore ?? this.shortTermScore,
      mediumTermScore: mediumTermScore ?? this.mediumTermScore,
      longTermScore: longTermScore ?? this.longTermScore,
      summary: summary ?? this.summary,
      otherOpinions: otherOpinions ?? this.otherOpinions,
      issues: issues ?? this.issues,
    );
  }

  /// 새로운 분석 데이터와 기존 데이터를 병합하는 도메인 로직
  StockAnalysis mergeWith(StockAnalysis newAnalysis) {
    final List<InvestmentIssue> mergedIssues = List.from(issues ?? []);
    
    // 더 강력한 정규화 (공백, 탭, 줄바꿈 제거)
    String normalize(String text) => text.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    if (newAnalysis.issues != null) {
      for (var newIssue in newAnalysis.issues!) {
        final newTitleNorm = normalize(newIssue.title);
        
        final existingIndex = mergedIssues.indexWhere(
          (i) =>
              (i.id.isNotEmpty && newIssue.id.isNotEmpty && i.id == newIssue.id) ||
              normalize(i.title) == newTitleNorm,
        );

        if (existingIndex != -1) {
          final existing = mergedIssues[existingIndex];
          final currentHistory = List<IssueHistory>.from(existing.history ?? []);
          final newHistoryItems = newIssue.history ?? [];
          final today = DateTime.now().toString().split(' ')[0];
          
          if (newHistoryItems.isNotEmpty) {
            for (var item in newHistoryItems) {
              final isDuplicate = currentHistory.any((h) => 
                 h.content == item.content && h.date == item.date);
              if (!isDuplicate) currentHistory.add(item);
            }
          } else {
            // 명시적인 히스토리가 없더라도 상태/점수 변화가 있거나 최신화된 경우 자동 기록
            final lastItem = currentHistory.isNotEmpty ? currentHistory.last : null;
            final autoContent = 'AI 분석 업데이트 (상태: ${newIssue.status})';
            
            // 같은 날짜에 동일한 자동 업데이트가 없는 경우에만 추가하여 스팸 방지
            bool alreadyUpdatedToday = lastItem != null && 
                                       lastItem.date == today && 
                                       lastItem.content.contains('AI 분석 업데이트');
            
            if (!alreadyUpdatedToday) {
              currentHistory.add(IssueHistory(
                date: today,
                content: autoContent,
                detail: 'AI가 실시간 데이터를 기반으로 해당 이슈의 상태와 모멘텀을 재평가했습니다.',
                isAiAdded: true,
              ));
            }
          }

          mergedIssues[existingIndex] = existing.copyWith(
            lastInvestigation: newIssue.lastInvestigation ?? existing.lastInvestigation,
            history: currentHistory,
            status: newIssue.status != 'active' ? newIssue.status : existing.status,
            impact: newIssue.impact,
            isAiModified: true,
          );
        } else {
          // 중복 추가 방지
          final alreadyAdded = mergedIssues.any((i) => normalize(i.title) == newTitleNorm);
          if (!alreadyAdded) {
            final today = DateTime.now().toString().split(' ')[0];
            // 새 이슈인 경우 초기 히스토리 기록
            final newIssueWithHistory = newIssue.copyWith(
              id: newIssue.id.isEmpty
                  ? 'issue_${DateTime.now().microsecondsSinceEpoch}_${newIssue.title.hashCode}'
                  : newIssue.id,
              history: newIssue.history ?? [
                IssueHistory(
                  date: today,
                  content: '신규 관찰 재료 등록',
                  detail: '리서치 결과 해당 투자 재료가 탐지되어 이슈 트레이스를 시작합니다.',
                  isAiAdded: true,
                )
              ],
            );
            mergedIssues.add(newIssueWithHistory.copyWith(isAiAdded: true));
          }
        }
      }
    }

    return copyWith(
      stockName: newAnalysis.stockName.isNotEmpty ? newAnalysis.stockName : stockName,
      content: newAnalysis.content.isNotEmpty ? newAnalysis.content : content,
      shortTermScore: newAnalysis.shortTermScore ?? shortTermScore,
      mediumTermScore: newAnalysis.mediumTermScore ?? mediumTermScore,
      longTermScore: newAnalysis.longTermScore ?? longTermScore,
      summary: newAnalysis.summary ?? summary,
      otherOpinions: newAnalysis.otherOpinions ?? otherOpinions,
      issues: mergedIssues,
    );
  }

  /// 특정 ID의 이슈를 찾아 업데이트된 새 분석 객체를 반환하는 헬퍼 메서드
  StockAnalysis updateIssueById(String id, InvestmentIssue Function(InvestmentIssue) updateFn) {
    if (issues == null) return this;
    final updatedIssues = issues!.map((i) => i.id == id ? updateFn(i) : i).toList();
    return copyWith(issues: updatedIssues);
  }
}
