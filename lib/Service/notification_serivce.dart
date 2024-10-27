import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest_all.dart" as tz;
import "package:timezone/timezone.dart";

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notification.initialize(initializationSettings);
  }

  static Future<void> scheduledNotification(
      String title, String body, DateTime selectedDateTime) async {
    TZDateTime selectedTZDateTime =
        tz.TZDateTime.from(selectedDateTime, tz.local);

    if (selectedTZDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    var androidDetails = const AndroidNotificationDetails(
      'important_notification',
      'My Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);
    await _notification.zonedSchedule(
      0,
      title,
      body,
      selectedTZDateTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
