import 'package:flutter/material.dart';
import '../consultation/screens/consultation_screen.dart';
import '../strategy/screens/strategy_screen.dart';
import '../account/screens/account_screen.dart';
import '../../../shared/theme.dart';
import 'package:ari_plugin/ari_plugin.dart';

/// 앱의 메인 레이아웃을 담당합니다.
/// 상단 탭 메뉴(브리핑-종목상담-매매전략-내계좌)를 포함하며 프리미엄한 디자인을 지향합니다.
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_graph,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ARIStock',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              // 서버 접속 상태 표시 (녹색점) - StreamBuilder로 실시간 감지
              StreamBuilder<bool>(
                stream: WsManager.connectionStream,
                initialData: WsManager.isConnected,
                builder: (context, snapshot) {
                  final isConnected = snapshot.data ?? false;
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: TabBar(
            tabs: const [
              Tab(text: '종목상담'),
              Tab(text: '매매전략'),
              Tab(text: '포트폴리오상담'),
            ],
            indicatorColor: AppTheme.primaryBlue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                AppTheme.surfaceDark.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: const TabBarView(
            children: [ConsultationScreen(), StrategyScreen(), AccountScreen()],
          ),
        ),
      ),
    );
  }
}
