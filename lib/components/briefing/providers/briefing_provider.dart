import 'package:flutter/material.dart';
import '../models/briefing_model.dart';
import '../repositories/briefing_repository.dart';

class BriefingProvider with ChangeNotifier {
  final BriefingRepository _repository = BriefingRepository();
  
  Briefing? _currentBriefing;
  final List<Briefing> _history = [];
  bool _isLoading = false;

  Briefing? get currentBriefing => _currentBriefing;
  List<Briefing> get history => _history;
  bool get isLoading => _isLoading;

  // 오늘 날짜의 브리핑 로드
  Future<void> loadTodayBriefing() async {
    _isLoading = true;
    notifyListeners();

    final today = DateTime.now().toIso8601String().split('T')[0];
    _currentBriefing = await _repository.getBriefing(today);
    
    _isLoading = false;
    notifyListeners();
  }

  // 특정 날짜 브리핑 로드
  Future<void> loadBriefingByDate(String date) async {
    _currentBriefing = await _repository.getBriefing(date);
    notifyListeners();
  }

  // 브리핑 저장
  Future<void> saveBriefing(String date, String content) async {
    final briefing = Briefing(date: date, content: content);
    await _repository.saveBriefing(briefing);
    if (date == DateTime.now().toIso8601String().split('T')[0]) {
      _currentBriefing = briefing;
    }
    notifyListeners();
  }

  // 모든 브리핑 삭제
  Future<void> clearAll() async {
    await _repository.clearAll();
    _currentBriefing = null;
    notifyListeners();
  }
}
