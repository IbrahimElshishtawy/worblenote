import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isInitialized = false,
  });

  final User? user;
  final bool isInitialized;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isInitialized,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges.listen((user) {
      emit(AuthState(user: user, isInitialized: true));
    });
  }

  final IAuthRepository _repository;
  StreamSubscription<User?>? _subscription;

  Future<void> logout() => _repository.logout();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
