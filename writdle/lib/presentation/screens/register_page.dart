import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/presentation/bloc/register_cubit.dart';
import 'package:writdle/presentation/bloc/theme_cubit.dart';
import 'package:writdle/presentation/widgets/auth/auth_brand_panel.dart';
import 'package:writdle/presentation/widgets/auth/auth_input_field.dart';
import 'package:writdle/presentation/widgets/auth/register_form_card.dart';
import 'package:writdle/presentation/widgets/auth/register_highlights.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(context.read<IAuthRepository>()),
      child: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.read<AppNotificationCubit>().show(
              'Account created successfully!',
              type: AppNotificationType.success,
            );
            context.read<RegisterCubit>().clearStatus();
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state.errorMessage != null) {
            context.read<AppNotificationCubit>().show(
              state.errorMessage!,
              type: AppNotificationType.error,
            );
            context.read<RegisterCubit>().clearStatus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: 'Toggle theme',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: const Icon(Icons.brightness_6_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 920;
                      final registerForm = _RegisterForm(
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        onSubmit: () => _submit(context),
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(child: AuthBrandPanel()),
                            const SizedBox(width: 24),
                            const Expanded(child: RegisterHighlights()),
                            const SizedBox(width: 24),
                            Expanded(child: registerForm),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthBrandPanel(),
                          const SizedBox(height: 24),
                          const RegisterHighlights(),
                          const SizedBox(height: 24),
                          registerForm,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<RegisterCubit>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return RegisterFormCard(
          title: 'Create your account',
          subtitle: 'Join your writing, planning, and daily challenge flow in one smart space.',
          child: Column(
            children: [
              AuthInputField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: !state.showPassword,
                suffix: IconButton(
                  onPressed: () => context.read<RegisterCubit>().togglePasswordVisibility(),
                  icon: Icon(
                    state.showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuthInputField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_reset,
                obscureText: !state.showConfirmPassword,
                onSubmitted: (_) => onSubmit(),
                suffix: IconButton(
                  onPressed: () => context.read<RegisterCubit>().toggleConfirmPasswordVisibility(),
                  icon: Icon(
                    state.showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: state.isLoading ? null : onSubmit,
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        );
      },
    );
  }
}
