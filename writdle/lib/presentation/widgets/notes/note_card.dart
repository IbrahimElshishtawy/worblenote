import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:writdle/domain/entities/note_model.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _blendWithWhite(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  Color _adaptiveMenuColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.92)
        : const Color(0xFF3F342B);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final noteColor = Color(
      note.colorValue == 0 ? 0xFFFFF1B8 : note.colorValue,
    );
    final topColor = _blendWithWhite(noteColor, 0.28);
    final bottomColor = _blendWithWhite(noteColor, 0.02);
    final menuColor = _adaptiveMenuColor(bottomColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topColor, bottomColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2B2118),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  iconColor: menuColor,
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                note.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4E4034),
                  height: 1.55,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('hh:mm a').format(note.createdAt),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF5F544A),
                  ),
                ),
                const Spacer(),
                if (note.id.startsWith('local_'))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Local',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B4F2A),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
