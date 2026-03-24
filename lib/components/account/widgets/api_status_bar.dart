import 'package:flutter/material.dart';
import '../providers/account_provider.dart';
import '../screens/api_key_setup_screen.dart';
import '../../../shared/theme.dart';

class ApiStatusBar extends StatelessWidget {
  final AccountProvider accountProvider;
  final Function(BuildContext) onDisconnect;

  const ApiStatusBar({
    super.key,
    required this.accountProvider,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = accountProvider.hasApiKeys;
    final statusColor = !isConnected 
        ? AppTheme.textMain24 
        : (accountProvider.credentials!.isMock ? Colors.amber : AppTheme.accentGreen);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isConnected ? '키움 API 연동됨' : '키움 API 미연동',
                      style: TextStyle(
                        color: isConnected ? statusColor : AppTheme.textMain54,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isConnected && accountProvider.credentials!.isMock) ...[
                      const SizedBox(width: 8),
                      _buildMockTag(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  accountProvider.lastError != null
                      ? '오류: ${accountProvider.lastError}'
                      : isConnected 
                          ? 'App Key: ${_maskKey(accountProvider.credentials!.appKey)}'
                          : '실시간 데이터를 위해 API를 연동하세요',
                  style: TextStyle(
                    color: accountProvider.lastError != null ? AppTheme.accentRed : AppTheme.textMain.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isConnected 
                ? () => onDisconnect(context)
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ApiKeySetupScreen()),
                    ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              isConnected ? '연동해제' : '연동하기',
              style: TextStyle(
                color: isConnected ? AppTheme.accentRed : AppTheme.primaryBlue, 
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '모의',
        style: TextStyle(
          color: Colors.amber,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _maskKey(String key) {
    if (key.length <= 8) {
      return '****${key.substring(key.length > 4 ? key.length - 4 : 0)}';
    }
    return '${key.substring(0, 4)}****${key.substring(key.length - 4)}';
  }
}
