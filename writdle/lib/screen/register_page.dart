// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:writdle/models/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final controller = RegisterController();

  @override
  void dispose() {
    controller.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder buildBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Register"),
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
                _buildTextField(controller.nameController, 'Full Name'),
                const SizedBox(height: 16),
                _buildTextField(controller.emailController, 'Email'),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller.passwordController,
                  'Password',
                  controller.showPassword,
                  () => setState(() => controller.togglePasswordVisibility()),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller.confirmPasswordController,
                  'Confirm Password',
                  controller.showConfirmPassword,
                  () => setState(
                    () => controller.toggleConfirmPasswordVisibility(),
                  ),
                  isMatch: controller.isPasswordMatched,
                  onChanged: (value) {
                    setState(() {
                      controller.checkPasswordMatch();
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          await controller.registerUser(context);
                          setState(() {});
                        },
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
                  child: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage!,
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isVisible,
    VoidCallback toggleVisibility, {
    bool isMatch = true,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isMatch ? Colors.white70 : Colors.red),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isMatch ? Colors.deepPurple : Colors.red,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isMatch ? Colors.deepPurpleAccent : Colors.red,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: isMatch ? Colors.white70 : Colors.red,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
