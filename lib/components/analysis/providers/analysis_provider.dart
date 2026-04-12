import 'package:flutter/material.dart';
import '../models/stock_analysis_model.dart';
import '../models/investment_issue_model.dart';
import '../repositories/analysis_repository.dart';

class AnalysisProvider with ChangeNotifier {
  final AnalysisRepository _repository = AnalysisRepository();

  List<StockAnalysis> _analyses = [];
  StockAnalysis? _selectedAnalysis;
  InvestmentIssue? _selectedIssue;
  bool _isLoading = false;

  List<StockAnalysis> get analyses => _analyses;
  StockAnalysis? get selectedAnalysis => _selectedAnalysis;
  InvestmentIssue? get selectedIssue => _selectedIssue;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _analyses = await _repository.getAllAnalyses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectStock(String symbol) async {
    _selectedAnalysis = await _repository.getAnalysis(symbol);
    _selectedIssue = null;
    notifyListeners();
  }

  void selectIssue(InvestmentIssue? issue) {
    _selectedIssue = issue;
    notifyListeners();
  }

  // --- 프로토콜 v2.0 대응 메서드 ---

  /// 특정 종목의 분석 객체 반환
  StockAnalysis? getAnalysisForSymbol(String symbol) {
    if (_selectedAnalysis?.symbol == symbol) return _selectedAnalysis;
    try {
      return _analyses.firstWhere((a) => a.symbol == symbol);
    } catch (_) {
      return null;
    }
  }

  /// AI 분석 데이터 객체 직접 저장 (모델 기반 병합 로직 사용)
  Future<void> addAnalysisLog(StockAnalysis newAnalysis) async {
    final existingAnalysis = await _repository.getAnalysis(newAnalysis.symbol);

    // 기존 데이터가 없더라도 새 데이터 자체의 중복 제거 및 초기화를 위해 mergeWith를 거칩니다.
    final baseAnalysis = existingAnalysis ??
        StockAnalysis(
          symbol: newAnalysis.symbol,
          stockName: newAnalysis.stockName,
          date: newAnalysis.date,
          content: '',
          issues: [],
        );

    final finalAnalysis = baseAnalysis.mergeWith(newAnalysis);

    await _repository.saveAnalysis(finalAnalysis);

    // 리스트 갱신 및 현재 선택된 종목 동기화
    _analyses = await _repository.getAllAnalyses();
    if (_selectedAnalysis?.symbol == newAnalysis.symbol) {
      _selectedAnalysis = finalAnalysis;
    }

    notifyListeners();
  }

  /// 이슈 히스토리 추가 및 상태 변경 (프로토콜 대응)
  Future<void> addIssueHistory(
    String symbol,
    String issueTitle,
    IssueHistory? history, {
    String? newStatus,
    String? stockName,
  }) async {
    StockAnalysis? analysis = await _repository.getAnalysis(symbol);

    // 로그가 없으면 기본 데이터 생성
    if (analysis == null) {
      analysis = StockAnalysis(
        symbol: symbol,
        stockName: stockName ?? symbol,
        date: DateTime.now().toString().split(' ')[0],
        content: 'AI 초기 분석 진행 중...',
        issues: [],
      );
    }

    // 새로운 이슈 객체 생성 (병합용 가상 객체)
    final newIssue = InvestmentIssue(
      id: '', // 제목 기반 매칭용
      title: issueTitle,
      startDate: DateTime.now().toString().split(' ')[0],
      isPositive: true,
      status: newStatus ?? 'active',
      history: history != null ? [history] : null,
    );

    final virtualAnalysis = StockAnalysis(
      symbol: symbol,
      stockName: stockName ?? analysis.stockName,
      date: analysis.date,
      content: '',
      issues: [newIssue],
    );

    // mergeWith를 재활용하여 일관된 병합 로직 적용
    final updatedAnalysis = analysis.mergeWith(virtualAnalysis);

    await _repository.saveAnalysis(updatedAnalysis);

    _analyses = await _repository.getAllAnalyses();
    if (_selectedAnalysis?.symbol == symbol) {
      _selectedAnalysis = updatedAnalysis;
    }
    notifyListeners();
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
    if (_selectedAnalysis == null || _selectedAnalysis!.issues == null) return;

    final updatedIssues = _selectedAnalysis!.issues!.map((i) {
      if (i.id == issue.id) {
        return i.copyWith(
          endDate: endDate,
          clearEndDate: endDate == null && status == 'active',
          status: status,
          lastInvestigation: lastInvestigation,
          history: history,
          isChecked: isChecked,
          impact: impact,
        );
      }
      return i;
    }).toList();

    final updatedAnalysis = _selectedAnalysis!.copyWith(issues: updatedIssues);
    await _saveAndRefresh(updatedAnalysis);
  }

