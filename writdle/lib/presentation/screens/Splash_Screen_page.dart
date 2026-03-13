import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/auth/developer_session.dart';
import 'package:writdle/presentation/bloc/app_settings_cubit.dart';
import 'package:writdle/presentation/widgets/splash/splash_background.dart';
import 'package:writdle/presentation/widgets/splash/splash_hero.dart';
import 'package:writdle/presentation/widgets/splash/splash_loading_panel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _heroAnimation;
  late final Animation<double> _loadingAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    final reduceMotion = context.read<AppSettingsCubit>().state.reduceMotion;

    _animationController = AnimationController(
      duration: reduceMotion
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 1700),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    _loadingAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationTimer = Timer(
        reduceMotion
            ? const Duration(milliseconds: 900)
            : const Duration(milliseconds: 2200),
        _navigateNext,
      );
    });
  }

  Future<void> _navigateNext() async {
    if (!mounted) {
      return;
    }
    final isLoggedIn = FirebaseAuth.instance.currentUser != null ||
        await DeveloperSession.isEnabled();
    Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = context.select<AppSettingsCubit, bool>(
      (cubit) => cubit.state.reduceMotion,
    );

    return Scaffold(
      body: SplashBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SplashHero(
                          progress: _heroAnimation.value,
                          reduceMotion: reduceMotion,
                        ),
                        const SizedBox(height: 34),
                        Opacity(
                          opacity: reduceMotion ? 1 : _loadingAnimation.value,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              reduceMotion
                                  ? 0
                                  : 18 * (1 - _loadingAnimation.value),
                            ),
                            child: SplashLoadingPanel(
                              progress: reduceMotion
                                  ? 1
                                  : _loadingAnimation.value.clamp(0.1, 1.0),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
