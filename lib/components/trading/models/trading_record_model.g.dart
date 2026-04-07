// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradingRecordAdapter extends TypeAdapter<TradingRecord> {
  @override
  final int typeId = 9;

  @override
  TradingRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradingRecord(
      symbol: fields[0] as String,
      date: fields[1] as String,
      price: fields[2] as double,
      side: fields[3] as String,
      quantity: fields[4] as double,
      reason: fields[5] as String,
      createdAt: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TradingRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.side)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.reason)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradingRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
