import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writdle/domain/entities/profile_data.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<ProfileData?> getProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return null;
    }

    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) {
      return null;
    }

    final joinedAtRaw = data['createdAt'];
    return ProfileData(
      name: data['name'] as String? ?? 'No Name',
      email: data['email'] as String? ?? 'No Email',
      bio: data['bio'] as String? ?? '',
      joinedAt: joinedAtRaw is Timestamp ? joinedAtRaw.toDate() : null,
    );
  }

  @override
  Future<void> updateProfile(ProfileData profile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    await _firestore.collection('users').doc(userId).set({
      'name': profile.name,
      'email': profile.email,
      'bio': profile.bio,
    }, SetOptions(merge: true));
  }

  @override
  Future<UserStatsSummary> getStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const UserStatsSummary();
    }

    final doc = await _firestore.collection('user_stats').doc(userId).get();
    final data = doc.data();
    if (data == null) {
      return const UserStatsSummary();
    }

    return UserStatsSummary(
      totalGames: data['totalGames'] as int? ?? 0,
      winsFirstTry: data['winsFirstTry'] as int? ?? 0,
      winsSecondTry: data['winsSecondTry'] as int? ?? 0,
      winsThirdTry: data['winsThirdTry'] as int? ?? 0,
      winsFourthTry: data['winsFourthTry'] as int? ?? 0,
      losses: data['losses'] as int? ?? 0,
      completedTasks: data['completedTasks'] as int? ?? 0,
      completedTaskTitles: List<String>.from(
        data['completedTaskTitles'] as List<dynamic>? ?? const [],
      ),
    );
  }

  @override
  Future<void> saveStats(UserStatsSummary stats) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    await _firestore.collection('user_stats').doc(userId).set({
      'totalGames': stats.totalGames,
      'winsFirstTry': stats.winsFirstTry,
      'winsSecondTry': stats.winsSecondTry,
      'winsThirdTry': stats.winsThirdTry,
      'winsFourthTry': stats.winsFourthTry,
      'losses': stats.losses,
      'completedTasks': stats.completedTasks,
      'completedTaskTitles': stats.completedTaskTitles,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> clearStats() {
    return saveStats(const UserStatsSummary());
  }
}
