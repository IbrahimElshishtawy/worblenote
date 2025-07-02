import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writdle/models/note_model.dart';
import 'package:writdle/models/task_model.dart';
import 'package:writdle/models/wordle_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tasks
  Future<void> addTask(TaskModel task) {
    return _db.collection('tasks').add(task.toMap());
  }

  Stream<List<TaskModel>> getTasks(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Notes
  Future<void> addNote(NoteModel note) {
    return _db.collection('notes').add(note.toMap());
  }

  Stream<List<NoteModel>> getNotes(String userId) {
    return _db
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Wordle
  Future<void> saveGame(WordleModel game) {
    return _db.collection('wordle_games').add(game.toMap());
  }

  Stream<List<WordleModel>> getGames(String userId) {
    return _db
        .collection('wordle_games')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WordleModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
