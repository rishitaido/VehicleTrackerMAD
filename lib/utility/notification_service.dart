import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    print("Initializing NotificationService...");
    tz.initializeTimeZones();
    
    // Get local timezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    print("Local timezone: $timeZoneName");
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    final fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) async {
        print("Notification tapped: ${response.payload}");
      },
    );
    
    // Create channel
    const fln.AndroidNotificationChannel channel = fln.AndroidNotificationChannel(
      'maintenance_channel', // id
      'Maintenance Reminders', // title
      description: 'Reminders for vehicle maintenance', // description
      importance: fln.Importance.max,
    );
            
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print("NotificationService initialized.");
  }

  Future<void> requestPermissions() async {
    print("Requesting notification permissions...");
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
     await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    final bool? androidResult = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    print("Permission request result: iOS/Mac: $result, Android: $androidResult");
  }

  Future<void> scheduleReminder(
      int id, String title, String body, DateTime scheduledDate) async {
    
    print("Attempting to schedule notification [$id] '$title' at $scheduledDate");
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'maintenance_channel',
            'Maintenance Reminders',
            channelDescription: 'Reminders for vehicle maintenance',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
          ),
          iOS: fln.DarwinNotificationDetails(),
        ),
        androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print("Notification successfully scheduled for $scheduledDate");
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
