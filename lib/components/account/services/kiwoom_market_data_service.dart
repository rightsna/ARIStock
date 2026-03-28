import '../../../shared/models/market/candle.dart';
import '../../../shared/models/market/market_tick.dart';
import '../../../shared/models/market/market_timeframe.dart';
import '../../../shared/services/technical/analyzer/candle_builder.dart';
import 'package:flutter/foundation.dart';
import 'kiwoom_market_service.dart';

/// 키움 원본 응답을 에이전트가 쓰기 좋은 표준 시장 데이터로 변환한다.
class KiwoomMarketDataService {
  final KiwoomMarketService _marketService;
  final List<DateTime> _callHistory = [];

  KiwoomMarketDataService(this._marketService);

  int getRequestsInLastMinute() {
    final now = DateTime.now();
    _callHistory.removeWhere((dt) => now.difference(dt).inSeconds > 60);
    return _callHistory.length;
  }

  void _recordCall() {
    _callHistory.add(DateTime.now());
  }

  Future<Map<String, dynamic>> fetchMarketData({
    required String symbol,
    required MarketTimeframe timeframe,
    int limit = 120,
  }) async {
    if (timeframe.isTick) {
      final ticks = await fetchTicks(symbol: symbol, limit: limit);
      return {
        'symbol': symbol,
        'timeframe': timeframe.protocolValue,
        'ticks': ticks.map((tick) => tick.toMap()).toList(),
      };
    }

    final candles = await fetchCandles(
      symbol: symbol,
      timeframe: timeframe,
      limit: limit,
    );

    return {
      'symbol': symbol,
      'timeframe': timeframe.protocolValue,
      'candles': candles.map((candle) => candle.toMap()).toList(),
    };
  }

  Future<List<Candle>> fetchCandles({
    required String symbol,
    required MarketTimeframe timeframe,
    int limit = 120,
  }) async {
    _recordCall();
    if (timeframe.isTick) {
      throw ArgumentError('Tick timeframe must be fetched with fetchTicks().');
    }

    final response = timeframe.isDay
        ? await _marketService.getStockDailyChart(
            stockCode: symbol,
            baseDate: _formatDate(DateTime.now()),
          )
        : await _marketService.getStockMinuteChart(
            stockCode: symbol,
            ticScope: timeframe.kiwoomMinuteScope,
          );

    if (!response.isSuccess) {
      throw StateError('API 요청 실패: ${response.statusCode} - ${response.body}');
    }

    final raw = _extractChartRows(response.body, apiId: timeframe.isDay ? 'ka10081' : 'ka10080');
    if (raw.isEmpty) {
      // 1. 서버 측 명시적 에러 메시지 확인 (KIS/키움/커스텀 브릿지 공통)
      final errorMsg = response.body['msg1'] ?? 
                      response.body['message'] ?? 
                      response.body['msg'] ?? 
                      response.body['err_msg'] ?? 
                      response.body['return_msg'];
      
      if (errorMsg != null) {
        throw StateError('브릿지 서버 에러: $errorMsg (TR: ${timeframe.protocolValue})');
      }

      // 2. 키는 존재하는데 리스트가 비어있는 경우인지 확인
      final List<String> emptyListKeys = [];
      response.body.forEach((k, v) {
        if (v is List && v.isEmpty) emptyListKeys.add(k);
      });

      final bodyStr = response.body.toString();
      final preview = bodyStr.length > 200 ? bodyStr.substring(0, 200) : bodyStr;

      if (emptyListKeys.isNotEmpty) {
        throw StateError('조회 결과 데이터가 비어 있습니다. (Empty Keys: $emptyListKeys, TR: ${timeframe.protocolValue})');
      }

      throw StateError('응답에서 데이터 리스트 필드를 찾을 수 없습니다. (Keys: ${response.body.keys.toList()}, Preview: $preview)');
    }

    final candles = CandleBuilder.fromKiwoomChartResponse(
      candles: raw,
      timeframe: timeframe.isDay ? 'D' : timeframe.kiwoomMinuteScope,
      baseDate: DateTime.now(),
    );

    if (candles.isEmpty) {
      if (raw.isNotEmpty) {
        debugPrint('🔵 DEBUG: Parsing failed. First raw item keys: ${raw.first.keys.toList()}');
        debugPrint('🔵 DEBUG: First raw item values: ${raw.first.values.toList()}');
      }
      throw StateError('데이터 파싱 결과가 비어 있습니다. (원본 개수: ${raw.length})');
    }

    return _takeLast(candles, limit);
  }

  Future<List<MarketTick>> fetchTicks({
    required String symbol,
    int limit = 60,
  }) async {
    _recordCall();
    final response = await _marketService.getStockTickChart(
      stockCode: symbol,
      ticScope: '1',
    );
    if (!response.isSuccess) {
      throw StateError('틱 데이터 조회 실패: ${response.body}');
    }

    final raw = _extractChartRows(response.body, apiId: 'ka10079');
    final now = DateTime.now();
    final ticks = <MarketTick>[];

    for (final item in raw) {
      final row = Map<String, dynamic>.from(item as Map);
      final timeStr = row['stck_cntg_hour']?.toString() ?? '';
      final timestamp = _parseTickTimestamp(timeStr, now);
      final price = _readDouble(
        row['cur_prc'] ?? row['stck_prpr'] ?? row['stck_clpr'],
      );
      final volume = _readInt(row['cntg_vol'] ?? row['acml_vol']);

      ticks.add(MarketTick(
        timestamp: timestamp,
        price: price,
        volume: volume,
      ));
    }

    ticks.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (ticks.length <= limit) return ticks;
    return ticks.sublist(ticks.length - limit);
  }

  List<dynamic> _extractChartRows(Map<String, dynamic> body, {String? apiId}) {
    // 1. 하드코딩된 주요 후보 키 먼저 확인
    final candidateKeys = [
      'output2', 'output', 'output1', 
      'stk_dt_pole_chart_qry', 'stk_min_pole_chart_qry',
      'data', 'result', 'outputs', 'grid', 'records',
      if (apiId != null) apiId, // TR명 자체가 키인 경우 대응
    ];

    for (final key in candidateKeys) {
      final value = body[key];
      if (value is List && value.isNotEmpty) {
        return value;
      }
      // 가끔 'output': { 'data': [...] } 형태가 있음
      if (value is Map) {
        for (final subKey in ['data', 'list', 'grid', 'output2']) {
          if (value[subKey] is List && (value[subKey] as List).isNotEmpty) {
            return value[subKey];
          }
        }
      }
    }

    // 2. (강력한 폴백) 응답 구조 전체를 재귀적으로 탐색하여 가장 긴 리스트를 반환
    List<dynamic>? longestList;
    int maxLength = 0;

    void findLongestList(dynamic current) {
      if (current is List) {
        if (current.length > maxLength) {
          maxLength = current.length;
          longestList = current;
        }
      } else if (current is Map) {
        for (final val in current.values) {
          findLongestList(val);
        }
      }
    }

    findLongestList(body);
    return longestList ?? const [];
  }

  List<Candle> _takeLast(List<Candle> candles, int limit) {
    if (candles.length <= limit) return candles;
    return candles.sublist(candles.length - limit);
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  double _readDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  int _readInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  DateTime _parseTickTimestamp(String timeStr, DateTime baseDate) {
    if (timeStr.length != 6) return baseDate;

    final hour = int.tryParse(timeStr.substring(0, 2)) ?? 0;
    final minute = int.tryParse(timeStr.substring(2, 4)) ?? 0;
    final second = int.tryParse(timeStr.substring(4, 6)) ?? 0;

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
      second,
    );
  }
}
