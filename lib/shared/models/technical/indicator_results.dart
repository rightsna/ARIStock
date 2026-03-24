/// 이동평균 결과
class MovingAverageResult {
  final Map<int, double> values;  // {기간: 값}

  MovingAverageResult({required this.values});

  /// 특정 기간의 이동평균 값
  double? get(int period) => values[period];

  Map<String, dynamic> toMap() => {
        'values': values.map((k, v) => MapEntry(k.toString(), v)),
      };
}

/// RSI 결과
class RSIResult {
  final double value;  // 0-100
  final bool isOverbought;  // > 70
  final bool isOversold;    // < 30

  RSIResult({
    required this.value,
  })  : isOverbought = value > 70,
        isOversold = value < 30;

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
  final double histogram;  // MACD - Signal
  final bool isBullish;    // MACD > Signal

  MacdResult({
    required this.macdLine,
    required this.signalLine,
  })  : histogram = macdLine - signalLine,
        isBullish = macdLine > signalLine;

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
  final bool isAtTop;      // 종가가 상단에 가까움
  final bool isAtBottom;   // 종가가 하단에 가까움
  final double squeeze;    // 밴드폭 축소 정도 (0-1)

  BollingerBandsResult({
    required this.upperBand,
    required this.middleBand,
    required this.lowerBand,
    required double lastClose,
  })  : bandwidthRatio = middleBand == 0 ? 0 : (upperBand - lowerBand) / middleBand,
        isAtTop = lastClose > middleBand + (upperBand - middleBand) * 0.8,
        isAtBottom = lastClose < middleBand - (middleBand - lowerBand) * 0.8,
        squeeze = 1 / (1 + (middleBand == 0 ? 0 : (upperBand - lowerBand) / middleBand));

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
  final bool isHighVolatility;  // 평년대비 높음

  ATRResult({
    required this.value,
    this.isHighVolatility = false,
  });

  Map<String, dynamic> toMap() => {
        'value': value,
        'isHighVolatility': isHighVolatility,
      };
}

/// 거래량 분석 결과
class VolumeAnalysisResult {
  final double averageVolume;
  final double currentVolumeRatio;  // 현재 거래량 / 평균 (1.0 = 평년대비 동일)
  final bool isSpike;               // 거래량 스파이크 (> 2배)

  VolumeAnalysisResult({
    required this.averageVolume,
    required this.currentVolumeRatio,
  }) : isSpike = currentVolumeRatio > 2.0;

  Map<String, dynamic> toMap() => {
        'averageVolume': averageVolume,
        'currentVolumeRatio': currentVolumeRatio,
        'isSpike': isSpike,
      };
}

/// 추세 분석 결과
class TrendResult {
  final String direction;  // "UP", "DOWN", "NEUTRAL"
  final double slope;      // 기울기 (양수=상승, 음수=하락)
  final double strength;   // 추세 강도 (0-1)

  TrendResult({
    required this.direction,
    required this.slope,
    required this.strength,
  });

  Map<String, dynamic> toMap() => {
        'direction': direction,
        'slope': slope,
        'strength': strength,
      };
}
