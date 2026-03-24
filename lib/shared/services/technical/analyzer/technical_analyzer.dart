import 'package:flutter/foundation.dart';

import '../../../models/market/candle.dart';
import '../../../models/technical/indicator_results.dart';
import '../indicators/moving_average.dart';
import '../indicators/momentum.dart';
import '../indicators/volatility.dart';
import '../indicators/volume.dart';
import '../indicators/trend.dart';
import 'stock_analysis_result.dart';

/// 기술적 분석 통합 엔진
/// 모든 지표를 계산해서 에이전트에게 최종 분석 결과만 전달
class TechnicalAnalyzer {
  // 기본 설정
  static const List<int> defaultMaPeriods = [20, 50, 200];
  static const int defaultRsiPeriod = 14;
  static const int defaultMacdFast = 12;
  static const int defaultMacdSlow = 26;
  static const int defaultMacdSignal = 9;
  static const int defaultAtrPeriod = 14;
  static const int defaultBbPeriod = 20;
  static const int defaultTrendPeriod = 20;
  static const int defaultVolumePeriod = 20;

  /// 종목의 모든 기술적 지표를 한 번에 분석
  /// 캔들 리스트를 받아 에이전트가 필요한 모든 정보를 반환
  static Future<StockAnalysisResult> analyze({
    required String symbol,
    required List<Candle> candles,
    List<int> maPeriods = defaultMaPeriods,
  }) async {
    if (candles.isEmpty) {
      throw ArgumentError('Candles list is empty');
    }

    // 이동평균 계산
    final movingAverages = _calculateMovingAverages(candles, maPeriods);

    // 모멘텀 지표 계산
    final rsi = RelativeStrengthIndex(period: defaultRsiPeriod).calculate(candles);
    final macd = MACD(
      fastPeriod: defaultMacdFast,
      slowPeriod: defaultMacdSlow,
      signalPeriod: defaultMacdSignal,
    ).calculate(candles);

    // 변동성 지표 계산
    final atr = AverageTrueRange(period: defaultAtrPeriod).calculate(candles);
    final bollingerBands = BollingerBands(
      period: defaultBbPeriod,
      stdDev: 2.0,
    ).calculate(candles);

    // 거래량 분석
    final volumeAnalysis = VolumeAnalyzer(period: defaultVolumePeriod).calculate(candles);

    // 추세 분석
    final trend = TrendAnalyzer(period: defaultTrendPeriod).calculate(candles);

    return StockAnalysisResult(
      symbol: symbol,
      timestamp: DateTime.now(),
      lastCandle: candles.last,
      movingAverages: movingAverages,
      rsi: rsi,
      macd: macd,
      atr: atr,
      bollingerBands: bollingerBands,
      volumeAnalysis: volumeAnalysis,
      trend: trend,
    );
  }

  /// 이동평균 계산 (다중 기간)
  static MovingAverageResult _calculateMovingAverages(
    List<Candle> candles,
    List<int> periods,
  ) {
    final closePrices = candles.map((c) => c.close).toList();
    final values = <int, double>{};

    for (final period in periods) {
      final smaValues = MovingAverage.sma(closePrices, period);
      final lastValue = smaValues.lastWhere((s) => s != null, orElse: () => null);
      if (lastValue != null) {
        values[period] = lastValue;
      }
    }

    return MovingAverageResult(values: values);
  }

  /// 빠른 분석 (성능 최적화된 버전)
  /// 필요한 지표만 선택적으로 계산
  static Future<Map<String, dynamic>> analyzeFast({
    required String symbol,
    required List<Candle> candles,
    List<String> indicators = const [
      'movingAverages',
      'rsi',
      'macd',
      'trend',
    ],
  }) async {
    final result = <String, dynamic>{
      'symbol': symbol,
      'timestamp': DateTime.now().toIso8601String(),
      'price': candles.last.close,
    };

    if (indicators.isEmpty) return result;

    // 이동평균
    if (indicators.contains('movingAverages')) {
      final ma = _calculateMovingAverages(candles, defaultMaPeriods);
      result['movingAverages'] = ma.toMap();
    }

    // RSI
    if (indicators.contains('rsi')) {
      final rsi = RelativeStrengthIndex(period: defaultRsiPeriod).calculate(candles);
      result['rsi'] = rsi.toMap();
    }

    // MACD
    if (indicators.contains('macd')) {
      final macd = MACD(
        fastPeriod: defaultMacdFast,
        slowPeriod: defaultMacdSlow,
        signalPeriod: defaultMacdSignal,
      ).calculate(candles);
      result['macd'] = macd.toMap();
    }

    // ATR
    if (indicators.contains('atr')) {
      final atr = AverageTrueRange(period: defaultAtrPeriod).calculate(candles);
      result['atr'] = atr.toMap();
    }

    // Bollinger Bands
    if (indicators.contains('bollinger')) {
      final bb = BollingerBands(period: defaultBbPeriod).calculate(candles);
      result['bollinger'] = bb.toMap();
    }

    // 거래량
    if (indicators.contains('volume')) {
      final volume = VolumeAnalyzer(period: defaultVolumePeriod).calculate(candles);
      result['volume'] = volume.toMap();
    }

    // 추세
    if (indicators.contains('trend')) {
      final trend = TrendAnalyzer(period: defaultTrendPeriod).calculate(candles);
      result['trend'] = trend.toMap();
    }

    return result;
  }

  /// 다중 종목 일괄 분석 (배치 처리)
  static Future<List<StockAnalysisResult>> analyzeMultiple({
    required Map<String, List<Candle>> stocksData,
  }) async {
    final results = <StockAnalysisResult>[];

    for (final entry in stocksData.entries) {
      try {
        final result = await analyze(
          symbol: entry.key,
          candles: entry.value,
        );
        results.add(result);
      } catch (e) {
        debugPrint('Error analyzing ${entry.key}: $e');
      }
    }

    return results;
  }

  /// 분석 결과 요약 출력 (디버깅용)
  static void printAnalysisReport(StockAnalysisResult result) {
    debugPrint(result.summary);
  }
}
