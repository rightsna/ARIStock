import 'package:flutter/material.dart';
import '../../../../shared/theme.dart';

class UserNoteCard extends StatelessWidget {
  final String? initialNote;
  final Function(String) onChanged;

  const UserNoteCard({
    super.key,
    this.initialNote,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Note: TextEditingController setup is better done in a StatefulWidget 
    // but for simple cases this works if the parent doesn't rebuild too often.
    final controller = TextEditingController(text: initialNote);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3, height: 16,
              decoration: BoxDecoration(color: AppTheme.textMain38, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            const Text(
              '투자 리서치 메모',
              style: TextStyle(
                color: AppTheme.textMain,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.textMain10, width: 1.5), // 일관된 노트 테두리
          ),
          child: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: '이슈 분석 결과에 따른 나만의 매매 계획이나 관점을 기록하세요...',
              hintStyle: TextStyle(color: AppTheme.textMain24, fontSize: 13),
              contentPadding: EdgeInsets.all(20),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
