import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/entities/note_model.dart';
import 'package:writdle/domain/repositories/note_repository.dart';

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedDate,
  });

  final List<NoteModel> notes;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedDate;

  NotesState copyWith({
    List<NoteModel>? notes,
    bool? isLoading,
    String? errorMessage,
    String? selectedDate,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository) : super(const NotesState());

  final INoteRepository _repository;

  Future<void> fetchNotes(String date) async {
    emit(state.copyWith(isLoading: true, selectedDate: date, clearError: true));
    try {
      final notes = await _repository.getNotes(date);
      emit(
        state.copyWith(
          notes: notes,
          isLoading: false,
          selectedDate: date,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load notes',
          selectedDate: date,
        ),
      );
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

  Future<void> updateNote(
    String id,
    String title,
    String description,
    String date,
  ) async {
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
