import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                scheme.surfaceContainerHighest.withValues(alpha: 0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: -30,
          child: _GlowOrb(
            size: 220,
            color: scheme.primary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          top: 110,
          right: -50,
          child: _GlowOrb(
            size: 180,
            color: const Color(0x26C84B5A),
          ),
        ),
        Positioned(
          bottom: -60,
          left: 40,
          child: _GlowOrb(
            size: 160,
            color: scheme.tertiary.withValues(alpha: 0.10),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 70,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
