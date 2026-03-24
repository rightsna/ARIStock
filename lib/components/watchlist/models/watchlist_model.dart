import 'package:hive/hive.dart';

part 'watchlist_model.g.dart';

@HiveType(typeId: 7)
class WatchlistStock extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isHolding;

  @HiveField(3)
  final DateTime addedAt;

  WatchlistStock({
    required this.symbol,
    required this.name,
    this.isHolding = false,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}
