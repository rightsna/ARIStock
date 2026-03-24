import 'dart:math';

import '../../../models/market/candle.dart';
import '../../../models/technical/indicator_results.dart';
import 'base_indicator.dart';

/// 추세 분석 - 가격 추세의 방향과 강도 측정
class TrendAnalyzer extends BaseIndicator {
  final int period;

  TrendAnalyzer({this.period = 20});

  @override
  TrendResult calculate(List<Candle> candles) {
    if (candles.length < period) {
      return TrendResult(
        direction: 'NEUTRAL',
        slope: 0,
        strength: 0,
      );
    }

    // 선형 회귀로 기울기 계산
    final closePrices = candles.map((c) => c.close).toList();
    final recentPrices = closePrices.sublist(closePrices.length - period);

    // 기울기 계산 (선형 회귀)
    final slope = _calculateSlope(recentPrices);

    // 방향 결정
    String direction;
    if (slope > 0.5) {
      direction = 'UP';
    } else if (slope < -0.5) {
      direction = 'DOWN';
    } else {
      direction = 'NEUTRAL';
    }

    // 강도 계산 (R² 값)
    final strength = _calculateRSquared(recentPrices);

    return TrendResult(
      direction: direction,
      slope: slope,
      strength: strength,
    );
  }

  /// 선형 회귀 기울기 계산
  double _calculateSlope(List<double> prices) {
    if (prices.length < 2) return 0;

    final n = prices.length.toDouble();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;

    for (int i = 0; i < prices.length; i++) {
      sumX += i;
      sumY += prices[i];
      sumXY += i * prices[i];
      sumX2 += i * i;
    }

    final denominator = (n * sumX2) - (sumX * sumX);
    if (denominator == 0) return 0;

    return ((n * sumXY) - (sumX * sumY)) / denominator;
  }

  /// R² (결정계수) 계산 - 추세 강도
  double _calculateRSquared(List<double> prices) {
    if (prices.length < 2) return 0;

    final n = prices.length.toDouble();
    final mean = prices.reduce((a, b) => a + b) / n;

    // 총 제곱합
    final ssTot = prices.fold<double>(0, (sum, p) => sum + pow(p - mean, 2).toDouble());

    // 회귀 제곱합
    final slope = _calculateSlope(prices);
    final intercept = mean - (slope * (n - 1) / 2);

    final ssRes = prices
        .asMap()
        .entries
        .fold<double>(0, (sum, entry) {
          final predicted = slope * entry.key + intercept;
          return sum + pow(entry.value - predicted, 2).toDouble();
        });

    if (ssTot == 0) return 0;
    return (1 - (ssRes / ssTot)).clamp(0, 1);
  }
}

/// ADX (Average Directional Index) - 추세 강도 측정
class AverageDirectionalIndex extends BaseIndicator {
  final int period;

  AverageDirectionalIndex({this.period = 14});

  @override
  double calculate(List<Candle> candles) {
    if (candles.length < period + 1) return 25;

    // +DM, -DM 계산
    double sumPlusDM = 0;
    double sumMinusDM = 0;
    double sumTR = 0;

    for (int i = 1; i <= period && i < candles.length; i++) {
      final idx = candles.length - i;
      final current = candles[idx];
      final previous = candles[idx - 1];

      final upMove = current.high - previous.high;
      final downMove = previous.low - current.low;

      if (upMove > downMove && upMove > 0) {
        sumPlusDM += upMove;
      } else {
        sumPlusDM += 0;
      }

      if (downMove > upMove && downMove > 0) {
        sumMinusDM += downMove;
      } else {
        sumMinusDM += 0;
      }

      sumTR += current.trueRangeFromPreviousClose(previous.close);
    }

    if (sumTR == 0) return 0;
    final plusDI = (sumPlusDM / sumTR) * 100;
    final minusDI = (sumMinusDM / sumTR) * 100;

    return (plusDI - minusDI).abs();
  }
}

/// Momentum (Single line momentum) - 단순 모멘텀
class Momentum extends BaseIndicator {
  final int period;

  Momentum({this.period = 12});

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];
    for (int i = 0; i < period; i++) {
      result.add(null);
    }

    for (int i = period; i < candles.length; i++) {
      result.add(candles[i].close - candles[i - period].close);
    }

    return result;
  }
}

/// Rate of Change (ROC) - 변화율
class RateOfChange extends BaseIndicator {
  final int period;

  RateOfChange({this.period = 12});

  @override
  List<double?> calculate(List<Candle> candles) {
    if (candles.length < period) {
      return List.filled(candles.length, null);
    }

    final result = <double?>[];
    for (int i = 0; i < period; i++) {
      result.add(null);
    }

    for (int i = period; i < candles.length; i++) {
      final change = candles[i].close - candles[i - period].close;
      final roc = (change / candles[i - period].close) * 100;
      result.add(roc);
    }

    return result;
  }
}
