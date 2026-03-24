import '../../../models/market/candle.dart';
import '../../../models/technical/indicator_results.dart';
import 'base_indicator.dart';

/// 거래량 분석 - 거래량 기반의 강도 측정
class VolumeAnalyzer extends BaseIndicator {
  final int period;

  VolumeAnalyzer({this.period = 20});

  @override
  VolumeAnalysisResult calculate(List<Candle> candles) {
    if (candles.isEmpty) {
      return VolumeAnalysisResult(averageVolume: 0, currentVolumeRatio: 1.0);
    }

    // 1. 현재 봉을 제외한 기간 내 평균 거래량
    final historicalCandles = candles.length > 1 ? candles.sublist(0, candles.length - 1) : candles;
    final recentCandles = historicalCandles.length >= period
        ? historicalCandles.sublist(historicalCandles.length - period)
        : historicalCandles;
    if (recentCandles.isEmpty) {
      return VolumeAnalysisResult(averageVolume: 0, currentVolumeRatio: 1.0);
    }
    final avgVolume =
        recentCandles.map((c) => c.volume).fold<double>(0, (a, b) => a + b) / recentCandles.length;

    // 2. 현재 거래량 비율
    final currentVolume = candles.last.volume.toDouble();
    final ratio = avgVolume > 0 ? currentVolume / avgVolume : 1.0;

    return VolumeAnalysisResult(
      averageVolume: avgVolume,
      currentVolumeRatio: ratio,
    );
  }

  /// 모든 거래량 비율 반환
  List<double> calculateAllRatios(List<Candle> candles) {
    final result = <double>[];
    for (int i = 0; i < candles.length; i++) {
      final end = i;
      final start = (end - period).clamp(0, candles.length);
      final window = candles.sublist(start, end);
      if (window.isEmpty) {
        result.add(1.0);
        continue;
      }
      final avgVol = window.map((c) => c.volume).fold<double>(0, (a, b) => a + b) / window.length;
      result.add(avgVol > 0 ? candles[i].volume / avgVol : 1.0);
    }
    return result;
  }
}

/// OBV (On-Balance Volume) - 거래량 지표
/// 거래량을 누적해서 추세 강도 측정
class OnBalanceVolume extends BaseIndicator {
  @override
  List<double> calculate(List<Candle> candles) {
    if (candles.isEmpty) return [];

    final result = <double>[candles[0].volume.toDouble()];
    for (int i = 1; i < candles.length; i++) {
      final volume = candles[i].volume.toDouble();
      if (candles[i].close > candles[i - 1].close) {
        result.add(result[i - 1] + volume);
      } else if (candles[i].close < candles[i - 1].close) {
        result.add(result[i - 1] - volume);
      } else {
        result.add(result[i - 1]);
      }
    }
    return result;
  }
}

/// MFI (Money Flow Index) - 거래량과 가격 결합
/// RSI와 유사하지만 거래량 고려
class MoneyFlowIndex extends BaseIndicator {
  final int period;

  MoneyFlowIndex({this.period = 14});

  @override
  double calculate(List<Candle> candles) {
    if (candles.length < period + 1) return 50;

    // 1. Typical Price = (high + low + close) / 3
    final typicalPrices = candles.map((c) => (c.high + c.low + c.close) / 3).toList();

    // 2. Money Flow = Typical Price * Volume
    final moneyFlows = <double>[];
    for (int i = 0; i < candles.length; i++) {
      moneyFlows.add(typicalPrices[i] * candles[i].volume);
    }

    // 3. Positive/Negative Money Flow
    double positiveFlow = 0;
    double negativeFlow = 0;

    for (int i = 1; i <= period && i < candles.length; i++) {
      final idx = candles.length - i;
      if (typicalPrices[idx] > typicalPrices[idx - 1]) {
        positiveFlow += moneyFlows[idx];
      } else if (typicalPrices[idx] < typicalPrices[idx - 1]) {
        negativeFlow += moneyFlows[idx];
      }
    }

    // 4. MFI 계산
    final mfratio = negativeFlow == 0 ? 100 : positiveFlow / negativeFlow;
    return 100 - (100 / (1 + mfratio));
  }
}

/// VWAP (Volume Weighted Average Price) - 거래량 가중 평균 가격
/// 거래량을 고려한 평균 가격
class VolumeWeightedAveragePrice extends BaseIndicator {
  @override
  double calculate(List<Candle> candles) {
    if (candles.isEmpty) return 0;

    double typicalPriceVolume = 0;
    int totalVolume = 0;

    for (final candle in candles) {
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      typicalPriceVolume += typicalPrice * candle.volume;
      totalVolume += candle.volume;
    }

    return totalVolume > 0 ? typicalPriceVolume / totalVolume : 0;
  }

  /// 모든 VWAP 값 반환 (누적)
  List<double> calculateAll(List<Candle> candles) {
    final result = <double>[];
    double cumulativeTypicalPriceVolume = 0;
    int cumulativeVolume = 0;

    for (final candle in candles) {
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;
      cumulativeTypicalPriceVolume += typicalPrice * candle.volume;
      cumulativeVolume += candle.volume;

      result.add(cumulativeVolume > 0 ? cumulativeTypicalPriceVolume / cumulativeVolume : 0);
    }

    return result;
  }
}
