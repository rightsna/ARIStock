import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/trading_record_model.dart';

class TradingRecordProvider with ChangeNotifier {
  late Box<TradingRecord> _box;
  List<TradingRecord> _records = [];
  bool _initialized = false;

  List<TradingRecord> get records => _records;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox<TradingRecord>('trading_records_box');
    _loadRecords();
    _initialized = true;
    notifyListeners();
  }

  void _loadRecords() {
    _records = _box.values.toList();
    // 최신순 정렬
    _records.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
  }

  Future<void> addRecord(TradingRecord record) async {
    await _box.add(record);
    _loadRecords();
    notifyListeners();
  }

  Future<void> deleteRecord(int index) async {
    await _box.deleteAt(index);
    _loadRecords();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _loadRecords();
    notifyListeners();
  }

  List<TradingRecord> getRecordsForSymbol(String symbol) {
    return _records.where((r) => r.symbol == symbol).toList();
  }
}
