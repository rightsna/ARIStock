// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_issue_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      id: fields[0] as String,
      title: fields[1] as String,
      startDate: fields[2] as String,
      endDate: fields[3] as String?,
      isPositive: fields[4] as bool,
      impact: fields[5] as int,
      status: fields[6] as String,
      lastInvestigation: fields[7] as String?,
      history: (fields[8] as List?)?.cast<IssueHistory>(),
      isChecked: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, InvestmentIssue obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.isPositive)
      ..writeByte(5)
      ..write(obj.impact)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.lastInvestigation)
      ..writeByte(8)
      ..write(obj.history)
      ..writeByte(9)
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
