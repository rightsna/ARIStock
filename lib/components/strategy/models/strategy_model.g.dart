// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StrategyAdapter extends TypeAdapter<Strategy> {
  @override
  final int typeId = 3;

  @override
  Strategy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Strategy(
      symbol: fields[0] as String,
      name: fields[1] as String,
      content: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Strategy obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TradingLogAdapter extends TypeAdapter<TradingLog> {
  @override
  final int typeId = 4;

  @override
  TradingLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradingLog(
      symbol: fields[0] as String,
      date: fields[1] as String,
      type: fields[2] as String,
      price: fields[3] as String,
      quantity: fields[4] as String,
      status: fields[5] as String,
      strategySnapshot: fields[6] as String,
      aiReason: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TradingLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.strategySnapshot)
      ..writeByte(7)
      ..write(obj.aiReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradingLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
