import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:writdle/domain/entities/profile_data.dart';
import 'package:writdle/domain/entities/user_stats_summary.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.stats = const UserStatsSummary(),
    this.currentDateTime = '',
    this.isLoading = true,
  });

  final ProfileData? profile;
  final UserStatsSummary stats;
  final String currentDateTime;
  final bool isLoading;

  ProfileState copyWith({
    ProfileData? profile,
    UserStatsSummary? stats,
    String? currentDateTime,
    bool? isLoading,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      currentDateTime: currentDateTime ?? this.currentDateTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._profileRepository, this._authRepository)
    : super(const ProfileState());

  final IProfileRepository _profileRepository;
  final IAuthRepository _authRepository;
  Timer? _clockTimer;

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true));
    final profile = await _profileRepository.getProfile();
    final stats = await _profileRepository.getStats();
    emit(
      state.copyWith(
        profile: profile,
        stats: stats,
        currentDateTime: _formatNow(),
        isLoading: false,
      ),
    );

    _clockTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      emit(state.copyWith(currentDateTime: _formatNow()));
    });
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  String _formatNow() {
    return DateFormat('EEEE, MMM d, yyyy - h:mm:ss a').format(DateTime.now());
  }

  @override
  Future<void> close() async {
    _clockTimer?.cancel();
    return super.close();
  }
}
