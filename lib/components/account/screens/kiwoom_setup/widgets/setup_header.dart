import 'package:flutter/material.dart';
import 'package:aristock/shared/theme.dart';

class SetupHeader extends StatelessWidget {
  const SetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 40),
        _buildTitle(context),
        const SizedBox(height: 12),
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.vpn_key_rounded, color: AppTheme.textMain, size: 36),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      '키움 API 연동',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textMain,
          ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      '실시간 포트폴리오 데이터를 가져오기 위해\n키움증권 Open API 인증 정보를 입력해주세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.textMain.withValues(alpha: 0.5),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}
