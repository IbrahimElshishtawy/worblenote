import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStats {
  static int totalGames = 0;
  static int winsFirstTry = 0;
  static int winsSecondTry = 0;
  static int winsThirdTry = 0;
  static int winsFourthTry = 0;
  static int losses = 0;

  static int completedTasks = 0;
  static List<String> completedTaskTitles = [];

  // 🧩 جلب البيانات من Firestore
  static Future<void> loadFromFirestore() async {
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
      completedTaskTitles = List<String>.from(
        data['completedTaskTitles'] ?? [],
      );
      print("📦 UserStats loaded from Firestore");
    } else {
      print("📭 No user stats found in Firestore");
    }
  }

  // 💾 حفظ البيانات في Firestore
  static Future<void> saveToFirestore() async {
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

    print("✅ UserStats saved to Firestore");
  }

  static void updateStats({
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

    saveToFirestore(); // ✅ احفظ مباشرة
  }

  static void reset() {
    totalGames = 0;
    winsFirstTry = 0;
    winsSecondTry = 0;
    winsThirdTry = 0;
    winsFourthTry = 0;
    losses = 0;
    completedTasks = 0;
    completedTaskTitles = [];
    saveToFirestore(); // ✅ reset يحفظ كمان
  }

  static int get totalWins =>
      winsFirstTry + winsSecondTry + winsThirdTry + winsFourthTry;

  static double get winRate => totalGames == 0 ? 0 : totalWins / totalGames;
}
