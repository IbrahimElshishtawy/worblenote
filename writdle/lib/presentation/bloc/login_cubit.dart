import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.showPassword = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool showPassword;
  final bool isSuccess;
  final String? errorMessage;

  LoginState copyWith({
    bool? isLoading,
    bool? showPassword,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      showPassword: showPassword ?? this.showPassword,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final IAuthRepository _repository;

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: 'Please fill in all fields',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        clearError: true,
      ),
    );

    final result = await _repository.login(trimmedEmail, trimmedPassword);
    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: result == null,
        errorMessage: result,
      ),
    );
  }

  void clearStatus() {
    emit(state.copyWith(isSuccess: false, clearError: true));
  }
}
