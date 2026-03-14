import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/auth/local_auth_store.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
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
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.read<AppNotificationCubit>().show(
            'Please enter your name first.',
            type: AppNotificationType.error,
          );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      await LocalAuthStore.createOnboardingProfile(
        name: name,
        bio: '',
      );
      if (!mounted) {
        return;
      }
      context.read<AppNotificationCubit>().show(
            'Profile saved on this device.',
            type: AppNotificationType.success,
          );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.read<AppNotificationCubit>().show(
            'Unable to save your profile right now.',
            type: AppNotificationType.error,
          );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  final form = _NameSetupForm(
                    nameController: _nameController,
                    isSaving: _isSaving,
                    onSubmit: _submit,
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: AuthBrandPanel(
                            title: 'Start your local workspace',
                            subtitle:
                                'Create your device profile once, then continue straight into notes, tasks, and your daily game flow.',
                          ),
                        ),
                        const SizedBox(width: 28),
                        const Expanded(
                          child: AuthCenterLogo(
                            caption: 'Writdle Profile',
                            description:
                                'A lightweight local setup that keeps your app personal without a full login flow.',
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
                      const AuthCenterLogo(
                        caption: 'Writdle Profile',
                        description:
                            'Set your name once and keep everything saved locally on this phone.',
                      ),
                      const SizedBox(height: 24),
                      const AuthBrandPanel(
                        centered: true,
                        title: 'Create your local profile',
                        subtitle:
                            'No email, no password, no online account. Just your name and your own device.',
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
    );
  }
}

class _NameSetupForm extends StatelessWidget {
  const _NameSetupForm({
    required this.nameController,
    required this.isSaving,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final bool isSaving;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return LoginFormCard(
      title: 'Enter your name',
      subtitle:
          'This profile is stored locally on your phone and will appear in your profile screen.',
      child: Column(
        children: [
          AuthInputField(
            controller: nameController,
            label: 'Your name',
            icon: Icons.person_outline_rounded,
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Saved locally on this device. If you want to change it later, edit it from the profile page only.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSaving ? null : onSubmit,
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