  Future<void> toggleIssueResolved(InvestmentIssue issue) async {
    final wasResolved = issue.isResolved;
    final today = DateTime.now().toString().split(' ')[0];

    await updateIssue(
      issue,
      status: wasResolved ? 'active' : 'resolved',
      endDate: wasResolved ? null : today,
    );
    
    if (_selectedIssue?.id == issue.id) {
      _selectedIssue = null;
      notifyListeners();
    }
  }

  Future<void> deleteIssue(InvestmentIssue issue) async {
    if (_selectedAnalysis == null || _selectedAnalysis!.issues == null) return;

    final updatedIssues = _selectedAnalysis!.issues!
        .where((i) => i.id != issue.id)
        .toList();

    final updatedAnalysis = _selectedAnalysis!.copyWith(issues: updatedIssues);
    await _saveAndRefresh(updatedAnalysis);
    
    if (_selectedIssue?.id == issue.id) {
      _selectedIssue = null;
      notifyListeners();
    }
  }

  /// 제목(Title)을 기준으로 이슈 삭제
  Future<void> deleteIssueByTitle(String symbol, String title) async {
    final analysis = await _repository.getAnalysis(symbol);
    if (analysis == null || analysis.issues == null) return;

    final normalizedTitle = title.replaceAll(' ', '').toLowerCase();
    final updatedIssues = analysis.issues!
        .where((i) => i.title.replaceAll(' ', '').toLowerCase() != normalizedTitle)
        .toList();

    if (updatedIssues.length == analysis.issues!.length) return; // 삭제된 게 없음

    final updatedAnalysis = analysis.copyWith(issues: updatedIssues);
    await _saveAndRefresh(updatedAnalysis);
  }

  Future<void> approveIssueUpdate(InvestmentIssue issue) async {
    if (_selectedAnalysis == null) return;
    final updatedAnalysis = _selectedAnalysis!.updateIssueById(
      issue.id,
      (i) => i.approve(),
    );
    await _saveAndRefresh(updatedAnalysis);
  }

  Future<void> rejectIssueUpdate(InvestmentIssue issue) async {
    if (_selectedAnalysis == null) return;

    if (issue.isAiAdded) {
      await deleteIssue(issue);
      return;
    }

    final updatedAnalysis = _selectedAnalysis!.updateIssueById(
      issue.id,
      (i) => i.reject(),
    );
    await _saveAndRefresh(updatedAnalysis);
  }

  Future<void> approveHistoryUpdate(
    InvestmentIssue issue,
    IssueHistory history,
  ) async {
    if (_selectedAnalysis == null) return;

    final updatedAnalysis = _selectedAnalysis!.updateIssueById(
      issue.id,
      (i) => i.approveHistoryItem(history),
    );
    await _saveAndRefresh(updatedAnalysis);
  }

  Future<void> rejectHistoryUpdate(
    InvestmentIssue issue,
    IssueHistory history,
  ) async {
    await deleteHistoryItem(issue, history);
  }

  Future<void> deleteHistoryItem(
    InvestmentIssue issue,
    IssueHistory history,
  ) async {
    if (_selectedAnalysis == null) return;

    final updatedAnalysis = _selectedAnalysis!.updateIssueById(
      issue.id,
      (i) => i.rejectHistoryItem(history),
    );
    await _saveAndRefresh(updatedAnalysis);
  }

  /// 내부 상태 저장 및 UI 갱신 공통 로직
  Future<void> _saveAndRefresh(StockAnalysis updatedAnalysis) async {
    await _repository.saveAnalysis(updatedAnalysis);
    _selectedAnalysis = updatedAnalysis;

    // 전체 리스트 동기화
    final index = _analyses.indexWhere((a) => a.symbol == updatedAnalysis.symbol);
    if (index != -1) {
      _analyses[index] = updatedAnalysis;
    }

    notifyListeners();
  }


  Future<void> clearLog(String symbol) async {
    await _repository.deleteAnalysis(symbol);
    _analyses = await _repository.getAllAnalyses();
    if (_selectedAnalysis?.symbol == symbol) {
      _selectedAnalysis = null;
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _analyses = [];
    _selectedAnalysis = null;
    notifyListeners();
  }

}
