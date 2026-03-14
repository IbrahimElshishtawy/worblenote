import 'package:flutter/material.dart';

class AppNavigation {
  static const BorderRadius _sheetRadius = BorderRadius.vertical(
    top: Radius.circular(30),
  );

  static Route<T> page<T>(
    Widget child, {
    RouteSettings? settings,
    bool useScale = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        if (useScale) {
          final scale = Tween<double>(begin: 0.96, end: 1).animate(fade);
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: pageChild,
            ),
          );
        }

        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: pageChild,
          ),
        );
      },
    );
  }

  static Future<T?> showSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    bool showDragHandle = false,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    final theme = Theme.of(context);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      showDragHandle: showDragHandle,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: _sheetRadius,
          ),
      builder: builder,
    );
  }
}
