import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/wordle_game_logic.dart';

class KeyboardWidget extends StatelessWidget {
  const KeyboardWidget({
    super.key,
    required this.keyStatus,
    required this.onKeyTap,
    this.highContrast = false,
  });

  final Map<String, LetterStatus> keyStatus;
  final void Function(String) onKeyTap;
  final bool highContrast;

  Color _getColor(LetterStatus status) {
    if (highContrast) {
      switch (status) {
        case LetterStatus.correct:
          return const Color(0xFF0EA5E9);
        case LetterStatus.present:
          return const Color(0xFFF97316);
        case LetterStatus.absent:
          return const Color(0xFF475569);
        case LetterStatus.initial:
          return const Color(0xFF1F2937);
      }
    }

    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF16A34A);
      case LetterStatus.present:
        return const Color(0xFFEAB308);
      case LetterStatus.absent:
        return const Color(0xFF4B5563);
      case LetterStatus.initial:
        return const Color(0xFF1F2937);
    }
  }

  Widget _buildKey(String letter, {double flex = 1}) {
    final status = keyStatus[letter] ?? LetterStatus.initial;

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => onKeyTap(letter),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColor(status),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const row1 = 'QWERTYUIOP';
    const row2 = 'ASDFGHJKL';
    const row3 = 'ZXCVBNM';

    return Column(
      children: [
        Row(children: row1.split('').map((e) => _buildKey(e)).toList()),
        Row(
          children: [
            const SizedBox(width: 18),
            ...row2.split('').map((e) => _buildKey(e)).toList(),
            const SizedBox(width: 18),
          ],
        ),
        Row(
          children: [
            _buildKey('ENTER', flex: 2),
            ...row3.split('').map((e) => _buildKey(e)).toList(),
            _buildKey('BACK', flex: 2),
          ],
        ),
      ],
    );
  }
}
