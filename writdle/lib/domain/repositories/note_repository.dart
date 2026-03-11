import 'package:writdle/domain/entities/note_model.dart';

abstract class INoteRepository {
  Future<List<NoteModel>> getNotes(String date);
  Future<void> addNote(NoteModel note, String date);
  Future<void> updateNote(NoteModel note, String date);
  Future<void> deleteNote(String id, String date);
}
