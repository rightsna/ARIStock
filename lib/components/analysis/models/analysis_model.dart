import 'package:hive/hive.dart';

part 'analysis_model.g.dart';

@HiveType(typeId: 1)
class AnalysisStock {
  @HiveField(0)
  final String symbol; // 종목 코드 또는 심볼

  @HiveField(1)
  final String name; // 종목 이름

  AnalysisStock({
    required this.symbol,
    required this.name,
  });
}

@HiveType(typeId: 2)
class AnalysisLog {
  @HiveField(0)
  final String symbol; // 연결된 종목 심볼

  @HiveField(1)
  final String date; // 분석 일자 (YYYY-MM-DD)

  @HiveField(2)
  final String content; // 전체 내용 (호환성 유지용)

  @HiveField(3)
  final double? shortTermScore; // 단기 예측 점수 (0.0~1.0)

  @HiveField(4)
  final double? mediumTermScore; // 중기 예측 점수 (0.0~1.0)

  @HiveField(5)
  final double? longTermScore; // 장기 예측 점수 (0.0~1.0)

  @HiveField(6)
  final String? summary; // 분석 요약

  @HiveField(7)
  final String? otherOpinions; // 기타 의견

  @HiveField(8)
  final String? userNote; // 사용자가 직접 쓴 노트

  @HiveField(9)
  final List<AnalysisCheckPoint>? checkPoints; // 구조화된 체크포인트

  AnalysisLog({
    required this.symbol,
    required this.date,
    required this.content,
    this.shortTermScore,
    this.mediumTermScore,
    this.longTermScore,
    this.summary,
    this.otherOpinions,
    this.userNote,
    this.checkPoints,
  });

  // 유저 노트를 업데이트하거나 체크포인트를 토글하기 위한 복사 메서드
  AnalysisLog copyWith({
    String? userNote,
    List<AnalysisCheckPoint>? checkPoints,
  }) {
    return AnalysisLog(
      symbol: symbol,
      date: date,
      content: content,
      shortTermScore: shortTermScore,
      mediumTermScore: mediumTermScore,
      longTermScore: longTermScore,
      summary: summary,
      otherOpinions: otherOpinions,
      userNote: userNote ?? this.userNote,
      checkPoints: checkPoints ?? this.checkPoints,
    );
  }
}

@HiveType(typeId: 3)
class AnalysisCheckPoint {
  @HiveField(0)
  final String content; // 체크포인트 내용

  @HiveField(1)
  final bool isChecked; // 확인 여부

  @HiveField(2)
  final bool isPositive; // true: 상승관점(긍정), false: 하락관점(부정)

  @HiveField(3)
  final int? impact; // 임팩트 팩터 (1~5)

  AnalysisCheckPoint({
    required this.content,
    this.isChecked = false,
    required this.isPositive,
    this.impact = 3, // 기본값 중간 (새 데이터용)
  });

  // UI용 Getter (기존 데이터 호환을 위해 3 보장)
  int get impactValue => impact ?? 3;

  AnalysisCheckPoint copyWith({bool? isChecked}) {
    return AnalysisCheckPoint(
      content: content,
      isChecked: isChecked ?? this.isChecked,
      isPositive: isPositive,
      impact: impact,
    );
  }
}
