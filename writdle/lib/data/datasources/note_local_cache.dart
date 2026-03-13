import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/domain/entities/note_model.dart';

class NoteLocalCache {
  static const _notesPrefix = 'notes_cache_';
  static const _queuePrefix = 'notes_queue_';

  Future<List<NoteModel>> readNotes(String userId, String date) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_notesPrefix$userId\_$date');
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => NoteModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNotes(String userId, String date, List<NoteModel> notes) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_notesPrefix$userId\_$date',
      jsonEncode(notes.map((note) => note.toJson()).toList()),
    );
  }

  Future<List<Map<String, dynamic>>> readQueue(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_queuePrefix$userId');
    if (raw == null || raw.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List<dynamic>);
  }

  Future<void> saveQueue(String userId, List<Map<String, dynamic>> queue) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_queuePrefix$userId',
      jsonEncode(queue),
    );
  }
}
