import 'package:flutter/material.dart';

class NotesHeader extends StatelessWidget {
  const NotesHeader({
    super.key,
    required this.formattedDate,
    required this.onPrevious,
    required this.onNext,
  });

  final String formattedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            scheme.primary.withValues(alpha: 0.92),
            scheme.secondary.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Notes',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your ideas, plans, and reflections with a cleaner writing space.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.86),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _DateArrowButton(icon: Icons.arrow_back_ios_new, onTap: onPrevious),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DateArrowButton(icon: Icons.arrow_forward_ios, onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateArrowButton extends StatelessWidget {
  const _DateArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: scheme.onPrimary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: scheme.onPrimary, size: 18),
      ),
    );
  }
}
