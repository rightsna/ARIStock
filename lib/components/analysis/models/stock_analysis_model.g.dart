// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_analysis_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockAnalysisAdapter extends TypeAdapter<StockAnalysis> {
  @override
  final int typeId = 2;

  @override
  StockAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockAnalysis(
      symbol: fields[0] as String,
      stockName: fields[10] as String,
      date: fields[1] as String,
      content: fields[2] as String,
      shortTermScore: fields[3] as double?,
      mediumTermScore: fields[4] as double?,
      longTermScore: fields[5] as double?,
      summary: fields[6] as String?,
      otherOpinions: fields[7] as String?,
      issues: (fields[9] as List?)?.cast<InvestmentIssue>(),
    );
  }

  @override
  void write(BinaryWriter writer, StockAnalysis obj) {
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
      ..writeByte(9)
      ..write(obj.issues)
      ..writeByte(10)
      ..write(obj.stockName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
