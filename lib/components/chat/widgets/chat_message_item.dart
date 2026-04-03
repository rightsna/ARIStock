import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../shared/theme.dart';
import '../chat_provider.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 38),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.text,
              style: TextStyle(
                color: AppTheme.textMain.withOpacity(0.4),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

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
              child: message.isUser
                  ? SelectableText(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppTheme.textMain,
                          height: 1.4,
                          fontSize: 13,
                        ),
                        h1: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        h2: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        h3: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                        ),
                        em: const TextStyle(
                          color: AppTheme.textSub,
                          fontStyle: FontStyle.italic,
                        ),
                        code: TextStyle(
                          color: AppTheme.primaryBlue,
                          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                              width: 3,
                            ),
                          ),
                        ),
                        blockquote: const TextStyle(
                          color: AppTheme.textSub,
                          fontSize: 13,
                        ),
                        listBullet: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 13,
                        ),
                        tableBody: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 12,
                        ),
                        tableHead: const TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
