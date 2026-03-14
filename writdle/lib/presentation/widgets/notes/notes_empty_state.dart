import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  const NotesEmptyState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  hasQuery ? Icons.search_off_rounded : Icons.note_alt_outlined,
                  size: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                hasQuery ? 'No matching notes' : 'No notes for this day yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                hasQuery
                    ? 'Try another keyword or clear the search.'
                    : 'Start writing your first thought and it will appear here.',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
