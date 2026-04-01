// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_strategy_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradingStrategyAdapter extends TypeAdapter<TradingStrategy> {
  @override
  final int typeId = 8;

  @override
  TradingStrategy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradingStrategy(
      symbol: fields[0] as String,
      content: fields[1] as String,
      updatedAt: fields[2] as String,
      entryPrices: (fields[3] as List?)?.cast<double>(),
      targetPrices: (fields[4] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, TradingStrategy obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.entryPrices)
      ..writeByte(4)
      ..write(obj.targetPrices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradingStrategyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
