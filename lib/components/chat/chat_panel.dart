import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../shared/theme.dart';
import 'chat_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _currentTab = widget.tabController.index;
    widget.tabController.addListener(_onTabChanged);
    _lastMessageCount = context.read<ChatProvider>().messages.length;
    context.read<ChatProvider>().addListener(_onMessagesChanged);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    context.read<ChatProvider>().removeListener(_onMessagesChanged);
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
    final messages = context.read<ChatProvider>().messages;
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

    // 에이전트에게 전송 (이제 requestId를 지원합니다)
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
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageItem(chatProvider.messages[index]);
                      },
                    ),
            ),
          ),

          // Input Section
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.forum_outlined,
              size: 32,
              color: AppTheme.primaryBlue.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '무엇을 함께 분석해 볼까요?',
            style: TextStyle(
              color: AppTheme.textMain,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF64B5F6)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryBlue
                    : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textMain,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textMain10),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppTheme.textMain, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: '분석 요청...',
                  hintStyle: TextStyle(
                    color: AppTheme.textMain38,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
