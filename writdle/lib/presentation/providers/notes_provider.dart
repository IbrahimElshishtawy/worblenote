import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/note_model.dart';
import 'package:writdle/domain/repositories/note_repository.dart';

class NotesProvider with ChangeNotifier {
  final INoteRepository _repository;
  List<NoteModel> _notes = [];
  bool _isLoading = false;

  NotesProvider(this._repository);

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes(String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.getNotes(date);
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String title, String description, String date) async {
    final note = NoteModel(
      id: '',
      title: title,
      content: description,
      createdAt: DateTime.now(),
    );
    await _repository.addNote(note, date);
    await fetchNotes(date);
  }

  Future<void> updateNote(String id, String title, String description, String date) async {
    final note = NoteModel(
      id: id,
      title: title,
      content: description,
      createdAt: DateTime.now(),
    );
    await _repository.updateNote(note, date);
    await fetchNotes(date);
  }

  Future<void> deleteNote(String id, String date) async {
    await _repository.deleteNote(id, date);
    await fetchNotes(date);
  }
}
