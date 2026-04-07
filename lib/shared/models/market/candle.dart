import 'dart:math';
import 'package:flutter/foundation.dart';

/// OHLCV 캔들 데이터 모델
/// 모든 기술적 지표의 기반이 되는 표준화된 가격 데이터
class Candle {
  final DateTime timestamp;
  final double open;      // 시가
  final double high;      // 고가
  final double low;       // 저가
  final double close;     // 종가
  final int volume;       // 거래량

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// 캔들 몸통 크기 (종가 - 시가)
  double get bodySize => (close - open).abs();

  /// 상승 캔들 여부
  bool get isBullish => close >= open;

  /// 하락 캔들 여부
  bool get isBearish => close < open;

  /// 범위 (고가 - 저가)
  double get range => high - low;

  /// 이전 종가를 기준으로 계산한 True Range
  double trueRangeFromPreviousClose(double previousClose) {
    final highLow = high - low;
    final highClose = (high - previousClose).abs();
    final lowClose = (low - previousClose).abs();
    return [highLow, highClose, lowClose].reduce((a, b) => a > b ? a : b);
  }

  /// 종가가 범위에서 차지하는 비율 (0~1)
  double get closeRatio {
    if (range == 0) return 0.5;
    return (close - low) / range;
  }

  /// 맵으로 변환 (JSON 직렬화용)
  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      };

  /// 맵에서 생성
  factory Candle.fromMap(Map<String, dynamic> map) {
    return Candle(
      timestamp: DateTime.parse(
        map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      open: (map['open'] as num).toDouble(),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
      volume: map['volume'] as int? ?? 0,
    );
  }

  /// 키움 API의 차트 데이터 응답을 Candle 리스트로 변환
  static List<Candle> fromKiwoomList({
    required List<dynamic> candles,
    required String timeframe, // '1', '5', '60', 'D', 'W', 'M'
    DateTime? baseDate, // 일봉 이상에서 필요
  }) {
    final result = <Candle>[];
    for (final item in candles) {
      try {
        final candle = _parseKiwoomCandle(
          Map<String, dynamic>.from(item as Map),
          timeframe,
          baseDate,
        );
        if (candle != null) result.add(candle);
      } catch (e) {
        debugPrint('Error parsing candle: $e');
      }
    }
    // 오래된 날짜부터 정렬
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }

  static Candle? _parseKiwoomCandle(
    Map<String, dynamic> itemMap,
    String timeframe,
    DateTime? baseDate,
  ) {
    try {
      dynamic getVal(String key) =>
          itemMap[key] ?? itemMap[key.toLowerCase()] ?? itemMap[key.toUpperCase()];

      final close =
          double.tryParse(
                (getVal('stck_clpr') ??
                        getVal('stk_clpr') ??
                        getVal('cur_prc') ??
                        '0')
                    .toString(),
              )?.abs() ??
              0;
      final open =
          double.tryParse(
                (getVal('stck_oprc') ??
                        getVal('stk_oprc') ??
                        getVal('open_pric') ??
                        '0')
                    .toString(),
              )?.abs() ??
              0;
      final high =
          double.tryParse(
                (getVal('stck_hgpr') ??
                        getVal('stk_hgpr') ??
                        getVal('high_pric') ??
                        '0')
                    .toString(),
              )?.abs() ??
              0;
      final low =
          double.tryParse(
                (getVal('stck_lwpr') ??
                        getVal('stk_lwpr') ??
                        getVal('low_pric') ??
                        '0')
                    .toString(),
              )?.abs() ??
              0;
      final volume =
          int.tryParse(
                (getVal('cntg_vol') ??
                        getVal('stck_cntg_vol') ??
                        getVal('acml_vol') ??
                        getVal('trde_qty') ??
                        '0')
                    .toString(),
              )?.abs().toInt() ??
              0;

      late DateTime timestamp;
      if (timeframe == 'D' || timeframe == 'W' || timeframe == 'M') {
        var dateStr =
            (getVal('stck_bsop_date') ?? getVal('stk_bsop_date') ?? getVal('dt') ?? '')
                .toString();
        if (dateStr.length == 8) {
          final year = int.parse(dateStr.substring(0, 4));
          final month = int.parse(dateStr.substring(4, 6));
          final day = int.parse(dateStr.substring(6, 8));
          timestamp = DateTime(year, month, day);
        } else if (baseDate != null) {
          timestamp = baseDate;
        } else {
          return null;
        }
      } else {
        var timeStr =
            (getVal('stck_cntg_hour') ?? getVal('stk_cntg_hour') ?? '')
                .toString();
        var fullTimeStr = getVal('cntr_tm')?.toString() ?? '';
        if (fullTimeStr.length == 14) {
          final year = int.parse(fullTimeStr.substring(0, 4));
          final month = int.parse(fullTimeStr.substring(4, 6));
          final day = int.parse(fullTimeStr.substring(6, 8));
          final hour = int.parse(fullTimeStr.substring(8, 10));
          final minute = int.parse(fullTimeStr.substring(10, 12));
          final second = int.parse(fullTimeStr.substring(12, 14));
          timestamp = DateTime(year, month, day, hour, minute, second);
        } else {
          if (timeStr.length == 5) timeStr = '0$timeStr';
          if (timeStr.length != 6 || baseDate == null) return null;
          final hour = int.parse(timeStr.substring(0, 2));
          final minute = int.parse(timeStr.substring(2, 4));
          final second = int.parse(timeStr.substring(4, 6));
          timestamp = baseDate.copyWith(
            hour: hour,
            minute: minute,
            second: second,
          );
        }
      }

      return Candle(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    } catch (e) {
      return null;
    }
  }

  /// 시간프레임 변환 (예: 1분 -> 5분)
  static List<Candle> mergeToTimeframe(
    List<Candle> candles,
    int targetMinutes,
  ) {
    if (candles.length < targetMinutes) return candles;
    final sorted = [...candles]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final buckets = <DateTime, List<Candle>>{};
    for (final candle in sorted) {
      final bucketTime = DateTime(
        candle.timestamp.year,
        candle.timestamp.month,
        candle.timestamp.day,
        candle.timestamp.hour,
        (candle.timestamp.minute ~/ targetMinutes) * targetMinutes,
      );
      buckets.putIfAbsent(bucketTime, () => <Candle>[]).add(candle);
    }
    return buckets.entries.map((entry) {
      final batch = entry.value;
      return Candle(
        timestamp: entry.key,
        open: batch.first.open,
        high: batch.map((c) => c.high).reduce(max),
        low: batch.map((c) => c.low).reduce(min),
        close: batch.last.close,
        volume: batch.fold<int>(0, (sum, c) => sum + c.volume),
      );
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
