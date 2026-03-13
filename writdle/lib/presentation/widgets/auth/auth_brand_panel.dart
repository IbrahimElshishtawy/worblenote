import 'package:flutter/material.dart';

class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({
    super.key,
    this.centered = false,
    this.title = 'Welcome back',
    this.subtitle = 'Sign in to continue your notes, tasks, games, and progress with a smoother and safer login flow.',
  });

  final bool centered;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (!centered) ...[
          _BrandBadge(theme: theme, size: 82),
          const SizedBox(height: 24),
        ],
        Text(
          title,
          textAlign: textAlign,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: centered ? 420 : 480),
          child: Text(
            subtitle,
            textAlign: textAlign,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({
    required this.theme,
    required this.size,
  });

  final ThemeData theme;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset('assets/image/WR-Logo-1.jpg', fit: BoxFit.cover),
      ),
    );
  }
}
