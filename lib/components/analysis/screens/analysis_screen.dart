import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../providers/analysis_provider.dart';
import '../../watchlist/providers/watchlist_provider.dart';
import '../models/analysis_model.dart';
import '../widgets/trend_summary_card.dart';
import '../widgets/analysis_history_selector.dart';
import '../widgets/analysis_report_header.dart';
import '../widgets/analysis_checkpoint_card.dart';
import '../widgets/analysis_info_card.dart';
import '../widgets/user_note_card.dart';
import 'package:ari_plugin/ari_plugin.dart';
import '../../../shared/theme.dart';


/// 종목분석 화면: AI 애널리스트가 생성한 구조화된 리포트를 렌더링합니다.
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _lastSyncedSymbol;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedSymbol = context.watch<WatchlistProvider>().selectedSymbol;

    if (selectedSymbol != null && selectedSymbol != _lastSyncedSymbol) {
      _lastSyncedSymbol = selectedSymbol;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AnalysisProvider>().selectStock(selectedSymbol);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final analysisProvider = context.watch<AnalysisProvider>();
    final selectedStock = watchlistProvider.selectedStock;

    if (selectedStock == null) {
      return _buildNoSelectionState();
    }

    return Scaffold(
      body: analysisProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(selectedStock.name),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AnalysisHistorySelector(
                          logs: analysisProvider.currentStockLogs,
                          selectedLog: analysisProvider.selectedLog,
                          onSelect: (log) => analysisProvider.selectLog(log),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AI 신규 분석 요청 버튼 (실제 통신 로직 포함)
                      _buildRequestAnalysisButton(context, selectedStock.symbol),
                    ],
                  ),

                  if (analysisProvider.selectedLog != null) ...[
                    const SizedBox(height: 24),
                    AnalysisReportHeader(
                      stockName: selectedStock.name,
                      date: analysisProvider.selectedLog!.date,
                    ),
                    const SizedBox(height: 32),
                    _buildStructuredAnalysis(
                      context,
                      analysisProvider.selectedLog!,
                    ),
                    const SizedBox(height: 32),
                    UserNoteCard(
                      initialNote: analysisProvider.selectedLog!.userNote,
                      onChanged: (value) =>
                          analysisProvider.updateUserNote(value),
                    ),
                  ] else
                    _buildEmptyState(),
                  const SizedBox(height: 40),
                  _buildResetButton(context, analysisProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildNoSelectionState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app_outlined,
              size: 64, color: AppTheme.textMain24),
          const SizedBox(height: 24),
          const Text(
            '분석할 종목을 먼저 선택해 주세요.',
            style: TextStyle(
              color: AppTheme.textMain54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '우측 상단의 종목 버튼을 눌러 관심종목을 선택하세요.',
            style: TextStyle(color: AppTheme.textMain38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final symbol = watchlistProvider.selectedSymbol;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppTheme.textMain24,
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 분석 내역이 없습니다.',
              style: TextStyle(color: AppTheme.textMain54),
            ),
            const SizedBox(height: 24),
            if (symbol != null)
              _buildRequestAnalysisButton(context, symbol, isLarge: true)
            else
              const Text(
                'AI 분석을 요청해 보세요.',
                style: TextStyle(
                  color: AppTheme.textMain38,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 신규 분석 요청 버튼 빌더
  Widget _buildRequestAnalysisButton(BuildContext context, String symbol,
      {bool isLarge = false}) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (WsManager.isConnected) {
          WsManager.sendAsync('/APP.REPORT', {
            'appId': 'aristock',
            'event': 'REQUEST_ANALYSIS',
            'message': '$symbol 종목에 대한 실시간 시장 상황과 기술적 지표를 분석하여 신규 리포트를 작성해줘.',
            'params': {'symbol': symbol}
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI에게 "$symbol" 신규 분석을 요청했습니다...'),
              backgroundColor: AppTheme.primaryBlue,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('서버와 연결이 끊겨 있습니다. 상태를 확인해 주세요.'),
              backgroundColor: AppTheme.accentRed,
            ),
          );
        }
      },
      icon: Icon(Icons.auto_awesome, size: isLarge ? 20 : 14),
      label: Text(
        'AI 신규 분석',
        style: TextStyle(fontSize: isLarge ? 14 : 11),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 24 : 12,
          vertical: isLarge ? 16 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLarge ? 16 : 8),
        ),
        elevation: isLarge ? 2 : 0,
      ),
    );
  }


  Widget _buildSectionHeader(String stockName) {
    return Row(
      children: [
        const Icon(Icons.history, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          '$stockName 분석 히스토리',
          style: const TextStyle(
            color: AppTheme.textMain,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStructuredAnalysis(BuildContext context, AnalysisLog log) {
    final analysisProvider = context.read<AnalysisProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrendSummaryCard(
          shortTerm: log.shortTermScore,
          mediumTerm: log.mediumTermScore,
          longTerm: log.longTermScore,
        ),
        const SizedBox(height: 32),
        AnalysisInfoCard(
          title: 'AI 분석 요약',
          content: log.summary ?? '',
          icon: Icons.summarize_outlined,
          themeColor: AppTheme.primaryBlue,
        ),
        if (log.summary != null && log.summary!.isNotEmpty)
          const SizedBox(height: 24),
        AnalysisCheckPointCard(
          checkPoints: log.checkPoints ?? [],
          onToggle: (point) => analysisProvider.toggleCheckPoint(point),
          onInvestigate: (point) async {
            // 상태를 '조사 중'으로 변경
            await analysisProvider.updateCheckPoint(point, status: 'investigating');
            
            // 서버(AI)에 심화 조사 요청 전송 (양방향 통신 활용)
            if (WsManager.isConnected) {
            WsManager.sendAsync('/APP.REPORT', {
                'appId': 'aristock',
                'event': 'INVESTIGATE_CHECKPOINT',
                'message': '${log.symbol} 종목의 "${point.content}" 항목에 대해 상세 분석을 수행하고 추가 정보를 리포트해줘.',
                'params': {
                  'symbol': log.symbol,
                  'content': point.content,
                  'isPositive': point.isPositive,
                }
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI가 "${point.content}"에 대해 심화 조사를 시작합니다...'),
                    backgroundColor: AppTheme.primaryBlue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),

        if (log.checkPoints != null && log.checkPoints!.isNotEmpty)
          const SizedBox(height: 24),
        AnalysisInfoCard(
          title: '기타 의견',
          content: log.otherOpinions ?? '',
          icon: Icons.lightbulb_outline,
          themeColor: Colors.orange,
        ),
        if (log.otherOpinions != null && log.otherOpinions!.isNotEmpty)
          const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context, AnalysisProvider provider) {
    return Column(
      children: [
        Center(
          child: TextButton.icon(
            onPressed: () => _showResetConfirmDialog(context, provider),
            icon: const Icon(
              Icons.delete_outline,
              size: 16,
              color: AppTheme.textMain38,
            ),
            label: const Text(
              '현재 종목 분석 데이터 초기화',
              style: TextStyle(color: AppTheme.textMain38, fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => _showForceResetDialog(context, provider),
              icon: const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: AppTheme.accentRed,
              ),
              label: const Text(
                'DEBUG: 모든 디비 데이터 완전 삭제',
                style: TextStyle(color: AppTheme.accentRed, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showResetConfirmDialog(
    BuildContext context,
    AnalysisProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          '데이터 초기화',
          style: TextStyle(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '현재 종목의 모든 분석 내역이 삭제됩니다.\n계속하시겠습니까?',
          style: TextStyle(color: AppTheme.textMain70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textMain54),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text(
              '초기화',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showForceResetDialog(
    BuildContext context,
    AnalysisProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          '디비 완전 초기화 (DEBUG)',
          style: TextStyle(
            color: AppTheme.accentRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '디스크에 저장된 분석 관련 하이브 박스를 통째로 날립니다.\n구조 변경(HiveField)으로 인한 오류 해결을 위해 사용하세요.\n모든 데이터가 삭제되며 되돌릴 수 없습니다.',
          style: TextStyle(color: AppTheme.textMain70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: AppTheme.textMain54)),
          ),
          TextButton(
            onPressed: () {
              provider.forceResetDatabase();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('데이터베이스가 완전히 삭제되었습니다.')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}
