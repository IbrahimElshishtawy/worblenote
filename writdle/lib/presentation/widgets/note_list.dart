import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/presentation/bloc/notes_cubit.dart';

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

  Future<void> _showNoteDialog({
    String? id,
    String? currentTitle,
    String? currentDesc,
  }) async {
    _titleController.text = currentTitle ?? '';
    _descController.text = currentDesc ?? '';

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(id == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Note Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final description = _descController.text.trim();
                if (title.isEmpty) {
                  return;
                }

                if (id == null) {
                  await context.read<NotesCubit>().addNote(
                    title,
                    description,
                    widget.date,
                  );
                  if (!mounted) {
                    return;
                  }
                  context.read<AppNotificationCubit>().show(
                    'Note added!',
                    type: AppNotificationType.success,
                  );
                } else {
                  await context.read<NotesCubit>().updateNote(
                    id,
                    title,
                    description,
                    widget.date,
                  );
                  if (!mounted) {
                    return;
                  }
                  context.read<AppNotificationCubit>().show(
                    'Note updated!',
                    type: AppNotificationType.success,
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final filteredNotes = state.notes.where((note) {
          final query = widget.searchQuery.toLowerCase();
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query);
        }).toList();

        return Stack(
          children: [
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredNotes.isEmpty)
              const Center(child: Text('No notes for this day.'))
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredNotes.length,
                itemBuilder: (_, index) {
                  final note = filteredNotes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.content.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(note.content),
                            ),
                          Text(
                            DateFormat('hh:mm a').format(note.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showNoteDialog(
                                id: note.id,
                                currentTitle: note.title,
                                currentDesc: note.content,
                              );
                            },
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () async {
                              await context.read<NotesCubit>().deleteNote(
                                note.id,
                                widget.date,
                              );
                              if (!mounted) {
                                return;
                              }
                              context.read<AppNotificationCubit>().show(
                                'Note deleted',
                                type: AppNotificationType.info,
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () => _showNoteDialog(),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
