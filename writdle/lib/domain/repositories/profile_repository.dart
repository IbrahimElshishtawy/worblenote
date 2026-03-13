import 'package:writdle/domain/entities/profile_data.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';

abstract class IProfileRepository {
  Future<ProfileData?> getProfile();
  Future<void> updateProfile(ProfileData profile);
  Future<UserStatsSummary> getStats();
  Future<void> saveStats(UserStatsSummary stats);
  Future<void> clearStats();
}
