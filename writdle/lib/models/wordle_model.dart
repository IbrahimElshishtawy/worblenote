import 'package:cloud_firestore/cloud_firestore.dart';

class WordleModel {
  final String id;
  final List<String> guesses;
  final String targetWord;
  final DateTime playedAt;

  WordleModel({
    required this.id,
    required this.guesses,
    required this.targetWord,
    required this.playedAt,
  });

  factory WordleModel.fromMap(Map<String, dynamic> data, String id) {
    return WordleModel(
      id: id,
      guesses: List<String>.from(data['guesses'] ?? []),
      targetWord: data['targetWord'] ?? '',
      playedAt: (data['playedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'guesses': guesses, 'targetWord': targetWord, 'playedAt': playedAt};
  }
}
