enum AppNotificationType { success, error, info }

class AppNotification {
  const AppNotification({
    required this.message,
    required this.type,
    this.localTitle,
    this.showLocalNotification = false,
  });

  final String message;
  final AppNotificationType type;
  final String? localTitle;
  final bool showLocalNotification;
}
