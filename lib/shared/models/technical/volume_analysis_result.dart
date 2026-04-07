import '../market/candle.dart';

/// 거래량 분석 결과 (평균 대비 거래량 및 스파이크 감지)
class VolumeAnalysisResult {
  final double averageVolume;
  final double currentVolumeRatio; // 현재 거래량 / 평균 (1.0 = 평년대비 동일)
  final bool isSpike; // 거래량 스파이크 (> 2배)

  VolumeAnalysisResult({
    required this.averageVolume,
    required this.currentVolumeRatio,
  }) : isSpike = currentVolumeRatio > 2.0;

  factory VolumeAnalysisResult.fromCandles(List<Candle> candles,
      {int period = 20}) {
    if (candles.isEmpty) {
      return VolumeAnalysisResult(averageVolume: 0, currentVolumeRatio: 1.0);
    }
    final historicalCandles =
        candles.length > 1 ? candles.sublist(0, candles.length - 1) : candles;
    final recentCandles = historicalCandles.length >= period
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
    return VolumeAnalysisResult(
        averageVolume: avgVolume, currentVolumeRatio: ratio);
  }

  Map<String, dynamic> toMap() => {
        'averageVolume': averageVolume,
        'currentVolumeRatio': currentVolumeRatio,
        'isSpike': isSpike,
      };
}
