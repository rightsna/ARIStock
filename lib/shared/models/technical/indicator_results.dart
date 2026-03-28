import 'dart:math';
import '../../models/market/candle.dart';

/// 이동평균 결과
class MovingAverageResult {
  final Map<int, double> values; // {기간: 값}

  MovingAverageResult({required this.values});

  /// 단순 이동평균 (SMA)
  static List<double?> sma(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);
    final result = List<double?>.filled(prices.length, null);
    for (int i = period - 1; i < prices.length; i++) {
      final sum =
          prices.sublist(i - period + 1, i + 1).fold<double>(0, (a, b) => a + b);
      result[i] = sum / period;
    }
    return result;
  }

  /// 지수 이동평균 (EMA)
  static List<double?> ema(List<double> prices, int period) {
    if (prices.length < period) return List.filled(prices.length, null);
    final result = List<double?>.filled(prices.length, null);
    final multiplier = 2.0 / (period + 1);
    double emaValue =
        prices.sublist(0, period).fold<double>(0, (a, b) => a + b) / period;
    result[period - 1] = emaValue;
    for (int i = period; i < prices.length; i++) {
      emaValue = prices[i] * multiplier + emaValue * (1 - multiplier);
      result[i] = emaValue;
    }
    return result;
  }

  /// 특정 기간의 이동평균 값
  double? get(int period) => values[period];

  Map<String, dynamic> toMap() => {
    'values': values.map((k, v) => MapEntry(k.toString(), v)),
  };
}

/// RSI 결과
class RSIResult {
  final double value; // 0-100
  final bool isOverbought; // > 70
  final bool isOversold; // < 30

  RSIResult({required this.value})
    : isOverbought = value > 70,
      isOversold = value < 30;

  factory RSIResult.fromCandles(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return RSIResult(value: 50);

    double gainSum = 0;
    double lossSum = 0;

    for (int i = 1; i <= period; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change >= 0) {
        gainSum += change;
      } else {
        lossSum += -change;
      }
    }

    double averageGain = gainSum / period;
    double averageLoss = lossSum / period;

    for (int i = period + 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? -change : 0.0;
      averageGain = ((averageGain * (period - 1)) + gain) / period;
      averageLoss = ((averageLoss * (period - 1)) + loss) / period;
    }

    if (averageLoss == 0) return RSIResult(value: 100);
    final rs = averageGain / averageLoss;
    return RSIResult(value: 100 - (100 / (1 + rs)));
  }

  Map<String, dynamic> toMap() => {
    'value': value.isFinite ? value : 50.0,
    'isOverbought': isOverbought,
    'isOversold': isOversold,
  };
}

/// MACD 결과
class MacdResult {
  final double macdLine;
  final double signalLine;
  final double histogram; // MACD - Signal
  final bool isBullish; // MACD > Signal

  MacdResult({required this.macdLine, required this.signalLine})
    : histogram = macdLine - signalLine,
      isBullish = macdLine > signalLine;

  factory MacdResult.fromCandles(
    List<Candle> candles, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (candles.length < slowPeriod + signalPeriod - 1) {
      return MacdResult(macdLine: 0, signalLine: 0);
    }

    final closePrices = candles.map((c) => c.close).toList();
    final fastEMA = MovingAverageResult.ema(closePrices, fastPeriod);
    final slowEMA = MovingAverageResult.ema(closePrices, slowPeriod);

    final macdLineSeries = <double?>[];
    for (int i = 0; i < fastEMA.length; i++) {
      if (fastEMA[i] != null && slowEMA[i] != null) {
        macdLineSeries.add(fastEMA[i]! - slowEMA[i]!);
      } else {
        macdLineSeries.add(null);
      }
    }

    final macdValues = macdLineSeries.whereType<double>().toList();
    final signalSeries = MovingAverageResult.ema(macdValues, signalPeriod);

    final lastMacd =
        macdLineSeries.lastWhere((v) => v != null, orElse: () => 0) ?? 0;
    final lastSignal =
        signalSeries.lastWhere((v) => v != null, orElse: () => 0) ?? 0;

    return MacdResult(macdLine: lastMacd, signalLine: lastSignal);
  }

