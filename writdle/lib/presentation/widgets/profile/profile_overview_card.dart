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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primaryContainer,
            scheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.20),
            blurRadius: 32,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.onPrimary.withValues(alpha: 0.16),
                  border: Border.all(
                    color: scheme.onPrimary.withValues(alpha: 0.30),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(profile?.name ?? 'Guest User'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name ?? 'Guest User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile?.email ?? 'No email connected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      joinedLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.onPrimary.withValues(alpha: 0.14),
                  foregroundColor: scheme.onPrimary,
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            profile?.bio.trim().isNotEmpty == true
                ? profile!.bio.trim()
                : 'Build your identity here. Add a short bio and keep your progress visible across the app.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.92),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: scheme.onPrimary.withValues(alpha: 0.12),
              border: Border.all(
                color: scheme.onPrimary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: scheme.onPrimary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentDateTime,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary,
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
