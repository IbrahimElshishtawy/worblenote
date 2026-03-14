import 'package:flutter/material.dart';

class NoteColorPalette extends StatelessWidget {
  const NoteColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  static const _options = [
    ('Red', 0xFFFFC2C2),
    ('Green', 0xFFC8EDC8),
    ('Blue', 0xFFC9D9FF),
    ('Orange', 0xFFFFD6B0),
    ('Purple', 0xFFE2D0FF),
    ('Pink', 0xFFFFCEE5),
    ('Rose', 0xFFFFD4DD),
    ('Brown', 0xFFE3CDBE),
    ('Sky', 0xFFCDEFFF),
    ('Lilac', 0xFFEBD8FF),
    ('White', 0xFFF6F6F6),
  ];

  Color _adaptiveTextColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    return brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.94)
        : const Color(0xFF3F342B);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedOption = _options.firstWhere(
      (option) => option.$2 == selectedColor,
      orElse: () => _options.first,
    );
    final selectedChipColor = Color(selectedOption.$2);
    final selectedTextColor = _adaptiveTextColor(selectedChipColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Note color',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.78),
                    selectedChipColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Text(
                selectedOption.$1,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selectedTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Pick the tone you want this note card to use.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _options.map((option) {
            final colorValue = option.$2;
            final isSelected = selectedColor == colorValue;
            final baseColor = Color(colorValue);
            return InkWell(
              onTap: () => onColorSelected(colorValue),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      baseColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? scheme.primary : scheme.outlineVariant,
                    width: isSelected ? 2.5 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, size: 18, color: scheme.primary)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
