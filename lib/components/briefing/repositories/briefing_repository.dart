import 'package:hive/hive.dart';
import '../models/briefing_model.dart';

class BriefingRepository {
  static const String boxName = 'briefing_box';

  Future<Box<Briefing>> _openBox() async {
    return await Hive.openBox<Briefing>(boxName);
  }

  // 브리핑 저장 (이미 해당 날짜 데이터가 있으면 덮어씀)
  Future<void> saveBriefing(Briefing briefing) async {
    final box = await _openBox();
    await box.put(briefing.date, briefing);
  }

  // 특정 날짜의 브리핑 가져오기
  Future<Briefing?> getBriefing(String date) async {
    final box = await _openBox();
    return box.get(date);
  }

  // 모든 브리핑 가져오기 (히스토리용)
  Future<List<Briefing>> getAllBriefings() async {
    final box = await _openBox();
    return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // 브리핑 삭제
  // 모든 브리핑 삭제
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
