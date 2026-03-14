import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:writdle/domain/entities/profile_data.dart';

class ProfileOverviewCard extends StatelessWidget {
  const ProfileOverviewCard({
    super.key,
    required this.profile,
    required this.currentDateTime,
    required this.onEdit,
  });

  final ProfileData? profile;
  final String currentDateTime;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final joinedAt = profile?.joinedAt;
    final joinedLabel = joinedAt == null
        ? 'Member profile ready for your next update'
        : 'Joined ${DateFormat('MMM yyyy').format(joinedAt)}';

    final cardBackground = LinearGradient(
      colors: [
        scheme.primaryContainer.withValues(alpha: 0.82),
        scheme.surfaceContainerHighest.withValues(alpha: 0.94),
        scheme.secondaryContainer.withValues(alpha: 0.80),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: cardBackground,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: scheme.surface.withValues(alpha: 0.45),
                ),
                child: Text(
                  'Profile Overview',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: onEdit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  backgroundColor: scheme.surface.withValues(alpha: 0.58),
                  foregroundColor: scheme.onSurface,
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surface.withValues(alpha: 0.42),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(profile?.name ?? 'Guest User'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.name ?? 'Guest User',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? 'No email connected',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  joinedLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            profile?.bio.trim().isNotEmpty == true
                ? profile!.bio.trim()
                : 'Build your identity here. Add a short bio and keep your progress visible across the app.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.90),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: scheme.surface.withValues(alpha: 0.46),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.40),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: scheme.onSurface,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentDateTime,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'GU';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
