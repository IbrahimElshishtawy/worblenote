import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writdle/domain/entities/note_model.dart';
import 'package:writdle/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements INoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<NoteModel>> getNotes(String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addNote(NoteModel note, String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('notes').add({
      'userId': userId,
      'title': note.title,
      'description': note.content,
      'timestamp': FieldValue.serverTimestamp(),
      'date': date,
    });
  }

  @override
  Future<void> updateNote(NoteModel note, String date) async {
    await _firestore.collection('notes').doc(note.id).update({
      'title': note.title,
      'description': note.content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteNote(String id, String date) async {
    await _firestore.collection('notes').doc(id).delete();
  }
}
