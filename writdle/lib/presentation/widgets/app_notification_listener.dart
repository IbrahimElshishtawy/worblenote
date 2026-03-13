import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/core/notifications/local_notification_service.dart';

class AppNotificationListener extends StatelessWidget {
  const AppNotificationListener({
    super.key,
    required this.child,
    required this.scaffoldMessengerKey,
  });

  final Widget child;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppNotificationCubit, AppNotification?>(
      listenWhen: (previous, current) => current != null,
      listener: (context, notification) async {
        if (notification == null) {
          return;
        }

        final backgroundColor = switch (notification.type) {
          AppNotificationType.success => Colors.green,
          AppNotificationType.error => Colors.red,
          AppNotificationType.info => Colors.blueGrey,
        };

        final messenger = scaffoldMessengerKey.currentState;
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(notification.message),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

        if (notification.showLocalNotification) {
          await LocalNotificationService.instance.show(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: notification.localTitle ?? 'Writdle',
            body: notification.message,
          );
        }

        context.read<AppNotificationCubit>().clear();
      },
      child: child,
    );
  }
}
