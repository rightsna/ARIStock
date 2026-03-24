// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisStockAdapter extends TypeAdapter<AnalysisStock> {
  @override
  final int typeId = 1;

  @override
  AnalysisStock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisStock(
      symbol: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisStock obj) {
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
      other is AnalysisStockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalysisLogAdapter extends TypeAdapter<AnalysisLog> {
  @override
  final int typeId = 2;

  @override
  AnalysisLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisLog(
      symbol: fields[0] as String,
      date: fields[1] as String,
      content: fields[2] as String,
      shortTermScore: fields[3] as double?,
      mediumTermScore: fields[4] as double?,
      longTermScore: fields[5] as double?,
      summary: fields[6] as String?,
      otherOpinions: fields[7] as String?,
      userNote: fields[8] as String?,
      checkPoints: (fields[9] as List?)?.cast<AnalysisCheckPoint>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.shortTermScore)
      ..writeByte(4)
      ..write(obj.mediumTermScore)
      ..writeByte(5)
      ..write(obj.longTermScore)
      ..writeByte(6)
      ..write(obj.summary)
      ..writeByte(7)
      ..write(obj.otherOpinions)
      ..writeByte(8)
      ..write(obj.userNote)
      ..writeByte(9)
      ..write(obj.checkPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalysisCheckPointAdapter extends TypeAdapter<AnalysisCheckPoint> {
  @override
  final int typeId = 3;

  @override
  AnalysisCheckPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisCheckPoint(
      content: fields[0] as String,
      isChecked: fields[1] as bool,
      isPositive: fields[2] as bool,
      impact: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisCheckPoint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.isChecked)
      ..writeByte(2)
      ..write(obj.isPositive)
      ..writeByte(3)
      ..write(obj.impact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisCheckPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
