import 'package:writdle/core/auth/local_auth_store.dart';
import 'package:writdle/data/datasources/note_local_cache.dart';
import 'package:writdle/domain/entities/note_load_result.dart';
import 'package:writdle/domain/entities/note_model.dart';
import 'package:writdle/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements INoteRepository {
  NoteRepositoryImpl({NoteLocalCache? localCache})
    : _localCache = localCache ?? NoteLocalCache();

  final NoteLocalCache _localCache;

  @override
  Future<NoteLoadResult> getNotes(String date) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return const NoteLoadResult(notes: []);
    }

    final notes = await _localCache.readNotes(userId, date);
    return NoteLoadResult(notes: notes, isFromCache: true);
  }

  @override
  Future<void> addNote(NoteModel note, String date) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return;
    }

    final localId = note.id.isEmpty
        ? 'local_${DateTime.now().microsecondsSinceEpoch}'
        : note.id;
    final localNote = note.copyWith(id: localId);
    final cachedNotes = await _localCache.readNotes(userId, date);
    await _localCache.saveNotes(userId, date, [localNote, ...cachedNotes]);
  }

  @override
  Future<void> updateNote(NoteModel note, String date) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return;
    }

    final cachedNotes = await _localCache.readNotes(userId, date);
    final updatedNotes = cachedNotes
        .map((item) => item.id == note.id ? note : item)
        .toList();
    await _localCache.saveNotes(userId, date, updatedNotes);
  }

  @override
  Future<void> deleteNote(String id, String date) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return;
    }

    final cachedNotes = await _localCache.readNotes(userId, date);
    await _localCache.saveNotes(
      userId,
      date,
      cachedNotes.where((item) => item.id != id).toList(),
    );
  }
}
