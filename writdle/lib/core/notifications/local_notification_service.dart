import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();
  static const int gameReminderNotificationId = 7001;
  static const String _generalChannelId = 'writdle_general';
  static const String _taskChannelId = 'writdle_tasks';
  static const String _gameChannelId = 'writdle_game';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(settings);

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _generalChannelId,
        'Writdle Alerts',
        description: 'General in-app alerts and confirmations',
        importance: Importance.defaultImportance,
      ),
    );
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _taskChannelId,
        'Task Reminders',
        description: 'Local reminders for saved tasks',
        importance: Importance.max,
      ),
    );
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _gameChannelId,
        'Game Reminders',
        description: 'Local reminders for Wordle sessions',
        importance: Importance.high,
      ),
    );

    await androidImplementation?.requestNotificationsPermission();
    final canScheduleExact =
        await androidImplementation?.canScheduleExactNotifications() ?? false;
    if (!canScheduleExact) {
      await androidImplementation?.requestExactAlarmsPermission();
    }

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails get _generalDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _generalChannelId,
          'Writdle Alerts',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  NotificationDetails get _taskDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          'Task Reminders',
          channelDescription: 'Local reminders for saved tasks',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  NotificationDetails get _gameDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          _gameChannelId,
          'Game Reminders',
          channelDescription: 'Local reminders for Wordle sessions',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _generalDetails);
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExact =
        await androidImplementation?.canScheduleExactNotifications() ?? false;
    return canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime scheduledAt,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id,
      'Task Reminder',
      taskTitle,
      tz.TZDateTime.from(scheduledAt, tz.local),
      _taskDetails,
      androidScheduleMode: await _scheduleMode(),
      payload: 'task_reminder',
    );
  }

  Future<void> scheduleDailyGameReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledAt = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledAt.isBefore(now)) {
      scheduledAt = scheduledAt.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      gameReminderNotificationId,
      'Wordle Reminder',
      'Your next game session is waiting. Open Writdle and play now.',
      scheduledAt,
      _gameDetails,
      androidScheduleMode: await _scheduleMode(),
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'game_reminder',
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pendingRequests() async {
    return _plugin.pendingNotificationRequests();
  }
}
