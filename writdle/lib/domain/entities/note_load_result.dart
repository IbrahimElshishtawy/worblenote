import 'package:writdle/domain/entities/note_model.dart';

class NoteLoadResult {
  const NoteLoadResult({
    required this.notes,
    this.isFromCache = false,
  });

  final List<NoteModel> notes;
  final bool isFromCache;
}
