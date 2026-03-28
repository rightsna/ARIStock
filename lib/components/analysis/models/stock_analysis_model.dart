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

  @HiveField(8)
  final String? userNote;

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
    this.userNote,
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
      userNote: map['userNote'],
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
      'userNote': userNote,
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
    String? userNote,
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
      userNote: userNote ?? this.userNote,
      issues: issues ?? this.issues,
    );
  }

  /// 새로운 분석 데이터와 기존 데이터를 병합하는 도메인 로직
  StockAnalysis mergeWith(StockAnalysis newAnalysis) {
    final List<InvestmentIssue> mergedIssues = List.from(issues ?? []);
    
    String normalize(String text) => text.replaceAll(' ', '').toLowerCase();

    if (newAnalysis.issues != null) {
      for (var newIssue in newAnalysis.issues!) {
        final existingIndex = mergedIssues.indexWhere(
          (i) =>
              i.id == newIssue.id ||
              normalize(i.title) == normalize(newIssue.title),
        );

        if (existingIndex != -1) {
          final existing = mergedIssues[existingIndex];
          final currentHistory = List<IssueHistory>.from(existing.history ?? []);

          currentHistory.add(
            IssueHistory(
              date: DateTime.now().toString().split(' ')[0],
              content: 'AI 업데이트: ${newIssue.title}',
              detail: '분석 내용이 최신 상태로 갱신되었습니다.',
              isAiAdded: true,
            ),
          );

          mergedIssues[existingIndex] = existing.copyWith(
            lastInvestigation: newIssue.lastInvestigation ?? existing.lastInvestigation,
            history: currentHistory,
            status: newIssue.status != 'active' ? newIssue.status : existing.status,
            impact: newIssue.impact,
            isAiModified: true,
          );
        } else {
          mergedIssues.add(newIssue.copyWith(isAiAdded: true));
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
