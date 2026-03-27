import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../repositories/analysis_repository.dart';

class AnalysisProvider with ChangeNotifier {
  final AnalysisRepository _repository = AnalysisRepository();

  List<AnalysisStock> _stocks = [];
  AnalysisLog? _selectedLog; 
  bool _isLoading = false;

  List<AnalysisStock> get stocks => _stocks;
  AnalysisLog? get selectedLog => _selectedLog;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _stocks = await _repository.getAllStocks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectStock(String symbol) async {
    _selectedLog = await _repository.getLogByStock(symbol);
    notifyListeners();
  }

  // --- 프로토콜 v2.0 대응 메서드 ---

  /// 특정 종목의 로그를 반환 (비동기 조회)
  AnalysisLog? getLogForSymbol(String symbol) {
    if (_selectedLog?.symbol == symbol) return _selectedLog;
    // 참고: 동기 반환을 위해 우선 캐시된 데이터를 사용하거나 내부 처리가 필요함
    // 여기서는 간단히 현재 선택된 로그 기반으로 처리하거나 캐시된 리스트를 활용
    return _selectedLog?.symbol == symbol ? _selectedLog : null;
  }

  /// AI 분석 데이터 객체 직접 저장 (병합 로직 포함)
  Future<void> addAnalysisLog(AnalysisLog newLog) async {
    final existingLog = await _repository.getLogByStock(newLog.symbol);
    final List<InvestmentIssue> mergedIssues = List.from(existingLog?.issues ?? []);

    // 제목 정규화 (공백 제거 후 대소문자 무시 비교)
    String normalize(String text) => text.replaceAll(' ', '').toLowerCase();

    if (newLog.issues != null) {
      for (var newIssue in newLog.issues!) {
        final existingIndex = mergedIssues.indexWhere(
          (i) => normalize(i.title) == normalize(newIssue.title)
        );

        if (existingIndex != -1) {
          final existing = mergedIssues[existingIndex];
          final currentHistory = List<IssueHistory>.from(existing.history ?? []);
          
          currentHistory.add(IssueHistory(
            date: DateTime.now().toString().split(' ')[0],
            content: 'AI 업데이트: ${newIssue.title}',
            detail: '분석 내용이 최신 상태로 갱신되었습니다.',
            isAiAdded: true, // 강조 플래그 추가
          ));

          mergedIssues[existingIndex] = existing.copyWith(
            lastInvestigation: newIssue.lastInvestigation ?? existing.lastInvestigation,
            history: currentHistory,
            status: newIssue.status != 'active' ? newIssue.status : existing.status,
            impact: newIssue.impact,
            isAiModified: true, // 수정됨 강조 플래그
          );
        } else {
          // 완전히 새로운 이슈인 경우
          mergedIssues.add(newIssue.copyWith(isAiAdded: true));
        }
      }
    }

    final finalLog = AnalysisLog(
      symbol: newLog.symbol,
      date: DateTime.now().toString().split(' ')[0],
      content: newLog.content.isNotEmpty ? newLog.content : (existingLog?.content ?? ''),
      shortTermScore: newLog.shortTermScore ?? existingLog?.shortTermScore,
      mediumTermScore: newLog.mediumTermScore ?? existingLog?.mediumTermScore,
      longTermScore: newLog.longTermScore ?? existingLog?.longTermScore,
      summary: newLog.summary ?? existingLog?.summary,
      otherOpinions: newLog.otherOpinions ?? existingLog?.otherOpinions,
      userNote: existingLog?.userNote, 
      issues: mergedIssues,
    );
    
    await _repository.saveLog(finalLog);
    await _ensureStockExists(newLog.symbol);
    
    // 만약 현재 보고 있는 종목이라면 UI 갱신
    if (_selectedLog?.symbol == newLog.symbol) {
      _selectedLog = finalLog;
    }
    
    notifyListeners();
  }

