import 'package:hive/hive.dart';

part 'analysis_model.g.dart';

@HiveType(typeId: 1)
class AnalysisStock {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  AnalysisStock({
    required this.symbol,
    required this.name,
  });
}

@HiveType(typeId: 2)
class AnalysisLog {
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
    this.issues,
  });

  factory AnalysisLog.fromMap(Map<String, dynamic> map) {
    return AnalysisLog(
      symbol: map['symbol'] ?? '',
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

  AnalysisLog copyWith({
    String? userNote,
    List<InvestmentIssue>? issues,
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
      issues: issues ?? this.issues,
    );
  }
}

@HiveType(typeId: 3)
class InvestmentIssue {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String startDate;

  @HiveField(2)
  final String? endDate;

  @HiveField(3)
  final bool isPositive;

  @HiveField(4)
  final int impact;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String? lastInvestigation;

  @HiveField(7)
  final List<IssueHistory>? history;

  @HiveField(8)
  final bool isChecked;

  @HiveField(10)
  final bool isAiAdded;

  @HiveField(11)
  final bool isAiModified;

  InvestmentIssue({
    required this.title,
    required this.startDate,
    this.endDate,
    required this.isPositive,
    this.impact = 3,
    this.status = 'active',
    this.lastInvestigation,
    this.history,
    this.isChecked = false,
    this.isAiAdded = false,
    this.isAiModified = false,
  });

  factory InvestmentIssue.fromMap(Map<String, dynamic> map) {
    return InvestmentIssue(
      title: map['title'] ?? '',
      startDate: map['startDate'] ?? DateTime.now().toString().split(' ')[0],
      endDate: map['endDate'],
      isPositive: map['isPositive'] ?? true,
      impact: map['impact'] ?? 3,
      status: map['status'] ?? 'active',
      lastInvestigation: map['lastInvestigation'],
      history: map['history'] != null
          ? (map['history'] as List).map((h) => IssueHistory.fromMap(Map<String, dynamic>.from(h))).toList()
          : null,
      isChecked: map['isChecked'] ?? false,
      isAiAdded: map['isAiAdded'] ?? false,
      isAiModified: map['isAiModified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'isPositive': isPositive,
      'impact': impact,
      'status': status,
      'lastInvestigation': lastInvestigation,
      'history': history?.map((h) => h.toMap()).toList(),
      'isChecked': isChecked,
      'isAiAdded': isAiAdded,
      'isAiModified': isAiModified,
    };
  }

  bool get isResolved => status == 'resolved' || endDate != null;

  InvestmentIssue copyWith({
    String? endDate,
    String? status,
    String? lastInvestigation,
    List<IssueHistory>? history,
    bool? isChecked,
    int? impact,
    bool? isAiAdded,
    bool? isAiModified,
  }) {
    return InvestmentIssue(
      title: title,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      isPositive: isPositive,
      impact: impact ?? this.impact,
      status: status ?? this.status,
      lastInvestigation: lastInvestigation ?? this.lastInvestigation,
      history: history ?? this.history,
      isChecked: isChecked ?? this.isChecked,
      isAiAdded: isAiAdded ?? this.isAiAdded,
      isAiModified: isAiModified ?? this.isAiModified,
    );
  }
}

@HiveType(typeId: 4)
class IssueHistory {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String? detail;

  @HiveField(3)
  final bool isAiAdded;

  IssueHistory({
    required this.date,
    required this.content,
    this.detail,
    this.isAiAdded = false,
  });

  factory IssueHistory.fromMap(Map<String, dynamic> map) {
    return IssueHistory(
      date: map['date'] ?? DateTime.now().toString().split(' ')[0],
      content: map['content'] ?? '',
      detail: map['detail'],
      isAiAdded: map['isAiAdded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'content': content,
      'detail': detail,
      'isAiAdded': isAiAdded,
    };
  }

  IssueHistory copyWith({
    String? date,
    String? content,
    String? detail,
    bool? isAiAdded,
  }) {
    return IssueHistory(
      date: date ?? this.date,
      content: content ?? this.content,
      detail: detail ?? this.detail,
      isAiAdded: isAiAdded ?? this.isAiAdded,
    );
  }
}
