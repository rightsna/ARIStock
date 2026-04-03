import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ari_plugin/ari_plugin.dart';

/// 채팅 메시지 데이터 모델
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystem; // 프로그래스(툴 실행 등) 메시지 여부
  final DateTime createdAt;
  final String? requestId;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.isSystem = false,
    this.requestId,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  StreamSubscription? _agentPushSub;
  StreamSubscription? _agentRequestSub;
  StreamSubscription? _progressSub;

  ChatProvider() {
    _initListeners();
  }

  void _initListeners() {
    // 1. 질문 수신 — /AGENT.REQUEST 로 브로드캐스트됨 (루프 방지용 별도 프로토콜)
    _agentRequestSub = AriAgent.on('/AGENT.REQUEST', (data) {
      final requestId = data['requestId']?.toString() ?? '';
      final message = data['message']?.toString() ?? '';

      if (message.isEmpty) return;
      if (requestId.isNotEmpty &&
          _messages.any((m) => m.isUser && m.requestId == requestId))
        return;

      _messages.add(
        ChatMessage(
          text: message,
          isUser: true,
          createdAt: DateTime.now(),
          requestId: requestId,
        ),
      );
      notifyListeners();
    });

    // 2. 답변 수신 (방송)
    _agentPushSub = AriAgent.on('/APP.PUSH', (data) {
      final payload = data['data'] is Map ? data['data'] as Map : data;
      final response = payload['response']?.toString() ?? '';
      final requestId = payload['requestId']?.toString() ?? '';

      if (response.isEmpty) return;

      // 답변이 오면 프로그래스 메시지 제거
      if (requestId.isNotEmpty) {
        _removeProgressMessage(requestId);
      }

      // AI 답변 중복 체크
      if (requestId.isNotEmpty &&
          _messages.any(
            (m) => !m.isUser && !m.isSystem && m.requestId == requestId,
          ))
        return;

      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          createdAt: DateTime.now(),
          requestId: requestId,
        ),
      );
      notifyListeners();
    });

    // 3. 프로그래스(툴 실행 등) 수신
    _progressSub = AriAgent.on('/AGENT.PROGRESS', (data) {
      final payload = data['data'] is Map ? data['data'] as Map : data;
      final progressMessage = payload['message']?.toString() ?? '';
      final requestId = payload['requestId']?.toString() ?? '';

      if (progressMessage.isEmpty) return;

      _upsertProgressMessage(progressMessage, requestId);
      notifyListeners();
    });
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void _upsertProgressMessage(String text, String requestId) {
    final idx = _messages.lastIndexWhere(
      (m) => m.isSystem && m.requestId == requestId,
    );
    final msg = ChatMessage(
      text: text,
      isUser: false,
      isSystem: true,
      requestId: requestId,
      createdAt: DateTime.now(),
    );

    if (idx >= 0) {
      _messages[idx] = msg;
    } else {
      _messages.add(msg);
    }
  }

  void _removeProgressMessage(String requestId) {
    _messages.removeWhere((m) => m.isSystem && m.requestId == requestId);
  }

  void addAiMessage(String text, {String? requestId}) {
    if (requestId != null &&
        _messages.any((m) => !m.isUser && m.requestId == requestId))
      return;
    _messages.add(
      ChatMessage(
        text: text,
        isUser: false,
        createdAt: DateTime.now(),
        requestId: requestId,
      ),
    );
    notifyListeners();
  }

  void addUserMessage(String text, {String? requestId}) {
    if (requestId != null &&
        _messages.any((m) => m.isUser && m.requestId == requestId))
      return;
    _messages.add(
      ChatMessage(
        text: text,
        isUser: true,
        createdAt: DateTime.now(),
        requestId: requestId,
      ),
    );
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _agentPushSub?.cancel();
    _agentRequestSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
  }
}
