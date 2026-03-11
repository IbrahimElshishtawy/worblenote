import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:writdle/domain/repositories/auth_repository.dart';
import 'package:writdle/presentation/providers/login_controller.dart';
import 'package:writdle/data/datasources/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    final authRepository = context.read<IAuthRepository>();
    _controller = LoginController(authRepository);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Consumer<LoginController>(
              builder: (context, controller, child) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.asset('assets/image/WR-Logo-1.jpg', height: 100),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "Welcome Back",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Login to continue your journey",
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 48),
                      TextField(
                        controller: controller.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: controller.passwordController,
                        obscureText: !controller.showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: controller.isLoading
                            ? null
                            : () async {
                                final success = await controller.login(context);
                                if (success) {
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/home');
                                    NotificationService.showSnackBar(context, "Logged in successfully!");
                                  }
                                } else if (controller.errorMessage != null) {
                                  if (mounted) {
                                    NotificationService.showSnackBar(
                                      context,
                                      controller.errorMessage!,
                                      isError: true,
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: controller.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                              )
                            : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: const Text("Register"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
