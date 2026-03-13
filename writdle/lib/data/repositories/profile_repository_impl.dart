import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/core/auth/developer_session.dart';
import 'package:writdle/domain/entities/profile_data.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _localStatsKey = 'developer_profile_stats';

  @override
  Future<ProfileData?> getProfile() async {
    final developerEnabled = await DeveloperSession.isEnabled();
    if (developerEnabled && _auth.currentUser == null) {
      return const ProfileData(
        name: DeveloperSession.developerName,
        email: DeveloperSession.developerEmail,
        bio: DeveloperSession.developerBio,
      );
    }

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
    final developerEnabled = await DeveloperSession.isEnabled();
    if (developerEnabled && _auth.currentUser == null) {
      return;
    }

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
    final developerEnabled = await DeveloperSession.isEnabled();
    if (developerEnabled && _auth.currentUser == null) {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_localStatsKey);
      if (raw == null || raw.isEmpty) {
        return const UserStatsSummary();
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserStatsSummary(
        totalGames: json['totalGames'] as int? ?? 0,
        winsFirstTry: json['winsFirstTry'] as int? ?? 0,
        winsSecondTry: json['winsSecondTry'] as int? ?? 0,
        winsThirdTry: json['winsThirdTry'] as int? ?? 0,
        winsFourthTry: json['winsFourthTry'] as int? ?? 0,
        losses: json['losses'] as int? ?? 0,
        completedTasks: json['completedTasks'] as int? ?? 0,
        completedTaskTitles: List<String>.from(
          json['completedTaskTitles'] as List<dynamic>? ?? const [],
        ),
      );
    }

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
    final developerEnabled = await DeveloperSession.isEnabled();
    if (developerEnabled && _auth.currentUser == null) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _localStatsKey,
        jsonEncode({
          'totalGames': stats.totalGames,
          'winsFirstTry': stats.winsFirstTry,
          'winsSecondTry': stats.winsSecondTry,
          'winsThirdTry': stats.winsThirdTry,
          'winsFourthTry': stats.winsFourthTry,
          'losses': stats.losses,
          'completedTasks': stats.completedTasks,
          'completedTaskTitles': stats.completedTaskTitles,
        }),
      );
      return;
    }

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
