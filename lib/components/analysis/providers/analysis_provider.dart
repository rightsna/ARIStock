import 'package:flutter/material.dart';
import '../models/analysis_model.dart';
import '../repositories/analysis_repository.dart';

class AnalysisProvider with ChangeNotifier {
  final AnalysisRepository _repository = AnalysisRepository();

  List<AnalysisStock> _stocks = [];
  List<AnalysisLog> _currentStockLogs = [];
  AnalysisLog? _selectedLog;
  bool _isLoading = false;

  List<AnalysisStock> get stocks => _stocks;
  List<AnalysisLog> get currentStockLogs => _currentStockLogs;
  AnalysisLog? get selectedLog => _selectedLog;
  bool get isLoading => _isLoading;

  // 데이터 초기화
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _stocks = await _repository.getAllStocks();
    _isLoading = false;
    notifyListeners();
  }

  // 종목 선택 및 해당 종목의 분석 히스토리 로드
  Future<void> selectStock(String symbol) async {
    _currentStockLogs = await _repository.getLogsByStock(symbol);
    if (_currentStockLogs.isNotEmpty) {
      _selectedLog = _currentStockLogs.first;
    } else {
      _selectedLog = null;
    }
    notifyListeners();
  }

  // 특정 로그 선택 (히스토리에서 클릭 시)
  void selectLog(AnalysisLog log) {
    _selectedLog = log;
    notifyListeners();
  }

  Future<void> saveAnalysis(
    String symbol,
    String name,
    String content, {
    double? shortTermScore,
    double? mediumTermScore,
    double? longTermScore,
    String? summary,
    List<dynamic>? positive,
    List<dynamic>? negative,
    String? otherOpinions,
    String? userNote,
  }) async {
    final stock = AnalysisStock(symbol: symbol, name: name);
    await _repository.addStock(stock);

    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final points = <AnalysisCheckPoint>[];
    if (positive != null) {
      points.addAll(positive.map((item) {
        if (item is Map) {
          return AnalysisCheckPoint(
            content: item['content']?.toString() ?? '',
            isPositive: true,
            impact: int.tryParse(item['impact']?.toString() ?? '') ?? 3,
          );
        }
        return AnalysisCheckPoint(content: item.toString(), isPositive: true);
      }));
    }
    if (negative != null) {
      points.addAll(negative.map((item) {
        if (item is Map) {
          return AnalysisCheckPoint(
            content: item['content']?.toString() ?? '',
            isPositive: false,
            impact: int.tryParse(item['impact']?.toString() ?? '') ?? 3,
          );
        }
        return AnalysisCheckPoint(content: item.toString(), isPositive: false);
      }));
    }

    final log = AnalysisLog(
      symbol: symbol,
      date: today,
      content: content,
      shortTermScore: shortTermScore,
      mediumTermScore: mediumTermScore,
      longTermScore: longTermScore,
      summary: summary,
      otherOpinions: otherOpinions,
      userNote: userNote,
      checkPoints: points.isNotEmpty ? points : null,
    );
    await _repository.saveLog(log);
    
    // 현재 선택된 종목이라면 UI 갱신
    _stocks = await _repository.getAllStocks();
    await selectStock(symbol);
    notifyListeners();
  }

  // 체크포인트 체크 여부 토글
  Future<void> toggleCheckPoint(AnalysisCheckPoint point) async {
    if (_selectedLog == null || _selectedLog!.checkPoints == null) return;

    final updatedPoints = _selectedLog!.checkPoints!.map((p) {
      if (p.content == point.content && p.isPositive == point.isPositive) {
        return p.copyWith(isChecked: !p.isChecked);
      }
      return p;
    }).toList();

    final updatedLog = _selectedLog!.copyWith(checkPoints: updatedPoints);
    await _repository.saveLog(updatedLog);

    // UI 동기화
    final index = _currentStockLogs.indexOf(_selectedLog!);
    if (index != -1) {
      _currentStockLogs[index] = updatedLog;
      _selectedLog = updatedLog;
      notifyListeners();
    }
  }

  // 유저 개인의 매매 메모 저장
  Future<void> updateUserNote(String note) async {
    if (_selectedLog == null) return;

    final updatedLog = _selectedLog!.copyWith(userNote: note);
    await _repository.saveLog(updatedLog); // 같은 symbol+date면 덮어쓰기 로직 필요
    
    // UI 동기화
    final index = _currentStockLogs.indexOf(_selectedLog!);
    if (index != -1) {
      _currentStockLogs[index] = updatedLog;
      _selectedLog = updatedLog;
      notifyListeners();
    }
  }

  // 모든 분석 데이터 삭제 (내용만 비움)
  Future<void> clearAll() async {
    await _repository.clearAll();
    _stocks = [];
    _currentStockLogs = [];
    _selectedLog = null;
    notifyListeners();
  }

  // 데이터베이스 완전 삭제 (파일 삭제 후 초기화)
  Future<void> forceResetDatabase() async {
    _isLoading = true;
    notifyListeners();

    await _repository.forceDeleteFromDisk();

    _stocks = [];
    _currentStockLogs = [];
    _selectedLog = null;

    _isLoading = false;
    notifyListeners();
  }
}