  /// 이슈 히스토리 추가 및 상태 변경 (프로토콜 대응)
  Future<void> addIssueHistory(
    String symbol, 
    String issueTitle, 
    IssueHistory? history, 
    {String? newStatus}
  ) async {
    AnalysisLog? log = await _repository.getLogByStock(symbol);
    
    // 만약 로그가 없다면 기본 로그 생성
    if (log == null) {
      log = AnalysisLog(
        symbol: symbol,
        date: DateTime.now().toString().split(' ')[0],
        content: 'AI 초기 분석 진행 중...',
        issues: [],
      );
    }

    final List<InvestmentIssue> currentIssues = List.from(log.issues ?? []);
    bool found = false;

    // 제목 정규화 (공백 제거 후 대소문자 무시 비교)
    String normalize(String text) => text.replaceAll(' ', '').toLowerCase();
    final normalizedSearchTitle = normalize(issueTitle);

    final updatedIssues = currentIssues.map((i) {
      if (normalize(i.title) == normalizedSearchTitle) {
        found = true;
        final currentHistory = List<IssueHistory>.from(i.history ?? []);
        if (history != null) {
          currentHistory.add(history.copyWith(isAiAdded: true));
        }
        
        return i.copyWith(
          history: currentHistory,
          status: newStatus ?? (history != null ? 'evolving' : i.status),
          isAiModified: true, // AI에 의해 수정됨
        );
      }
      return i;
    }).toList();

    // 만약 해당 이슈가 없다면 새로 추가
    if (!found) {
      final newIssue = InvestmentIssue(
        title: issueTitle,
        startDate: DateTime.now().toString().split(' ')[0],
        isPositive: true, // 기본값
        status: newStatus ?? 'active',
        history: history != null ? [history.copyWith(isAiAdded: true)] : [],
        isAiAdded: true, // AI에 의해 새로 추가됨
      );
      updatedIssues.add(newIssue);
    }

    final updatedLog = log.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);

    await _ensureStockExists(symbol);

