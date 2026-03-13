import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isInitialized = false,
  });

  final bool isAuthenticated;
  final bool isInitialized;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isInitialized,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _initialize();
    _subscription = _repository.authStateChanges.listen((isAuthenticated) {
      emit(
        AuthState(
          isAuthenticated: isAuthenticated,
          isInitialized: true,
        ),
      );
    });
  }

  final IAuthRepository _repository;
  StreamSubscription<bool>? _subscription;

  Future<void> _initialize() async {
    emit(
      AuthState(
        isAuthenticated: await _repository.isAuthenticated(),
        isInitialized: true,
      ),
    );
  }

  Future<void> logout() => _repository.logout();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
