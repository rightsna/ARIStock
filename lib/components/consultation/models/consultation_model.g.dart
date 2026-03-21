// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsultationStockAdapter extends TypeAdapter<ConsultationStock> {
  @override
  final int typeId = 1;

  @override
  ConsultationStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsultationStock(
      symbol: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConsultationStock obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultationStockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConsultationLogAdapter extends TypeAdapter<ConsultationLog> {
  @override
  final int typeId = 2;

  @override
  ConsultationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsultationLog(
      stockSymbol: fields[0] as String,
      date: fields[1] as String,
      content: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConsultationLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.stockSymbol)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
