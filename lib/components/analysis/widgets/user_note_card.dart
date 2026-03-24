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
    final controller = TextEditingController(text: initialNote);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, size: 18, color: AppTheme.textMain70),
            const SizedBox(width: 8),
            Text(
              '나의 투자 노트',
              style: TextStyle(
                color: AppTheme.textMain70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.textMain10),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '이 종목에 대한 나만의 생각이나 매매 계획을 기록하세요...',
              hintStyle: TextStyle(color: AppTheme.textMain24, fontSize: 13),
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: AppTheme.textMain, fontSize: 14),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
