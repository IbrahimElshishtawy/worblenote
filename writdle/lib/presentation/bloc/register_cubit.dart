import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';

class RegisterState {
  const RegisterState({
    this.isLoading = false,
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isSuccess;
  final String? errorMessage;

  RegisterState copyWith({
    bool? isLoading,
    bool? showPassword,
    bool? showConfirmPassword,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState());

  final IAuthRepository _repository;

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please fill in all fields',
          isSuccess: false,
        ),
      );
      return;
    }

    if (password.trim() != confirmPassword.trim()) {
      emit(
        state.copyWith(
          errorMessage: 'Passwords do not match',
          isSuccess: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, isSuccess: false, clearError: true));
    try {
      await _repository.register(name.trim(), email.trim(), password.trim());
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void clearStatus() {
    emit(state.copyWith(isSuccess: false, clearError: true));
  }
}
