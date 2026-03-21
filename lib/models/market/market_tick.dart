class MarketTick {
  final DateTime timestamp;
  final double price;
  final int volume;

  MarketTick({
    required this.timestamp,
    required this.price,
    required this.volume,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'price': price,
        'volume': volume,
      };
}
