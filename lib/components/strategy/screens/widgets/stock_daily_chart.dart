import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/market/candle.dart';
import '../../../../shared/theme.dart';
import '../../providers/stock_chart_provider.dart';
import '../../../watchlist/providers/watchlist_provider.dart';

class StockDailyChart extends StatefulWidget {
  final List<double>? entryPrices;
  final List<double>? targetPrices;
  final double? stopLoss;

  const StockDailyChart({
    super.key,
    this.entryPrices,
    this.targetPrices,
    this.stopLoss,
  });

  @override
  State<StockDailyChart> createState() => _StockDailyChartState();
}

class _StockDailyChartState extends State<StockDailyChart> {
  String? _lastSymbol;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedSymbol = context.watch<WatchlistProvider>().selectedSymbol;
    if (selectedSymbol != null && selectedSymbol != _lastSymbol) {
      _lastSymbol = selectedSymbol;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StockChartProvider>().fetchDailyChart(selectedSymbol);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartProvider = context.watch<StockChartProvider>();
    final candles = chartProvider.currentCandles;

    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight.withOpacity(0.3),
        border: const Border(
          bottom: BorderSide(color: AppTheme.textMain10, width: 1),
        ),
      ),
      child: chartProvider.isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : chartProvider.error != null
          ? Center(
              child: Text(
                '데이터를 불러올 수 없습니다.',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            )
          : candles.isEmpty
          ? const Center(
              child: Text(
                '차트 데이터가 없습니다.',
                style: TextStyle(color: AppTheme.textSub, fontSize: 12),
              ),
            )
          : CustomPaint(
              size: Size.infinite,
              painter: _CandleChartPainter(
                candles,
                entryPrices: widget.entryPrices,
                targetPrices: widget.targetPrices,
                stopLoss: widget.stopLoss,
              ),
            ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  final List<Candle> candles;
  final List<double>? entryPrices;
  final List<double>? targetPrices;
  final double? stopLoss;

  _CandleChartPainter(
    this.candles, {
    this.entryPrices,
    this.targetPrices,
    this.stopLoss,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    // 차트 높이 계산을 위한 가격 범위 산출
    double maxHigh = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    double minLow = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);

    // 설정된 가격선들도 범위에 포함
    if (targetPrices != null && targetPrices!.isNotEmpty) {
      for (var p in targetPrices!) {
        if (p > maxHigh) maxHigh = p;
        if (p < minLow) minLow = p;
      }
    }
    if (stopLoss != null) {
      if (stopLoss! > maxHigh) maxHigh = stopLoss!;
      if (stopLoss! < minLow) minLow = stopLoss!;
    }
    if (entryPrices != null && entryPrices!.isNotEmpty) {
      for (var p in entryPrices!) {
        if (p > maxHigh) maxHigh = p;
        if (p < minLow) minLow = p;
      }
    }

    final double range = (maxHigh - minLow).abs();
    if (range == 0) return;

    // 캔들 너비 계산 (오른쪽 10칸 빈자리 포함)
    const int extraSpace = 10;
    final int totalSlots = candles.length + extraSpace;
    final double candleWidth = (size.width / totalSlots) * 0.8;
    final double spacing = (size.width / totalSlots) * 0.2;

    double x = spacing / 2;

    for (final candle in candles) {
      final double highY = size.height * (1 - (candle.high - minLow) / range);
      final double lowY = size.height * (1 - (candle.low - minLow) / range);
      final double openY = size.height * (1 - (candle.open - minLow) / range);
      final double closeY = size.height * (1 - (candle.close - minLow) / range);

      final Color color = candle.isBullish ? Colors.red : Colors.blue;
      final Paint paint = Paint()..color = color;
      final Paint wickPaint = Paint()
        ..color = color
        ..strokeWidth = 1;

      // 꼬리
      canvas.drawLine(
        Offset(x + candleWidth / 2, highY),
        Offset(x + candleWidth / 2, lowY),
        wickPaint,
      );

      // 몸통
      double bodyTop = openY < closeY ? openY : closeY;
      double bodyBottom = openY < closeY ? closeY : openY;
      if (bodyBottom - bodyTop < 1) bodyBottom = bodyTop + 1;

      canvas.drawRect(
        Rect.fromLTRB(x, bodyTop, x + candleWidth, bodyBottom),
        paint,
      );

      x += candleWidth + spacing;
    }

    // 가격선 그리기 (오른쪽 빈칸 영역 위주)
    if (targetPrices != null) {
      for (var p in targetPrices!) {
        _drawPriceLine(canvas, size, p, minLow, range, Colors.orange, '목표가');
      }
    }
    if (entryPrices != null) {
      for (var p in entryPrices!) {
        _drawPriceLine(canvas, size, p, minLow, range, Colors.green, '매수가');
      }
    }
    if (stopLoss != null) {
      _drawPriceLine(
        canvas,
        size,
        stopLoss!,
        minLow,
        range,
        Colors.grey,
        '손절가',
      );
    }

    // 현재 고가/저가 수치 표시
    _drawText(
      canvas,
      maxHigh.toInt().toString(),
      0,
      Colors.red.withOpacity(0.5),
      size.width,
    );
    _drawText(
      canvas,
      minLow.toInt().toString(),
      size.height - 12,
      Colors.blue.withOpacity(0.5),
      size.width,
    );
  }

  void _drawPriceLine(
    Canvas canvas,
    Size size,
    double price,
    double minLow,
    double range,
    Color color,
    String label,
  ) {
    final double y = size.height * (1 - (price - minLow) / range);
    if (y < 0 || y > size.height) return;

    final Paint paint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 0.8;

    // 점선 그리기 (전체 가로지르기)
    const double dashWidth = 4;
    const double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }

    // 라벨 표시 (오른쪽 빈칸 영역)
    final tp = TextPainter(
      text: TextSpan(
        text: '$label ${price.toInt()}',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    // 캔들이 끝난 지점부터 배치 (여백 5 확보)
    final double labelX = size.width - tp.width;
    tp.paint(canvas, Offset(labelX, y - tp.height - 2));
  }

  void _drawText(
    Canvas canvas,
    String text,
    double y,
    Color color,
    double width,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(width - tp.width, y));
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.entryPrices != entryPrices ||
        oldDelegate.targetPrices != targetPrices ||
        oldDelegate.stopLoss != stopLoss;
  }
}
