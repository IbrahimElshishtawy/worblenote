import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';

class AppNotificationCubit extends Cubit<AppNotification?> {
  AppNotificationCubit() : super(null);

  void show(
    String message, {
    AppNotificationType type = AppNotificationType.info,
    String? localTitle,
    bool showLocalNotification = false,
  }) {
    emit(
      AppNotification(
        message: message,
        type: type,
        localTitle: localTitle,
        showLocalNotification: showLocalNotification,
      ),
    );
  }

  void clear() => emit(null);
}
