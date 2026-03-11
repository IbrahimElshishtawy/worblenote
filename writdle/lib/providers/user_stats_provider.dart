import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserStatsProvider with ChangeNotifier {
  int totalGames = 0;
  int winsFirstTry = 0;
  int winsSecondTry = 0;
  int winsThirdTry = 0;
  int winsFourthTry = 0;
  int losses = 0;
  int completedTasks = 0;
  List<String> completedTaskTitles = [];

  UserStatsProvider() {
    loadFromFirestore();
  }

  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user_stats')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      totalGames = data['totalGames'] ?? 0;
      winsFirstTry = data['winsFirstTry'] ?? 0;
      winsSecondTry = data['winsSecondTry'] ?? 0;
      winsThirdTry = data['winsThirdTry'] ?? 0;
      winsFourthTry = data['winsFourthTry'] ?? 0;
      losses = data['losses'] ?? 0;
      completedTasks = data['completedTasks'] ?? 0;
      completedTaskTitles = List<String>.from(data['completedTaskTitles'] ?? []);
      notifyListeners();
    }
  }

  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('user_stats')
        .doc(user.uid)
        .set({
      'totalGames': totalGames,
      'winsFirstTry': winsFirstTry,
      'winsSecondTry': winsSecondTry,
      'winsThirdTry': winsThirdTry,
      'winsFourthTry': winsFourthTry,
      'losses': losses,
      'completedTasks': completedTasks,
      'completedTaskTitles': completedTaskTitles,
    }, SetOptions(merge: true));
  }

  void updateStats({
    required int total,
    required int first,
    required int second,
    required int third,
    required int fourth,
    required int loss,
    required int completed,
    required List<String> titles,
  }) {
    totalGames = total;
    winsFirstTry = first;
    winsSecondTry = second;
    winsThirdTry = third;
    winsFourthTry = fourth;
    losses = loss;
    completedTasks = completed;
    completedTaskTitles = titles;
    notifyListeners();
    saveToFirestore();
  }

  void reset() {
    totalGames = 0;
    winsFirstTry = 0;
    winsSecondTry = 0;
    winsThirdTry = 0;
    winsFourthTry = 0;
    losses = 0;
    completedTasks = 0;
    completedTaskTitles = [];
    notifyListeners();
    saveToFirestore();
  }

  int get totalWins => winsFirstTry + winsSecondTry + winsThirdTry + winsFourthTry;
  double get winRate => totalGames == 0 ? 0 : totalWins / totalGames;
}
