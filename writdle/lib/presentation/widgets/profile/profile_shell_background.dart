import 'package:flutter/material.dart';

class ProfileShellBackground extends StatelessWidget {
  const ProfileShellBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -30,
          child: _GlowOrb(
            size: 220,
            color: scheme.primary.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          top: 140,
          right: -40,
          child: _GlowOrb(
            size: 190,
            color: scheme.secondary.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -70,
          left: 30,
          child: _GlowOrb(
            size: 180,
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
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
