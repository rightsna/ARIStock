import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../shared/theme.dart';
import 'chat_provider.dart';

import 'widgets/chat_empty_state.dart';
import 'widgets/chat_input_area.dart';
import 'widgets/chat_message_item.dart';

class ChatPanel extends StatefulWidget {
  final List<String> tabLabels;
  final TabController tabController;

  const ChatPanel({
    super.key,
    required this.tabLabels,
    required this.tabController,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentTab = 0;
  int _lastMessageCount = 0;
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.tabController.index;
    widget.tabController.addListener(_onTabChanged);
    _chatProvider = context.read<ChatProvider>();
    _lastMessageCount = _chatProvider.messages.length;
    _chatProvider.addListener(_onMessagesChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    _chatProvider.removeListener(_onMessagesChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() => _currentTab = widget.tabController.index);
  }

  void _onMessagesChanged() {
    if (!mounted) return;
    final messages = _chatProvider.messages;
    if (messages.length > _lastMessageCount) {
      _lastMessageCount = messages.length;
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!AriAgent.isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AI 에이전트가 연결되어 있지 않습니다.')));
      return;
    }

    _controller.clear();
    _scrollToBottom();

    // 에이전트에게 전송 (AI 분석 요청)
    AriAgent.report(
      appId: 'aristock',
      type: 'CHAT_MESSAGE',
      message: text,
      details: {'currentTab': widget.tabLabels[_currentTab]},
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(left: BorderSide(color: AppTheme.textMain10, width: 1)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI 에이전트 분석',
                        style: TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '현재 모드: ${widget.tabLabels[_currentTab]}',
                        style: const TextStyle(
                          color: AppTheme.textSub,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => chatProvider.clearMessages(),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: AppTheme.textSub,
                  ),
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: Container(
              color: AppTheme.backgroundLight.withOpacity(0.3),
              child: chatProvider.messages.isEmpty
                  ? const ChatEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        return ChatMessageItem(
                          message: chatProvider.messages[index],
                        );
                      },
                    ),
            ),
          ),

          // Input Section
          ChatInputArea(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}
