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
      issues: (fields[9] as List?)?.cast<InvestmentIssue>(),
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
      ..write(obj.issues);
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

class InvestmentIssueAdapter extends TypeAdapter<InvestmentIssue> {
  @override
  final int typeId = 3;

  @override
  InvestmentIssue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvestmentIssue(
      title: fields[0] as String,
      startDate: fields[1] as String,
      endDate: fields[2] as String?,
      isPositive: fields[3] as bool,
      impact: fields[4] as int,
      status: fields[5] as String,
      lastInvestigation: fields[6] as String?,
      history: (fields[7] as List?)?.cast<IssueHistory>(),
      isChecked: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InvestmentIssue obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.isPositive)
      ..writeByte(4)
      ..write(obj.impact)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.lastInvestigation)
      ..writeByte(7)
      ..write(obj.history)
      ..writeByte(8)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentIssueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueHistoryAdapter extends TypeAdapter<IssueHistory> {
  @override
  final int typeId = 4;

  @override
  IssueHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueHistory(
      date: fields[0] as String,
      content: fields[1] as String,
      detail: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.detail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
