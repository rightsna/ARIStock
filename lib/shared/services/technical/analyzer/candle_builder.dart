import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../models/market/candle.dart';

/// 키움 API 응답 데이터를 Candle 모델로 변환하는 유틸리티
class CandleBuilder {
  /// 키움 API의 차트 데이터 응답을 Candle 리스트로 변환
  /// API 응답 형식:
  /// {
  ///   "output": [
  ///     {
  ///       "stck_cntg_hour": "093000",      // 시간 (HHmmss)
  ///       "stck_clpr": 45000,              // 종가
  ///       "stck_oprc": 44900,              // 시가
  ///       "stck_hgpr": 45200,              // 고가
  ///       "stck_lwpr": 44800,              // 저가
  ///       "cntg_vol": 150000,              // 거래량
  ///       "acml_vol": 1500000              // 누적거래량
  ///     }
  ///   ]
  /// }
  static List<Candle> fromKiwoomChartResponse({
    required List<dynamic> candles,
    required String timeframe,  // '1', '5', '60', 'D', 'W', 'M'
    DateTime? baseDate,  // 일봉 이상에서 필요
  }) {
    final result = <Candle>[];

    for (final item in candles) {
      try {
        final candle = _parseKiwoomCandle(
          item as Map<String, dynamic>,
          timeframe,
          baseDate,
        );
        if (candle != null) result.add(candle);
      } catch (e) {
        debugPrint('Error parsing candle: $e');
      }
    }

    // 새로운 순서로 정렬 (오래된 → 최신)
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }

  /// 개별 캔들 파싱
  static Candle? _parseKiwoomCandle(
    Map<String, dynamic> item,
    String timeframe,
    DateTime? baseDate,
  ) {
    try {
      // 키 이름 대문자/소문자 모두 지원
      final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
      
      dynamic getVal(String key) => itemMap[key] ?? itemMap[key.toLowerCase()] ?? itemMap[key.toUpperCase()];

      final close = double.tryParse((getVal('stck_clpr') ?? getVal('stk_clpr') ?? '0').toString()) ?? 0;
      final open = double.tryParse((getVal('stck_oprc') ?? getVal('stk_oprc') ?? '0').toString()) ?? 0;
      final high = double.tryParse((getVal('stck_hgpr') ?? getVal('stk_hgpr') ?? '0').toString()) ?? 0;
      final low = double.tryParse((getVal('stck_lwpr') ?? getVal('stk_lwpr') ?? '0').toString()) ?? 0;
      final volume = int.tryParse((getVal('cntg_vol') ?? getVal('stck_cntg_vol') ?? getVal('acml_vol') ?? '0').toString()) ?? 0;

      // 시간 파싱
      late DateTime timestamp;

      if (timeframe == 'D' || timeframe == 'W' || timeframe == 'M') {
        // 일봉, 주봉, 월봉: stck_bsop_date 사용 (YYYYMMDD 형식)
        var dateStr = (getVal('stck_bsop_date') ?? getVal('stk_bsop_date') ?? '').toString();
        if (dateStr.length == 8) {
          final year = int.parse(dateStr.substring(0, 4));
          final month = int.parse(dateStr.substring(4, 6));
          final day = int.parse(dateStr.substring(6, 8));
          timestamp = DateTime(year, month, day);
        } else if (baseDate != null) {
          timestamp = baseDate;
        } else {
          return null; // 시간 정보 없음
        }
      } else {
        // 분봉: stck_cntg_hour 사용 (HHmmss 형식) + baseDate
        var timeStr = (getVal('stck_cntg_hour') ?? getVal('stk_cntg_hour') ?? '').toString();
        // 5자리 시간(93000)을 6자리(093000)로 보정
        if (timeStr.length == 5) timeStr = '0$timeStr';
        
        if (timeStr.length != 6 || baseDate == null) {
          return null;
        }

        final hour = int.parse(timeStr.substring(0, 2));
        final minute = int.parse(timeStr.substring(2, 4));
        final second = int.parse(timeStr.substring(4, 6));

        timestamp = baseDate.copyWith(hour: hour, minute: minute, second: second);
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
      debugPrint('Error parsing individual candle: $e');
      return null;
    }
  }

  /// 분봉 데이터로부터 더 큰 시간프레임 캔들 생성
  /// 예: 1분 캔들 5개 → 5분 캔들 1개
  static List<Candle> convertTimeframe(
    List<Candle> candles,
    int targetMinutes,
  ) {
    if (candles.length < targetMinutes) return candles;

    final sortedCandles = [...candles]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final buckets = <DateTime, List<Candle>>{};

    for (final candle in sortedCandles) {
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
      final open = batch.first.open;
      final close = batch.last.close;
      final high = batch.map((c) => c.high).reduce(max);
      final low = batch.map((c) => c.low).reduce(min);
      final volume = batch.fold<int>(0, (sum, candle) => sum + candle.volume);

      return Candle(
        timestamp: entry.key,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 매뉴얼 입력으로 캔들 생성 (테스트용/수기 입력용)
  static Candle create({
    required DateTime timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    int volume = 0,
  }) {
    return Candle(
      timestamp: timestamp,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }

  /// 여러 캔들이 유효한지 검증
  static bool isValid(List<Candle> candles) {
    if (candles.isEmpty) return false;

    for (final candle in candles) {
      if (candle.high < candle.low) return false;
      if (candle.open < 0 || candle.close < 0) return false;
      if (candle.volume < 0) return false;
    }

    return true;
  }

  /// 캔들 데이터 요약 출력 (디버깅용)
  static void printCandlesSummary(List<Candle> candles) {
    if (candles.isEmpty) {
      debugPrint('No candles');
      return;
    }

    debugPrint('Candles Summary:');
    debugPrint('  Count: ${candles.length}');
    debugPrint('  Range: ${candles.first.timestamp} ~ ${candles.last.timestamp}');
    debugPrint(
      '  Price Range: ${candles.map((c) => c.low).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} ~ ${candles.map((c) => c.high).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}',
    );
    debugPrint(
      '  Total Volume: ${candles.map((c) => c.volume).fold<int>(0, (a, b) => a + b)}',
    );
  }
}
