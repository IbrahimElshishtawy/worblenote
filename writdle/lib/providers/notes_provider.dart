import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writdle/models/note_model.dart';

class NotesProvider with ChangeNotifier {
  List<NoteModel> _notes = [];
  bool _isLoading = false;

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes(String date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .orderBy('timestamp', descending: true)
          .get();

      _notes = snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String title, String description, String date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('notes').add({
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'date': date,
    });
    await fetchNotes(date);
  }

  Future<void> updateNote(String id, String title, String description, String date) async {
    await FirebaseFirestore.instance.collection('notes').doc(id).update({
      'title': title,
      'description': description,
    });
    await fetchNotes(date);
  }

  Future<void> deleteNote(String id, String date) async {
    await FirebaseFirestore.instance.collection('notes').doc(id).delete();
    await fetchNotes(date);
  }
}
