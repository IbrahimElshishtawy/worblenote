import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/presentation/bloc/auth_cubit.dart';
import 'package:writdle/presentation/bloc/login_cubit.dart';
import 'package:writdle/presentation/bloc/theme_cubit.dart';
import 'package:writdle/presentation/widgets/auth/auth_brand_panel.dart';
import 'package:writdle/presentation/widgets/auth/auth_center_logo.dart';
import 'package:writdle/presentation/widgets/auth/auth_input_field.dart';
import 'package:writdle/presentation/widgets/auth/login_form_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _developerEmail = 'shishtawy@gmail.com';
  static const _developerPassword = 'hima123';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(context.read<IAuthRepository>()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (_emailController.text.isEmpty && state.savedEmail.isNotEmpty) {
                _emailController.text = state.savedEmail;
              }
              if (state.isSuccess) {
                context.read<AppNotificationCubit>().show(
                  'Logged in successfully!',
                  type: AppNotificationType.success,
                );
                context.read<LoginCubit>().clearStatus();
                Navigator.pushReplacementNamed(context, '/home');
              } else if (state.errorMessage != null) {
                context.read<AppNotificationCubit>().show(
                  state.errorMessage!,
                  type: AppNotificationType.error,
                );
                context.read<LoginCubit>().clearStatus();
              }
            },
          ),
          BlocListener<AuthCubit, AuthState>(
            listenWhen: (previous, current) => current.isAuthenticated,
            listener: (context, state) {
              if (ModalRoute.of(context)?.settings.name == '/login') {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
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
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;
                      final form = _LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onUseDeveloperAccount: () {
                          _emailController.text = _developerEmail;
                          _passwordController.text = _developerPassword;
                          setState(() {});
                        },
                        onSubmit: () => _submit(context),
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: AuthBrandPanel(
                                title: 'Welcome back',
                                subtitle:
                                    'Step into your dashboard, track your momentum, and continue where you left off.',
                              ),
                            ),
                            const SizedBox(width: 28),
                            const Expanded(
                              child: AuthCenterLogo(
                                caption: 'Writdle Hub',
                                description:
                                    'A centered identity block that keeps the login screen feeling polished and premium.',
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(child: form),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const AuthCenterLogo(),
                          const SizedBox(height: 24),
                          const AuthBrandPanel(
                            centered: true,
                            title: 'Welcome back',
                            subtitle:
                                'Sign in to continue your notes, tasks, games, and progress with a smoother and safer login flow.',
                          ),
                          const SizedBox(height: 28),
                          form,
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
    context.read<LoginCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onUseDeveloperAccount,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onUseDeveloperAccount;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return LoginFormCard(
          title: 'Sign in to your account',
          subtitle:
              'Clean login flow with validation, saved session, and theme support.',
          child: Column(
            children: [
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
                onSubmitted: (_) => onSubmit(),
                suffix: IconButton(
                  onPressed: () =>
                      context.read<LoginCubit>().togglePasswordVisibility(),
                  icon: Icon(
                    state.showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: state.rememberMe,
                    onChanged: (value) {
                      context.read<LoginCubit>().toggleRememberMe(value ?? true);
                    },
                  ),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.read<AppNotificationCubit>().show(
                        'Forgot password flow can be added next.',
                        type: AppNotificationType.info,
                      );
                    },
                    child: const Text('Need help?'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: state.isLoading ? null : onSubmit,
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.isLoading ? null : onUseDeveloperAccount,
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Use Developer Account'),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        );
      },
    );
  }
}
