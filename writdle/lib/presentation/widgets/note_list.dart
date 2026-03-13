import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/presentation/bloc/notes_cubit.dart';
import 'package:writdle/presentation/widgets/notes/note_card.dart';
import 'package:writdle/presentation/widgets/notes/note_editor_sheet.dart';
import 'package:writdle/presentation/widgets/notes/notes_empty_state.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key, required this.date, required this.searchQuery});

  final String date;
  final String searchQuery;

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesCubit>().fetchNotes(widget.date);
    });
  }

  @override
  void didUpdateWidget(NoteList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      context.read<NotesCubit>().fetchNotes(widget.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _openEditor({String? id, String? currentTitle, String? currentDesc}) async {
    _titleController.text = currentTitle ?? '';
    _descController.text = currentDesc ?? '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => NoteEditorSheet(
        titleController: _titleController,
        descriptionController: _descController,
        isEditing: id != null,
        onSave: () async {
          final title = _titleController.text.trim();
          final description = _descController.text.trim();
          if (title.isEmpty) {
            context.read<AppNotificationCubit>().show(
              'Please enter a note title.',
              type: AppNotificationType.error,
            );
            return;
          }

          if (id == null) {
            await context.read<NotesCubit>().addNote(title, description, widget.date);
            if (!mounted) {
              return;
            }
            context.read<AppNotificationCubit>().show(
              'Note saved successfully.',
              type: AppNotificationType.success,
            );
          } else {
            await context.read<NotesCubit>().updateNote(id, title, description, widget.date);
            if (!mounted) {
              return;
            }
            context.read<AppNotificationCubit>().show(
              'Note updated successfully.',
              type: AppNotificationType.success,
            );
          }

          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final query = widget.searchQuery.toLowerCase();
        final filteredNotes = state.notes.where((note) {
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query);
        }).toList();

        return Stack(
          children: [
            Column(
              children: [
                if (state.isOfflineData)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE68A),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off_rounded, color: Color(0xFF92400E)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Showing offline notes. Changes will sync when the connection is back.',
                            style: TextStyle(
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredNotes.isEmpty
                          ? NotesEmptyState(query: widget.searchQuery)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                              itemCount: filteredNotes.length,
                              itemBuilder: (_, index) {
                                final note = filteredNotes[index];
                                return NoteCard(
                                  note: note,
                                  onEdit: () => _openEditor(
                                    id: note.id,
                                    currentTitle: note.title,
                                    currentDesc: note.content,
                                  ),
                                  onDelete: () async {
                                    await context.read<NotesCubit>().deleteNote(note.id, widget.date);
                                    if (!mounted) {
                                      return;
                                    }
                                    context.read<AppNotificationCubit>().show(
                                      'Note deleted.',
                                      type: AppNotificationType.info,
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
            Positioned(
              right: 22,
              bottom: 24,
              child: FloatingActionButton.extended(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Note'),
              ),
            ),
          ],
        );
      },
    );
  }
}
