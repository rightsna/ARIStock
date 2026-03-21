import 'package:flutter/material.dart';
import '../models/consultation_model.dart';
import '../repositories/consultation_repository.dart';

class ConsultationProvider with ChangeNotifier {
  final ConsultationRepository _repository = ConsultationRepository();

  List<ConsultationStock> _stocks = [];
  List<ConsultationLog> _currentStockLogs = [];
  ConsultationLog? _selectedLog;
  bool _isLoading = false;

  List<ConsultationStock> get stocks => _stocks;
  List<ConsultationLog> get currentStockLogs => _currentStockLogs;
  ConsultationLog? get selectedLog => _selectedLog;
  bool get isLoading => _isLoading;

  // 초기 데이터 로드
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _stocks = await _repository.getAllStocks();
    
    if (_stocks.isNotEmpty) {
      await selectStock(_stocks.first.symbol);
    }

    _isLoading = false;
    notifyListeners();
  }

  // 종목 선택 및 해당 종목의 최신 로그 로드
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
  void selectLog(ConsultationLog log) {
    _selectedLog = log;
    notifyListeners();
  }

  Future<void> saveConsultation(String symbol, String name, String content) async {
    final stock = ConsultationStock(symbol: symbol, name: name);
    await _repository.addStock(stock);
    
    final today = DateTime.now().toIso8601String().split('T')[0];
    final log = ConsultationLog(
      stockSymbol: symbol,
      date: today,
      content: content,
    );
    await _repository.saveLog(log);
    
    // 현재 선택된 종목이라면 UI 갱신
    _stocks = await _repository.getAllStocks();
    await selectStock(symbol);
    notifyListeners();
  }

  // 모든 상담 데이터 삭제
  Future<void> clearAll() async {
    await _repository.clearAll();
    _stocks = [];
    _currentStockLogs = [];
    _selectedLog = null;
    notifyListeners();
  }
}
