import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/core/auth/local_auth_store.dart';
import 'package:writdle/domain/entities/profile_data.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  @override
  Future<ProfileData?> getProfile() async {
    final account = await LocalAuthStore.getCurrentAccount();
    if (account == null) {
      return null;
    }

    return ProfileData(
      name: account.name,
      email: account.email,
      bio: account.bio,
      joinedAt: account.createdAt,
    );
  }

  @override
  Future<void> updateProfile(ProfileData profile) async {
    final account = await LocalAuthStore.getCurrentAccount();
    if (account == null) {
      return;
    }

    await LocalAuthStore.updateAccount(
      account.copyWith(
        name: profile.name,
        email: profile.email,
        bio: profile.bio,
      ),
    );
  }

  @override
  Future<UserStatsSummary> getStats() async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return const UserStatsSummary();
    }

    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_statsKey(userId));
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

  @override
  Future<void> saveStats(UserStatsSummary stats) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _statsKey(userId),
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
  }

  @override
  Future<void> clearStats() {
    return saveStats(const UserStatsSummary());
  }

  String _statsKey(String userId) => 'profile_stats_$userId';
}
