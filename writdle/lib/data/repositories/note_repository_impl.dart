import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writdle/data/datasources/note_local_cache.dart';
import 'package:writdle/domain/entities/note_load_result.dart';
import 'package:writdle/domain/entities/note_model.dart';
import 'package:writdle/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements INoteRepository {
  NoteRepositoryImpl({NoteLocalCache? localCache})
    : _localCache = localCache ?? NoteLocalCache();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NoteLocalCache _localCache;

  @override
  Future<NoteLoadResult> getNotes(String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const NoteLoadResult(notes: []);
    }

    await _syncPendingOperations(userId);

    try {
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .orderBy('timestamp', descending: true)
          .get();

      final notes = snapshot.docs
          .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
          .toList();
      await _localCache.saveNotes(userId, date, notes);
      return NoteLoadResult(notes: notes);
    } catch (_) {
      final cachedNotes = await _localCache.readNotes(userId, date);
      return NoteLoadResult(notes: cachedNotes, isFromCache: true);
    }
  }

  @override
  Future<void> addNote(NoteModel note, String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    final localId =
        note.id.isEmpty ? 'local_${DateTime.now().microsecondsSinceEpoch}' : note.id;
    final localNote = note.copyWith(id: localId);
    final cachedNotes = await _localCache.readNotes(userId, date);
    final updatedNotes = [localNote, ...cachedNotes];
    await _localCache.saveNotes(userId, date, updatedNotes);

    try {
      final reference = await _firestore.collection('notes').add({
        'userId': userId,
        'title': note.title,
        'description': note.content,
        'timestamp': FieldValue.serverTimestamp(),
        'date': date,
      });
      final syncedNotes = updatedNotes
          .map((item) => item.id == localId ? item.copyWith(id: reference.id) : item)
          .toList();
      await _localCache.saveNotes(userId, date, syncedNotes);
    } catch (_) {
      await _enqueueOperation(userId, {
        'type': 'add',
        'date': date,
        'note': localNote.toJson(),
      });
    }
  }

  @override
  Future<void> updateNote(NoteModel note, String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    final cachedNotes = await _localCache.readNotes(userId, date);
    final updatedNotes = cachedNotes
        .map((item) => item.id == note.id ? note : item)
        .toList();
    await _localCache.saveNotes(userId, date, updatedNotes);

    if (note.id.startsWith('local_')) {
      await _replaceLocalAddOperation(userId, note, date);
      return;
    }

    try {
      await _firestore.collection('notes').doc(note.id).update({
        'title': note.title,
        'description': note.content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _enqueueOperation(userId, {
        'type': 'update',
        'date': date,
        'note': note.toJson(),
      });
    }
  }

  @override
  Future<void> deleteNote(String id, String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    final cachedNotes = await _localCache.readNotes(userId, date);
    await _localCache.saveNotes(
      userId,
      date,
      cachedNotes.where((item) => item.id != id).toList(),
    );

    if (id.startsWith('local_')) {
      await _removeLocalPendingAdd(userId, id);
      return;
    }

    try {
      await _firestore.collection('notes').doc(id).delete();
    } catch (_) {
      await _enqueueOperation(userId, {
        'type': 'delete',
        'date': date,
        'id': id,
      });
    }
  }

  Future<void> _enqueueOperation(String userId, Map<String, dynamic> operation) async {
    final queue = await _localCache.readQueue(userId);
    queue.add(operation);
    await _localCache.saveQueue(userId, queue);
  }

  Future<void> _replaceLocalAddOperation(
    String userId,
    NoteModel note,
    String date,
  ) async {
    final queue = await _localCache.readQueue(userId);
    final updatedQueue = queue.map((operation) {
      if (operation['type'] == 'add') {
        final current = NoteModel.fromJson(
          Map<String, dynamic>.from(operation['note'] as Map),
        );
        if (current.id == note.id) {
          return {
            'type': 'add',
            'date': date,
            'note': note.toJson(),
          };
        }
      }
      return operation;
    }).toList();
    await _localCache.saveQueue(userId, updatedQueue);
  }

  Future<void> _removeLocalPendingAdd(String userId, String noteId) async {
    final queue = await _localCache.readQueue(userId);
    queue.removeWhere((operation) {
      if (operation['type'] != 'add') {
        return false;
      }
      final note = NoteModel.fromJson(
        Map<String, dynamic>.from(operation['note'] as Map),
      );
      return note.id == noteId;
    });
    await _localCache.saveQueue(userId, queue);
  }

  Future<void> _syncPendingOperations(String userId) async {
    final queue = await _localCache.readQueue(userId);
    if (queue.isEmpty) {
      return;
    }

    final pending = List<Map<String, dynamic>>.from(queue);
    final failed = <Map<String, dynamic>>[];

    for (var index = 0; index < pending.length; index++) {
      final operation = pending[index];
      try {
        final type = operation['type'] as String? ?? '';
        final date = operation['date'] as String? ?? '';

        if (type == 'add') {
          final note = NoteModel.fromJson(
            Map<String, dynamic>.from(operation['note'] as Map),
          );
          final reference = await _firestore.collection('notes').add({
            'userId': userId,
            'title': note.title,
            'description': note.content,
            'timestamp': FieldValue.serverTimestamp(),
            'date': date,
          });
          final cachedNotes = await _localCache.readNotes(userId, date);
          final syncedNotes = cachedNotes
              .map((item) => item.id == note.id
                  ? item.copyWith(id: reference.id)
                  : item)
              .toList();
          await _localCache.saveNotes(userId, date, syncedNotes);

          for (var nextIndex = index + 1; nextIndex < pending.length; nextIndex++) {
            final nextOperation = pending[nextIndex];
            if (nextOperation['note'] != null) {
              final nextNote = NoteModel.fromJson(
                Map<String, dynamic>.from(nextOperation['note'] as Map),
              );
              if (nextNote.id == note.id) {
                pending[nextIndex] = {
                  ...nextOperation,
                  'note': nextNote.copyWith(id: reference.id).toJson(),
                };
              }
            }
            if (nextOperation['id'] == note.id) {
              pending[nextIndex] = {
                ...nextOperation,
                'id': reference.id,
              };
            }
          }
        } else if (type == 'update') {
          final note = NoteModel.fromJson(
            Map<String, dynamic>.from(operation['note'] as Map),
          );
          await _firestore.collection('notes').doc(note.id).update({
            'title': note.title,
            'description': note.content,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else if (type == 'delete') {
          final id = operation['id'] as String? ?? '';
          await _firestore.collection('notes').doc(id).delete();
        }
      } catch (_) {
        failed.add(operation);
      }
    }

    await _localCache.saveQueue(userId, failed);
  }
}
