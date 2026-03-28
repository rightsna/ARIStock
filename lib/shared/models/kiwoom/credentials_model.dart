import 'package:hive/hive.dart';

/// 키움 API 인증 정보를 저장하는 모델
class KiwoomCredentials {
  static const String boxName = 'kiwoom_credentials_box';
  static const String credentialsKey = 'credentials';

  final String appKey;
  final String appSecret;
  final bool isMock; // 모의투자 여부
  String? accessToken;
  DateTime? tokenExpiry;

  KiwoomCredentials({
    required this.appKey,
    required this.appSecret,
    this.isMock = false,
    this.accessToken,
    this.tokenExpiry,
  });

  /// 유효한 토큰이 있는지 확인
  bool get hasValidToken =>
      accessToken != null &&
      accessToken!.isNotEmpty &&
      tokenExpiry != null &&
      DateTime.now().isBefore(tokenExpiry!);

  /// API base URL (모의/실전 분기)
  String get baseUrl =>
      isMock ? 'https://mockapi.kiwoom.com' : 'https://api.kiwoom.com';

  /// Hive에 Map으로 저장
  Map<String, dynamic> toMap() => {
        'appKey': appKey,
        'appSecret': appSecret,
        'isMock': isMock,
        'accessToken': accessToken,
        'tokenExpiry': tokenExpiry?.toIso8601String(),
      };

  /// Map에서 복원
  factory KiwoomCredentials.fromMap(Map<dynamic, dynamic> map) {
    return KiwoomCredentials(
      appKey: map['appKey'] as String,
      appSecret: map['appSecret'] as String,
      isMock: map['isMock'] as bool? ?? false,
      accessToken: map['accessToken'] as String?,
      tokenExpiry: map['tokenExpiry'] != null
          ? DateTime.tryParse(map['tokenExpiry'] as String)
          : null,
    );
  }

  /// Hive Box에 저장
  static Future<void> save(KiwoomCredentials credentials) async {
    final box = await Hive.openBox(boxName);
    await box.put(credentialsKey, credentials.toMap());
  }

  /// Hive Box에서 불러오기
  static Future<KiwoomCredentials?> load() async {
    final box = await Hive.openBox(boxName);
    final data = box.get(credentialsKey);
    if (data == null) return null;
    return KiwoomCredentials.fromMap(Map<dynamic, dynamic>.from(data));
  }

  /// 저장된 인증 정보 삭제
  static Future<void> clear() async {
    final box = await Hive.openBox(boxName);
    await box.clear();
  }
}
