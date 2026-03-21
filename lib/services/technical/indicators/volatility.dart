import 'dart:math';

import '../../../models/market/candle.dart';
import '../../../models/technical/indicator_results.dart';
import 'base_indicator.dart';
import 'moving_average.dart';

/// ATR (Average True Range) - 변동성 지표
/// 기간 내 평균 변동폭으로 변동성 측정
class AverageTrueRange extends BaseIndicator {
  final int period;

  AverageTrueRange({this.period = 14});

  @override
  ATRResult calculate(List<Candle> candles) {
    if (candles.length < period + 1) {
      return ATRResult(value: 0);
    }

    final atrValues = calculateAll(candles);
    final atr = atrValues.lastWhere((value) => value != null, orElse: () => 0) ?? 0;

    return ATRResult(value: atr);
  }

  /// 모든 ATR 값 반환
  List<double?> calculateAll(List<Candle> candles) {
    if (candles.length < period + 1) {
      return List.filled(candles.length, null);
    }

    final trueRanges = <double>[];
    for (int i = 1; i < candles.length; i++) {
      trueRanges.add(
        candles[i].trueRangeFromPreviousClose(candles[i - 1].close),
      );
    }

    final smoothed = MovingAverage.sma(trueRanges, period);
    final result = List<double?>.filled(candles.length, null);
    for (int i = 0; i < smoothed.length; i++) {
      result[i + 1] = smoothed[i];
    }
    return result;
  }
}

/// Bollinger Bands - 변동성 지표
/// 이동평균 ± N표준편차로 지지/저항선 표시
class BollingerBands extends BaseIndicator {
  final int period;
  final double stdDev;  // 표준편차 배수 (일반적으로 2)

  BollingerBands({
    this.period = 20,
    this.stdDev = 2.0,
  });

  @override
  BollingerBandsResult calculate(List<Candle> candles) {
    if (candles.length < period) {
      final lastClose = candles.last.close;
      return BollingerBandsResult(
        upperBand: lastClose * 1.1,
        middleBand: lastClose,
        lowerBand: lastClose * 0.9,
        lastClose: lastClose,
      );
    }

    // 1. 중심선 (기간별 SMA)
    final closePrices = candles.map((c) => c.close).toList();
    final smaValues = MovingAverage.sma(closePrices, period);
    final middleBand = smaValues.lastWhere((s) => s != null) ?? candles.last.close;

    // 2. 표준편차 계산
    final lastWindow = closePrices.sublist(closePrices.length - period);
    final mean = lastWindow.reduce((a, b) => a + b) / period;
    final variance = lastWindow
            .map((p) => (p - mean) * (p - mean))
            .fold<double>(0, (a, b) => a + b) /
        period;
    final stdValue = variance.isNaN ? 0.0 : sqrt(variance);

    // 3. 상단/하단 밴드
    final upperBand = middleBand + (stdValue * stdDev);
    final lowerBand = middleBand - (stdValue * stdDev);

    return BollingerBandsResult(
      upperBand: upperBand,
      middleBand: middleBand,
      lowerBand: lowerBand,
      lastClose: candles.last.close,
    );
  }

  /// 모든 Bollinger Bands 값 반환
  Map<String, List<double?>> calculateAll(List<Candle> candles) {
    if (candles.length < period) {
      return {
        'upper': List.filled(candles.length, null),
        'middle': List.filled(candles.length, null),
        'lower': List.filled(candles.length, null),
      };
    }

    final closePrices = candles.map((c) => c.close).toList();
    final smaValues = MovingAverage.sma(closePrices, period);

    final upperBands = List<double?>.filled(candles.length, null);
    final lowerBands = List<double?>.filled(candles.length, null);

    for (int i = period - 1; i < candles.length; i++) {
      final window = closePrices.sublist(i - period + 1, i + 1);
      final mean = window.reduce((a, b) => a + b) / period;
      final variance = window
              .map((p) => (p - mean) * (p - mean))
              .fold<double>(0, (a, b) => a + b) /
          period;
      final stdVal = variance.isNaN ? 0.0 : sqrt(variance);

      if (smaValues[i] != null) {
        upperBands[i] = smaValues[i]! + (stdVal * stdDev);
        lowerBands[i] = smaValues[i]! - (stdVal * stdDev);
      }
    }

    return {
      'upper': upperBands,
      'middle': smaValues,
      'lower': lowerBands,
    };
  }
}

/// Keltner Channel - 변동성 기반 채널
/// ATR을 이용한 동적 채널
class KeltnerChannel extends BaseIndicator {
  final int period;
  final double atrMultiplier;

  KeltnerChannel({
    this.period = 20,
    this.atrMultiplier = 2.0,
  });

  @override
  Map<String, dynamic> calculate(List<Candle> candles) {
    if (candles.length < period) {
      final lastClose = candles.last.close;
      return {
        'upper': lastClose * 1.05,
        'middle': lastClose,
        'lower': lastClose * 0.95,
      };
    }

    // 중심: EMA
    final closePrices = candles.map((c) => c.close).toList();
    final emaValues = MovingAverage.ema(closePrices, period);
    final middle = emaValues.lastWhere((e) => e != null) ?? candles.last.close;

    // ATR 계산
    final atr = AverageTrueRange(period: period).calculate(candles).value;

    return {
      'upper': middle + (atr * atrMultiplier),
      'middle': middle,
      'lower': middle - (atr * atrMultiplier),
    };
  }
}
