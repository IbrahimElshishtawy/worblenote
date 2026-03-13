import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.showPassword = false,
    this.isSuccess = false,
    this.rememberMe = true,
    this.isReady = false,
    this.errorMessage,
    this.savedEmail = '',
  });

  final bool isLoading;
  final bool showPassword;
  final bool isSuccess;
  final bool rememberMe;
  final bool isReady;
  final String? errorMessage;
  final String savedEmail;

  LoginState copyWith({
    bool? isLoading,
    bool? showPassword,
    bool? isSuccess,
    bool? rememberMe,
    bool? isReady,
    String? errorMessage,
    String? savedEmail,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      showPassword: showPassword ?? this.showPassword,
      isSuccess: isSuccess ?? this.isSuccess,
      rememberMe: rememberMe ?? this.rememberMe,
      isReady: isReady ?? this.isReady,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savedEmail: savedEmail ?? this.savedEmail,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState()) {
    initialize();
  }

  final IAuthRepository _repository;
  static const _rememberMeKey = 'remember_me';
  static const _savedEmailKey = 'saved_login_email';
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    emit(
      state.copyWith(
        rememberMe: preferences.getBool(_rememberMeKey) ?? true,
        savedEmail: preferences.getString(_savedEmailKey) ?? '',
        isReady: true,
      ),
    );
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) {
      return;
    }

    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();
    final validationError = _validate(trimmedEmail, trimmedPassword);

    if (validationError != null) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: validationError,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, isSuccess: false, clearError: true));
    final result = await _repository.login(trimmedEmail, trimmedPassword);

    if (result == null) {
      await _persistLoginPreferences(trimmedEmail);
    }

    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: result == null,
        errorMessage: result,
      ),
    );
  }

  Future<void> _persistLoginPreferences(String email) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberMeKey, state.rememberMe);
    if (state.rememberMe) {
      await preferences.setString(_savedEmailKey, email);
    } else {
      await preferences.remove(_savedEmailKey);
    }
  }

  String? _validate(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Please enter your email and password.';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  void clearStatus() {
    emit(state.copyWith(isSuccess: false, clearError: true));
  }
}
