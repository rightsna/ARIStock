/// 키움 REST API 응답 모델
class KiwoomResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final String? contYn;
  final String? nextKey;

  KiwoomResponse({
    required this.statusCode,
    required this.body,
    this.contYn,
    this.nextKey,
  });

  bool get isSuccess {
    if (statusCode != 200) return false;
    final returnCode = body['return_code'];
    if (returnCode is int && returnCode != 0) return false;
    return true;
  }
  bool get hasNext => contYn == 'Y' && nextKey != null && nextKey!.isNotEmpty;
}
