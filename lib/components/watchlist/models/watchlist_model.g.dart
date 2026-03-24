// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WatchlistStockAdapter extends TypeAdapter<WatchlistStock> {
  @override
  final int typeId = 7;

  @override
  WatchlistStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistStock(
      symbol: fields[0] as String,
      name: fields[1] as String,
      isHolding: fields[2] as bool,
      addedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistStock obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isHolding)
      ..writeByte(3)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistStockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