    if (_selectedLog?.symbol == symbol) {
      _selectedLog = updatedLog;
    }
    notifyListeners();
  }

  /// 해당 종목이 분석 리스트에 등록되어 있는지 확인하고 등록 (UI 갱신용)
  Future<void> _ensureStockExists(String symbol) async {
    final allStocks = await _repository.getAllStocks();
    if (!allStocks.any((s) => s.symbol == symbol)) {
      await _repository.addStock(AnalysisStock(symbol: symbol, name: symbol));
      _stocks = await _repository.getAllStocks();
      notifyListeners();
    }
  }

  // --- 기존 편의 기능 ---

  Future<void> updateIssue(
    InvestmentIssue issue, {
    String? endDate,
    String? status,
    String? lastInvestigation,
    List<IssueHistory>? history,
    bool? isChecked,
    int? impact,
  }) async {
    if (_selectedLog == null || _selectedLog!.issues == null) return;

    final updatedIssues = _selectedLog!.issues!.map((i) {
      if (i.title == issue.title && i.isPositive == issue.isPositive) {
        return i.copyWith(
          endDate: endDate,
          status: status,
          lastInvestigation: lastInvestigation,
          history: history,
          isChecked: isChecked,
          impact: impact,
        );
      }
      return i;
    }).toList();

    final updatedLog = _selectedLog!.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> toggleIssueResolved(InvestmentIssue issue) async {
    final isResolved = issue.status == 'resolved';
    final today = DateTime.now().toString().split(' ')[0];
    await updateIssue(
      issue, 
      status: isResolved ? 'active' : 'resolved',
      endDate: isResolved ? null : today,
    );
  }

  Future<void> deleteIssue(InvestmentIssue issue) async {
    if (_selectedLog == null || _selectedLog!.issues == null) return;
    
    final updatedIssues = _selectedLog!.issues!.where((i) => 
      !(i.title == issue.title && i.isPositive == issue.isPositive)
    ).toList();

    final updatedLog = _selectedLog!.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> approveIssueUpdate(InvestmentIssue issue) async {
    if (_selectedLog == null || _selectedLog!.issues == null) return;
    
    final updatedIssues = _selectedLog!.issues!.map((i) {
      if (i.title == issue.title && i.isPositive == issue.isPositive) {
        return i.copyWith(
          isAiAdded: false,
          isAiModified: false,
          history: i.history?.map((h) => h.copyWith(isAiAdded: false)).toList(),
        );
      }
      return i;
    }).toList();

    final updatedLog = _selectedLog!.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> rejectIssueUpdate(InvestmentIssue issue) async {
    if (_selectedLog == null || _selectedLog!.issues == null) return;
    
    if (issue.isAiAdded) {
      await deleteIssue(issue);
      return;
    }

    // 수정된 항목이라면 강조를 끄고 최근 AI 히스토리를 삭제하거나 함
    final updatedIssues = _selectedLog!.issues!.map((i) {
      if (i.title == issue.title && i.isPositive == issue.isPositive) {
        final filteredHistory = i.history?.where((h) => !h.isAiAdded).toList();
        return i.copyWith(
          isAiModified: false,
          history: filteredHistory,
        );
      }
      return i;
    }).toList();

    final updatedLog = _selectedLog!.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> approveHistoryUpdate(InvestmentIssue issue, IssueHistory history) async {
    if (_selectedLog == null || _selectedLog!.issues == null) return;
    
    final updatedIssues = _selectedLog!.issues!.map((i) {
      if (i.title == issue.title && i.isPositive == issue.isPositive) {
        final updatedHistory = i.history?.map((h) {
          if (h.date == history.date && h.content == history.content) {
            return h.copyWith(isAiAdded: false);
          }
          return h;
        }).toList();
        
        // 만약 모든 AI 히스토리가 승인되면 이슈의 isAiModified도 해제할 수 있음
        final hasAnyAiHistory = updatedHistory?.any((h) => h.isAiAdded) ?? false;

        return i.copyWith(
          history: updatedHistory,
          isAiModified: hasAnyAiHistory,
        );
      }
      return i;
    }).toList();

    final updatedLog = _selectedLog!.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> rejectHistoryUpdate(InvestmentIssue issue, IssueHistory history) async {
    await deleteHistoryItem(issue, history);
  }

  Future<void> deleteHistoryItem(InvestmentIssue issue, IssueHistory history) async {
    if (_selectedLog == null || _selectedLog!.issues == null) return;
    
    final updatedIssues = _selectedLog!.issues!.map((i) {
      if (i.title == issue.title && i.isPositive == issue.isPositive) {
        final filteredHistory = i.history?.where((h) => 
          !(h.date == history.date && h.content == history.content && h.detail == history.detail)
        ).toList();
        
        final hasAnyAiHistory = filteredHistory?.any((h) => h.isAiAdded) ?? false;
        
        return i.copyWith(
          history: filteredHistory,
          isAiModified: hasAnyAiHistory,
        );
      }
      return i;
    }).toList();

    final updatedLog = _selectedLog!.copyWith(issues: updatedIssues);
    await _repository.saveLog(updatedLog);
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> updateUserNote(String note) async {
    if (_selectedLog == null) return;
    final updatedLog = _selectedLog!.copyWith(userNote: note);
    await _repository.saveLog(updatedLog); 
    _selectedLog = updatedLog;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _stocks = [];
    _selectedLog = null;
    notifyListeners();
  }

  // DEBUG: AI 수정 모드 토글 (실제 통신 로직을 타도록 수정)
  void toggleAiModificationDebug() {
    if (_selectedLog == null || _selectedLog!.issues == null || _selectedLog!.issues!.isEmpty) return;

    final symbol = _selectedLog!.symbol;
    final firstIssue = _selectedLog!.issues!.first;

    // 만약 이미 수정된 상태라면 승인 처리 (DB 반영)
    if (firstIssue.isAiModified) {
      approveIssueUpdate(firstIssue);
      return;
    }

    // 수정되지 않은 상태라면 새로운 히스토리를 추가하여 '수정됨' 상태 유발 (DB 저장 포함)
    final nowStr = DateTime.now().toString().split(' ')[0];
    addIssueHistory(
      symbol, 
      firstIssue.title, 
      IssueHistory(
        date: nowStr, 
        content: 'AI 분석 포인트 탐지', 
        detail: '실시간 시장 데이터를 바탕으로 새로운 이슈 흐름이 포착되었습니다.',
      )
    );
  }

  // DEBUG: AI 추가 모드 토글 (실제 통신 로직을 타도록 수정)
  void toggleAiAdditionDebug() {
    if (_selectedLog == null) return;

    final symbol = _selectedLog!.symbol;
    const debugTitle = '[DEBUG] AI 발견 신규 이슈';
    
    final issues = _selectedLog!.issues ?? [];
    final existing = issues.any((i) => i.title == debugTitle);

    if (existing) {
      // 이미 있으면 거절(삭제) 처리 (DB 반영)
      final issueToDelete = issues.firstWhere((i) => i.title == debugTitle);
      rejectIssueUpdate(issueToDelete);
    } else {
      // 없으면 신규 이슈로 프로토콜 가상 호출 (DB 저장 포함)
      final nowStr = DateTime.now().toString().split(' ')[0];
      final newIssue = InvestmentIssue(
        title: debugTitle,
        startDate: nowStr,
        isPositive: true,
        impact: 4,
        history: [
          IssueHistory(date: nowStr, content: '신규 모멘텀 포착', detail: 'AI 알고리즘이 새로운 상승 트리거를 발견했습니다.'),
        ],
      );
      
      addAnalysisLog(AnalysisLog(
        symbol: symbol,
        date: nowStr,
        content: '',
        issues: [newIssue],
      ));
    }
  }

  // DEBUG 전용 샘플 생성
  Future<void> loadSampleTimeline(String symbol, String name) async {
    final today = DateTime.now();
    final d1 = today.subtract(const Duration(days: 5)).toString().split(' ')[0];
    final d2 = today.subtract(const Duration(days: 3)).toString().split(' ')[0];
    final d3 = today.subtract(const Duration(days: 1)).toString().split(' ')[0];
    final nowStr = today.toString().split(' ')[0];

    final issues = [
      InvestmentIssue(
        title: '반도체 공급 과잉 해소',
        startDate: d1,
        endDate: d3,
        isPositive: true,
        impact: 4,
        status: 'resolved',
        history: [
          IssueHistory(date: d1, content: '재고 감소 추세 포착', detail: '주요 제조사들의 재고가 10% 이상 감소했습니다.'),
          IssueHistory(date: d2, content: '공급 조절 가속화', detail: 'D램 생산량 조절이 성공적으로 진행 중입니다.'),
          IssueHistory(date: d3, content: '이슈 완료: 정상 수급 도달', detail: '이제는 수요 급증을 대비해야 할 시점입니다.'),
        ],
      ),
      InvestmentIssue(
        title: 'HBM 독점 공급 가능성',
        startDate: d2,
        isPositive: true,
        impact: 5,
        status: 'evolving',
        history: [
          IssueHistory(date: d2, content: '인증 통과 소식', detail: '북미 고객사로부터 최종 인증 통보를 받았습니다.'),
        ],
        lastInvestigation: '현재 수주 확정 단계입니다.',
      ),
    ];

    final log = AnalysisLog(
      symbol: symbol,
      date: nowStr,
      content: '샘플 데이터',
      issues: issues,
      shortTermScore: 85,
    );

    await addAnalysisLog(log);
    await selectStock(symbol);
  }
}