  Map<String, dynamic> toMap() => {
    'macdLine': macdLine,
    'signalLine': signalLine,
    'histogram': histogram,
    'isBullish': isBullish,
  };
}

/// Bollinger Bands 결과
class BollingerBandsResult {
  final double upperBand;
  final double middleBand;
  final double lowerBand;
  final double bandwidthRatio;
  final bool isAtTop; // 종가가 상단에 가까움
  final bool isAtBottom; // 종가가 하단에 가까움
  final double squeeze; // 밴드폭 축소 정도 (0-1)

  BollingerBandsResult({
    required this.upperBand,
    required this.middleBand,
    required this.lowerBand,
    required double lastClose,
  }) : bandwidthRatio =
           middleBand == 0 ? 0 : (upperBand - lowerBand) / middleBand,
       isAtTop = lastClose > middleBand + (upperBand - middleBand) * 0.8,
       isAtBottom = lastClose < middleBand - (middleBand - lowerBand) * 0.8,
       squeeze =
           1 /
           (1 + (middleBand == 0 ? 0 : (upperBand - lowerBand) / middleBand));

  factory BollingerBandsResult.fromCandles(
    List<Candle> candles, {
    int period = 20,
    double stdDev = 2.0,
  }) {
    final lastClose = candles.last.close;
    if (candles.length < period) {
      return BollingerBandsResult(
        upperBand: lastClose * 1.1,
        middleBand: lastClose,
        lowerBand: lastClose * 0.9,
        lastClose: lastClose,
      );
    }

    final closePrices = candles.map((c) => c.close).toList();
    final smaValues = MovingAverageResult.sma(closePrices, period);
    final middle = smaValues.lastWhere((s) => s != null) ?? lastClose;

    final lastWindow = closePrices.sublist(closePrices.length - period);
    final mean = lastWindow.reduce((a, b) => a + b) / period;
    final variance =
        lastWindow
            .map((p) => (p - mean) * (p - mean))
            .fold<double>(0, (a, b) => a + b) /
        period;
    final stdValue = variance.isNaN ? 0.0 : sqrt(variance);

    return BollingerBandsResult(
      upperBand: middle + (stdValue * stdDev),
      middleBand: middle,
      lowerBand: middle - (stdValue * stdDev),
      lastClose: lastClose,
    );
  }

  Map<String, dynamic> toMap() => {
    'upperBand': upperBand.isFinite ? upperBand : 0.0,
    'middleBand': middleBand.isFinite ? middleBand : 0.0,
    'lowerBand': lowerBand.isFinite ? lowerBand : 0.0,
    'bandwidthRatio': bandwidthRatio.isFinite ? bandwidthRatio : 0.0,
    'isAtTop': isAtTop,
    'isAtBottom': isAtBottom,
    'squeeze': squeeze.isFinite ? squeeze : 1.0,
  };
}

/// ATR (Average True Range) 결과 - 변동성
class ATRResult {
  final double value;
  final bool isHighVolatility; // 평년대비 높음

  ATRResult({required this.value, this.isHighVolatility = false});

  factory ATRResult.fromCandles(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return ATRResult(value: 0);

    final trueRanges = <double>[];
    for (int i = 1; i < candles.length; i++) {
      trueRanges.add(
        candles[i].trueRangeFromPreviousClose(candles[i - 1].close),
      );
    }

    final smoothed = MovingAverageResult.sma(trueRanges, period);
    final atr = smoothed.lastWhere((v) => v != null, orElse: () => 0) ?? 0;

    return ATRResult(value: atr);
  }

  Map<String, dynamic> toMap() => {
    'value': value,
    'isHighVolatility': isHighVolatility,
  };
}

/// VWAP 결과
class VWAPResult {
  final double value;

  VWAPResult({required this.value});

