import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:writdle/providers/notes_provider.dart';
import 'package:writdle/service/notification_service.dart';

class NoteList extends StatefulWidget {
  final String date;
  final String searchQuery;

  const NoteList({super.key, required this.date, required this.searchQuery});

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
      context.read<NotesProvider>().fetchNotes(widget.date);
    });
  }

  @override
  void didUpdateWidget(NoteList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      context.read<NotesProvider>().fetchNotes(widget.date);
    }
  }

  Future<void> _showNoteDialog({String? id, String? currentTitle, String? currentDesc}) async {
    if (id != null) {
      _titleController.text = currentTitle ?? '';
      _descController.text = currentDesc ?? '';
    } else {
      _titleController.clear();
      _descController.clear();
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id != null ? 'Edit Note' : 'Add Note'),
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
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final title = _titleController.text.trim();
              final desc = _descController.text.trim();
              if (title.isEmpty) return;

              final notesProvider = context.read<NotesProvider>();
              if (id != null) {
                await notesProvider.updateNote(id, title, desc, widget.date);
                if (mounted) NotificationService.showSnackBar(context, "Note updated!");
              } else {
                await notesProvider.addNote(title, desc, widget.date);
                if (mounted) NotificationService.showSnackBar(context, "Note added!");
              }

              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredNotes = notesProvider.notes.where((note) {
          return note.title.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(widget.searchQuery.toLowerCase());
        }).toList();

        if (filteredNotes.isEmpty) {
          return const Center(child: Text('No notes for this day.'));
        }

        return Stack(
          children: [
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
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showNoteDialog(
                            id: note.id,
                            currentTitle: note.title,
                            currentDesc: note.content,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await notesProvider.deleteNote(note.id, widget.date);
                            if (mounted) NotificationService.showSnackBar(context, "Note deleted");
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 20,
              right: 20,
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
