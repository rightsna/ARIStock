import 'package:hive/hive.dart';

part 'briefing_model.g.dart';

@HiveType(typeId: 0)
class Briefing extends HiveObject {
  @HiveField(0)
  final String date; // YYYY-MM-DD format

  @HiveField(1)
  final String content; // Markdown content

  Briefing({
    required this.date,
    required this.content,
  });
}