  factory VWAPResult.fromCandles(List<Candle> candles) {
    if (candles.isEmpty) return VWAPResult(value: 0);

    double typicalPriceVolume = 0;
    int totalVolume = 0;

    for (final candle in candles) {
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      typicalPriceVolume += typicalPrice * candle.volume;
      totalVolume += candle.volume;
    }

    return VWAPResult(value: totalVolume > 0 ? typicalPriceVolume / totalVolume : 0);
  }

  Map<String, dynamic> toMap() => {
    'value': value,
  };
}

/// 거래량 분석 결과
class VolumeAnalysisResult {
  final double averageVolume;
  final double currentVolumeRatio; // 현재 거래량 / 평균 (1.0 = 평년대비 동일)
  final bool isSpike; // 거래량 스파이크 (> 2배)

  VolumeAnalysisResult({
    required this.averageVolume,
    required this.currentVolumeRatio,
  }) : isSpike = currentVolumeRatio > 2.0;

  factory VolumeAnalysisResult.fromCandles(List<Candle> candles, {int period = 20}) {
    if (candles.isEmpty) {
      return VolumeAnalysisResult(averageVolume: 0, currentVolumeRatio: 1.0);
    }
    final historicalCandles =
        candles.length > 1 ? candles.sublist(0, candles.length - 1) : candles;
    final recentCandles =
        historicalCandles.length >= period
            ? historicalCandles.sublist(historicalCandles.length - period)
            : historicalCandles;
    if (recentCandles.isEmpty) {
      return VolumeAnalysisResult(averageVolume: 0, currentVolumeRatio: 1.0);
    }
    final avgVolume =
        recentCandles.map((c) => c.volume).fold<double>(0, (a, b) => a + b) /
        recentCandles.length;
    final currentVolume = candles.last.volume.toDouble();
    final ratio = avgVolume > 0 ? currentVolume / avgVolume : 1.0;
    return VolumeAnalysisResult(averageVolume: avgVolume, currentVolumeRatio: ratio);
  }

  Map<String, dynamic> toMap() => {
    'averageVolume': averageVolume,
    'currentVolumeRatio': currentVolumeRatio,
    'isSpike': isSpike,
  };
}

/// 추세 분석 결과
class TrendResult {
  final String direction; // "UP", "DOWN", "NEUTRAL"
  final double slope; // 기울기 (양수=상승, 음수=하락)
  final double strength; // 추세 강도 (0-1)

  TrendResult({
    required this.direction,
    required this.slope,
    required this.strength,
  });

  factory TrendResult.fromCandles(List<Candle> candles, {int period = 20}) {
    if (candles.length < 5) {
      return TrendResult(direction: 'NEUTRAL', slope: 0, strength: 0);
    }
    final window =
        candles.length > period
            ? candles.sublist(candles.length - period)
            : candles;
    final closePrices = window.map((c) => c.close).toList();

    // 선형 회귀 기울기 계산
    final n = closePrices.length.toDouble();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (int i = 0; i < closePrices.length; i++) {
      sumX += i;
      sumY += closePrices[i];
      sumXY += i * closePrices[i];
      sumX2 += i * i;
    }

    final denominator = (n * sumX2) - (sumX * sumX);
    final slope =
        denominator == 0 ? 0.0 : ((n * sumXY) - (sumX * sumY)) / denominator;

    // R² (결정계수) 계산 - 추세 강도
    final mean = sumY / n;
    final ssTot = closePrices.fold<double>(
      0,
      (sum, p) => sum + pow(p - mean, 2).toDouble(),
    );
    final intercept = mean - (slope * (n - 1) / 2);
    final ssRes = closePrices.asMap().entries.fold<double>(0, (sum, entry) {
      final predicted = slope * entry.key + intercept;
      return sum + pow(entry.value - predicted, 2).toDouble();
    });
    final strength = ssTot == 0 ? 0.0 : (1 - (ssRes / ssTot)).clamp(0, 1).toDouble();

    String direction = 'NEUTRAL';
    if (slope > 0.5) direction = 'UP';
    if (slope < -0.5) direction = 'DOWN';

    return TrendResult(direction: direction, slope: slope, strength: strength);
  }

  Map<String, dynamic> toMap() => {
    'direction': direction,
    'slope': slope,
    'strength': strength,
  };
}
