import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/entities/note_load_result.dart';
import 'package:writdle/domain/entities/note_model.dart';
import 'package:writdle/domain/repositories/note_repository.dart';

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedDate,
    this.isOfflineData = false,
  });

  final List<NoteModel> notes;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedDate;
  final bool isOfflineData;

  NotesState copyWith({
    List<NoteModel>? notes,
    bool? isLoading,
    String? errorMessage,
    String? selectedDate,
    bool? isOfflineData,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
      isOfflineData: isOfflineData ?? this.isOfflineData,
    );
  }
}

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository) : super(const NotesState());

  final INoteRepository _repository;

  Future<void> fetchNotes(String date) async {
    emit(state.copyWith(isLoading: true, selectedDate: date, clearError: true));
    try {
      final NoteLoadResult result = await _repository.getNotes(date);
      emit(
        state.copyWith(
          notes: result.notes,
          isLoading: false,
          selectedDate: date,
          isOfflineData: result.isFromCache,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load notes',
          selectedDate: date,
          isOfflineData: false,
        ),
      );
    }
  }

  Future<void> addNote(
    String title,
    String description,
    String date,
    int colorValue,
  ) async {
    final note = NoteModel(
      id: '',
      title: title,
      content: description,
      createdAt: DateTime.now(),
      colorValue: colorValue,
    );
    await _repository.addNote(note, date);
    await fetchNotes(date);
  }

  Future<void> updateNote(
    String id,
    String title,
    String description,
    String date,
    int colorValue,
  ) async {
    final note = NoteModel(
      id: id,
      title: title,
      content: description,
      createdAt: DateTime.now(),
      colorValue: colorValue,
    );
    await _repository.updateNote(note, date);
    await fetchNotes(date);
  }

  Future<void> deleteNote(String id, String date) async {
    await _repository.deleteNote(id, date);
    await fetchNotes(date);
  }
}
