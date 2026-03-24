import '../../../models/market/candle.dart';
import '../../../models/technical/indicator_results.dart';

/// 종목의 모든 기술적 분석 결과를 담는 통합 모델
/// 에이전트에게 전달되는 최종 분석 결과
class StockAnalysisResult {
  final String symbol;
  final DateTime timestamp;
  final Candle lastCandle;

  // 이동평균
  final MovingAverageResult movingAverages;

  // 모멘텀
  final RSIResult rsi;
  final MacdResult macd;

  // 변동성
  final ATRResult atr;
  final BollingerBandsResult bollingerBands;

  // 거래량
  final VolumeAnalysisResult volumeAnalysis;

  // 추세
  final TrendResult trend;

  StockAnalysisResult({
    required this.symbol,
    required this.timestamp,
    required this.lastCandle,
    required this.movingAverages,
    required this.rsi,
    required this.macd,
    required this.atr,
    required this.bollingerBands,
    required this.volumeAnalysis,
    required this.trend,
  });

  /// 매매 신호 우선순위 점수 (0-100)
  /// 양수 = 매수 신호, 음수 = 매도 신호, 0 = 중립
  int get tradingSignalScore {
    int score = 0;

    // 모멘텀 신호 (±30)
    if (rsi.isOverbought) {
      score -= 15; // 과매수
    } else if (rsi.isOversold) {
      score += 15; // 과매도
    }

    if (macd.isBullish) {
      score += 15;
    } else {
      score -= 15;
    }

    // 추세 신호 (±20)
    if (trend.direction == 'UP') {
      score += 10 + (trend.strength * 10).toInt();
    } else if (trend.direction == 'DOWN') {
      score -= 10 + (trend.strength * 10).toInt();
    }

    // 거래량 신호 (±10)
    if (volumeAnalysis.isSpike) {
      score += (trend.direction == 'UP' ? 10 : -10);
    }

    // Bollinger Bands 신호 (±15)
    if (bollingerBands.isAtBottom) {
      score += 10;
    } else if (bollingerBands.isAtTop) {
      score -= 10;
    }

    // 손절금지 신호
    final maxClamp = trend.direction == 'UP' ? 100 : trend.direction == 'DOWN' ? -100 : 0;
    if (maxClamp != 0) {
      score = score.clamp(-100, 100);
    }

    return score;
  }

  /// 신호 해석 (한국어)
  String get tradingSignalText {
    final score = tradingSignalScore;

    if (score >= 60) {
      return '🟢 강한 매수 신호';
    } else if (score >= 30) {
      return '🟢 약한 매수 신호';
    } else if (score > -30) {
      return '🟡 중립 / 관망';
    } else if (score > -60) {
      return '🔴 약한 매도 신호';
    } else {
      return '🔴 강한 매도 신호';
    }
  }

  /// 주요 기술적 이상 신호 감지
  List<String> get warningSignals {
    final warnings = <String>[];

    if (rsi.isOverbought) warnings.add('⚠️ RSI 과매수 (>70)');
    if (rsi.isOversold) warnings.add('⚠️ RSI 과매도 (<30)');
    if (bollingerBands.isAtTop) warnings.add('⚠️ 상단 볼린저밴드 접촉');
    if (bollingerBands.isAtBottom) warnings.add('⚠️ 하단 볼린저밴드 접촉');
    if (bollingerBands.squeeze > 0.7) warnings.add('⚠️ 볼린저밴드 축소 (변동성 저하)');
    if (volumeAnalysis.isSpike) warnings.add('⚠️ 거래량 스파이크 (${volumeAnalysis.currentVolumeRatio.toStringAsFixed(1)}배)');

    return warnings;
  }

  /// JSON 직렬화 (에이전트 전송용)
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'timestamp': timestamp.toIso8601String(),
      'lastPrice': lastCandle.close,
      'priceChange': lastCandle.close - lastCandle.open,
      'priceChangePercent': ((lastCandle.close - lastCandle.open) / lastCandle.open * 100),
      'movingAverages': movingAverages.toMap(),
      'rsi': rsi.toMap(),
      'macd': macd.toMap(),
      'atr': atr.toMap(),
      'bollingerBands': bollingerBands.toMap(),
      'volumeAnalysis': volumeAnalysis.toMap(),
      'trend': trend.toMap(),
      'tradingSignalScore': tradingSignalScore,
      'tradingSignalText': tradingSignalText,
      'warningSignals': warningSignals,
    };
  }

  /// 요약 (콘솔 출력용)
  String get summary {
    return '''
═══════════════════════════════════════════════════════
📊 $symbol 기술적 분석 ($timestamp)
───────────────────────────────────────────────────────
현재가: ${lastCandle.close} | 변화: ${lastCandle.close - lastCandle.open >= 0 ? '📈' : '📉'} ${(lastCandle.close - lastCandle.open).toStringAsFixed(0)}

📈 추세: ${trend.direction} (강도: ${(trend.strength * 100).toStringAsFixed(0)}%)
🔵 RSI: ${rsi.value.toStringAsFixed(2)} ${rsi.isOverbought ? '⚠️ 과매수' : rsi.isOversold ? '⚠️ 과매도' : ''}
📊 MACD: ${macd.isBullish ? '🟢 상승' : '🔴 하락'}
📉 ATR: ${atr.value.toStringAsFixed(2)}
💰 거래량: ${volumeAnalysis.currentVolumeRatio.toStringAsFixed(1)}배 ${volumeAnalysis.isSpike ? '🔥' : ''}

$tradingSignalText
═══════════════════════════════════════════════════════
''';
  }
}
