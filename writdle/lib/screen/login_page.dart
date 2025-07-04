// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:writdle/models/login_logic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final logic = LoginLogic();

  @override
  void initState() {
    super.initState();
    logic.context = context;
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  OutlineInputBorder buildBorder(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: BorderRadius.circular(12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Login"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset('assets/image/WR-Logo-1.jpg', height: 100),
                ),
                const SizedBox(height: 30),

                // ✅ Email Field
                TextField(
                  controller: logic.emailController,
                  onChanged: logic.onEmailChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: logic.isEmailValid == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    enabledBorder: buildBorder(Colors.deepPurple),
                    focusedBorder: buildBorder(Colors.deepPurpleAccent),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Password Field
                TextField(
                  controller: logic.passwordController,
                  obscureText: !logic.showPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: buildBorder(Colors.deepPurple),
                    focusedBorder: buildBorder(Colors.deepPurpleAccent),
                    suffixIcon: IconButton(
                      icon: Icon(
                        logic.showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          logic.togglePasswordVisibility();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ Login Button
                ElevatedButton(
                  onPressed: logic.isLoading ? null : () => logic.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: logic.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // ✅ Navigation to Register
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                // ✅ Error Message
                if (logic.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    logic.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
