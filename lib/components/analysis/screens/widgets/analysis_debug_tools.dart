import 'package:flutter/material.dart';
import '../../providers/analysis_provider.dart';
import '../../providers/analysis_provider_debug.dart';

class AnalysisDebugTools extends StatelessWidget {
  final AnalysisProvider provider;
  final String symbol;
  final String name;

  const AnalysisDebugTools({
    super.key,
    required this.provider,
    required this.symbol,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () => provider.loadSampleIssueTrace(symbol, name),
          icon: const Icon(
            Icons.playlist_add_check_circle_rounded,
            size: 16,
            color: Colors.blue,
          ),
          label: const Text(
            'DEBUG: 샘플 데이터',
            style: TextStyle(color: Colors.blue, fontSize: 11),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => provider.toggleAiModificationDebug(),
          icon: const Icon(Icons.edit_note, size: 16, color: Colors.deepPurple),
          label: const Text(
            'AI 수정 시뮬',
            style: TextStyle(color: Colors.deepPurple, fontSize: 11),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () => provider.toggleAiAdditionDebug(),
          icon: const Icon(
            Icons.add_box_outlined,
            size: 16,
            color: Colors.indigo,
          ),
          label: const Text(
            'AI 추가 시뮬',
            style: TextStyle(color: Colors.indigo, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
