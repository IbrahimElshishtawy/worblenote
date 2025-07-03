// lib/widgets/note_list.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Future<void> _showNoteDialog({DocumentSnapshot? note}) async {
    if (note != null) {
      _titleController.text = note['title'];
      _descController.text = note['description'];
    } else {
      _titleController.clear();
      _descController.clear();
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note != null ? 'Edit Note' : 'Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Note Title'),
            ),
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

              final col = FirebaseFirestore.instance.collection('notes');
              if (note != null) {
                await col.doc(note.id).update({
                  'title': title,
                  'description': desc,
                });
              } else {
                await col.add({
                  'title': title,
                  'description': desc,
                  'timestamp': FieldValue.serverTimestamp(),
                  'date': widget.date,
                });
              }

              Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(String id) async {
    await FirebaseFirestore.instance.collection('notes').doc(id).delete();
    setState(() {});
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    return DateFormat('yyyy/MM/dd – hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('date', isEqualTo: widget.date)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final notes = snapshot.data?.docs ?? [];
            final filteredNotes = notes.where((note) {
              final title = (note['title'] ?? '').toLowerCase();
              final desc = (note['description'] ?? '').toLowerCase();
              return title.contains(widget.searchQuery.toLowerCase()) ||
                  desc.contains(widget.searchQuery.toLowerCase());
            }).toList();

            if (filteredNotes.isEmpty) {
              return const Center(child: Text('No notes for this day.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredNotes.length,
              itemBuilder: (_, index) {
                final note = filteredNotes[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      note['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((note['description'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(note['description']),
                          ),
                        Text(
                          _formatDate(note['timestamp']),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showNoteDialog(note: note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
  }
}
