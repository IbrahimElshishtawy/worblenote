import 'package:flutter/material.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({
    super.key,
    required this.userName,
    required this.onProfileTap,
  });

  final String userName;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hello, $userName',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onProfileTap,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.onPrimary.withValues(alpha: 0.14),
                ),
                icon: Icon(Icons.person_outline, color: scheme.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Shape your day with writing, focus, and smart routines in one place.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
