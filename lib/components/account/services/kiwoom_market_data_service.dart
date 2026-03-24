import '../../../shared/models/market/candle.dart';
import '../../../shared/models/market/market_tick.dart';
import '../../../shared/models/market/market_timeframe.dart';
import '../../../shared/services/technical/analyzer/candle_builder.dart';
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

    final raw = _extractChartRows(response.body);
    if (raw.isEmpty) {
      final bodyStr = response.body.toString();
      final preview = bodyStr.length > 100 ? bodyStr.substring(0, 100) : bodyStr;
      // 디버깅을 위해 에러 메시지에 응답 본문 키 포함
      throw StateError('데이터 필드를 찾을 수 없습니다. (Keys: ${response.body.keys.toList()}, Preview: $preview)');
    }

    final candles = CandleBuilder.fromKiwoomChartResponse(
      candles: raw,
      timeframe: timeframe.isDay ? 'D' : timeframe.kiwoomMinuteScope,
      baseDate: DateTime.now(),
    );

    if (candles.isEmpty) {
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

    final raw = _extractChartRows(response.body);
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

  List<dynamic> _extractChartRows(Map<String, dynamic> body) {
    // 1. 하드코딩된 주요 후보 키 먼저 확인
    const candidateKeys = [
      'output2', 'output', 'output1', 
      'stk_dt_pole_chart_qry', 'stk_min_pole_chart_qry',
      'data', 'result'
    ];

    for (final key in candidateKeys) {
      if (body[key] is List && (body[key] as List).isNotEmpty) {
        return body[key];
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
