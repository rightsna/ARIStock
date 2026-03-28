import 'package:hive/hive.dart';

part 'investment_issue_model.g.dart';

@HiveType(typeId: 3)
class InvestmentIssue {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String startDate;

  @HiveField(3)
  final String? endDate;

  @HiveField(4)
  final bool isPositive;

  @HiveField(5)
  final int impact;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final String? lastInvestigation;

  @HiveField(8)
  final List<IssueHistory>? history;

  @HiveField(9)
  final bool isChecked;

  // 휘발성 필드 (Hive 저장 안함)
  final bool isAiAdded;
  final bool isAiModified;

  InvestmentIssue({
    required this.id,
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
      id: map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
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
      'id': id,
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

  InvestmentIssue approve() {
    return copyWith(
      isAiAdded: false,
      isAiModified: false,
      history: history?.map((h) => h.approve()).toList(),
    );
  }

  InvestmentIssue reject() {
    // AI가 추가한 이슈라면 삭제 대상임을 표시 (상위에서 처리 필요하므로 상태만 변경하거나 null 반환 전략)
    // 여기서는 기존 로직대로 isAiAdded면 삭제 로직을 따르도록 함 (Provider에서 체크)
    
    final filteredHistory = history?.where((h) => !h.isAiAdded).toList();
    return copyWith(
      isAiModified: false,
      history: filteredHistory,
    );
  }

  InvestmentIssue approveHistoryItem(IssueHistory targetHistory) {
    final updatedHistory = history?.map((h) {
      if (h.date == targetHistory.date && h.content == targetHistory.content) {
        return h.approve();
      }
      return h;
    }).toList();

    final hasAnyAiHistory = updatedHistory?.any((h) => h.isAiAdded) ?? false;

    return copyWith(
      history: updatedHistory,
      isAiModified: hasAnyAiHistory,
    );
  }

  InvestmentIssue rejectHistoryItem(IssueHistory targetHistory) {
    final filteredHistory = history?.where(
      (h) => !(h.date == targetHistory.date &&
               h.content == targetHistory.content &&
               h.detail == targetHistory.detail),
    ).toList();

    final hasAnyAiHistory = filteredHistory?.any((h) => h.isAiAdded) ?? false;

    return copyWith(
      history: filteredHistory,
      isAiModified: hasAnyAiHistory,
    );
  }

  InvestmentIssue copyWith({
    String? endDate,
    bool clearEndDate = false,
    String? status,
    String? lastInvestigation,
    List<IssueHistory>? history,
    bool? isChecked,
    int? impact,
    bool? isAiAdded,
    bool? isAiModified,
  }) {
    return InvestmentIssue(
      id: id,
      title: title,
      startDate: startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
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

  // 휘발성 필드 (Hive 저장 안함)
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

  IssueHistory approve() {
    return copyWith(isAiAdded: false);
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
