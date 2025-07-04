// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:writdle/models/wordle_game_logic.dart';

class KeyboardWidget extends StatelessWidget {
  final Map<String, LetterStatus> keyStatus;
  final void Function(String) onKeyTap;

  const KeyboardWidget({
    super.key,
    required this.keyStatus,
    required this.onKeyTap,
  });

  Color _getColor(LetterStatus status) {
    switch (status) {
      case LetterStatus.correct:
        return Colors.green;
      case LetterStatus.present:
        return Colors.amber;
      case LetterStatus.absent:
        return Colors.grey.shade800;
      default:
        return Colors.black;
    }
  }

  Widget _buildKey(String letter, {double flex = 1}) {
    final status = keyStatus[letter] ?? LetterStatus.initial;

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => onKeyTap(letter),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getColor(status),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row1.split('').map((e) => _buildKey(e)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            ...row2.split('').map((e) => _buildKey(e)).toList(),
            const SizedBox(width: 20),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('ENTER', flex: 2),

            ...row3.split('').map((e) => _buildKey(e)).toList(),
            _buildKey('DEL', flex: 2),
          ],
        ),
      ],
    );
  }
}
