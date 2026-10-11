import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../firebase_options.dart';
import '../models/task_model.dart';
import '../screens/task_list_screen.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Background Firebase init: $e');
  }

  debugPrint('Handling FCM background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title ?? message.data['title']}');
  debugPrint('Body: ${message.notification?.body ?? message.data['body']}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Global navigator key to navigate from notification click
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // High importance channel for task notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'task_channel',
    'Task Notifications',
    description: 'Notifications for Task Creation, Completion, and Push Alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize FCM, Timezone, and Flutter Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database and set device local timezone
      tz.initializeTimeZones();
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
        debugPrint('🌍 Local timezone configured: ${timeZoneInfo.identifier}');
      } catch (tzError) {
        debugPrint('⚠️ Could not configure local timezone: $tzError');
      }

      // 2. Request notification permissions (Android 13+ & iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Authorization Status: ${settings.authorizationStatus}');

      // 3. Fetch & store device FCM token
      await _fetchFCMToken();

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token Refreshed: $newToken');
      });

      // 4. Initialize Flutter Local Notifications
      const androidInitSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // 5. Create Android channel & request permissions (Notifications & Exact Alarms)
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_channel);
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();

      // 6. Register background FCM message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 7. Handle FOREGROUND notifications (Teacher's Core Requirement)
      // When app is in foreground, FCM does not automatically show a notification.
      // We intercept the message and show a Local Notification banner.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.messageId}');

        final title =
            message.notification?.title ??
            message.data['title'] ??
            'Task Notification';
        final body =
            message.notification?.body ??
            message.data['body'] ??
            message.data['message'] ??
            'You have a new update.';
        final payload = message.data['taskId'] ?? message.data['id'];

        showLocalNotification(title: title, body: body, payload: payload);
      });

      // 8. Handle Background Notification Click
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification clicked in background: ${message.messageId}');
        _handlePayloadNavigation(message.data['taskId'] ?? message.data['id']);
      });

      // 9. Handle Terminated App Notification Click (FCM)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          'App launched from terminated via FCM: ${initialMessage.messageId}',
        );
        _handlePayloadNavigation(
          initialMessage.data['taskId'] ?? initialMessage.data['id'],
        );
      }

      // 10. Handle Terminated App Notification Click (Local Scheduled Notification)
      final launchDetails = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null) {
          Future.delayed(const Duration(milliseconds: 600), () {
            _handlePayloadNavigation(payload);
          });
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  /// Retrieve the FCM Device Token
  Future<String?> _fetchFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('====================================');
      debugPrint('🔥 FCM DEVICE TOKEN:');
      debugPrint(_fcmToken ?? 'Token null');
      debugPrint('====================================');
      return _fcmToken;
    } catch (e) {
      debugPrint('Could not fetch FCM token: $e');
      return null;
    }
  }

  /// Public method to force refresh or re-fetch FCM token
  Future<String?> getDeviceToken() async {
    if (_fcmToken != null) return _fcmToken;
    return await _fetchFCMToken();
  }

  /// Show a Local Notification banner
  Future<void> showLocalNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id == 0 ? DateTime.now().millisecondsSinceEpoch.remainder(100000) : id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule a Priority-Based Reminder before the Task Due Date & Time
  /// High Priority: 1 hour (60 min) before
  /// Medium Priority: 30 minutes before
  /// Low Priority: 15 minutes before
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (task.isCompleted) return;

    Duration offset;
    String timeLabel;

    switch (task.priority) {
      case TaskPriority.high:
        offset = const Duration(hours: 1);
        timeLabel = '1 Hour';
        break;
      case TaskPriority.medium:
        offset = const Duration(minutes: 30);
        timeLabel = '30 Minutes';
        break;
      case TaskPriority.low:
        offset = const Duration(minutes: 15);
        timeLabel = '15 Minutes';
        break;
    }

    DateTime scheduledTime = task.dueDate.subtract(offset);
    final now = DateTime.now();

    // If the priority-offset time is in the past (e.g. task is due in 2 minutes,
    // or when testing), trigger 5 seconds from now so the user can test immediately!
    if (scheduledTime.isBefore(now)) {
      if (task.dueDate.isAfter(now)) {
        scheduledTime = now.add(const Duration(seconds: 5));
      } else {
        // Task due date itself is completely in the past
        debugPrint(
          '⚠️ Task due date is in the past, skipping reminder schedule',
        );
        return;
      }
    }

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);
    final int notificationId = task.id.hashCode.abs() % 100000;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notifTitle = task.title;
    final notifBody = task.description.trim().isNotEmpty
        ? '${task.description.trim()} • Due in $timeLabel'
        : 'Due in $timeLabel • Tap to review details';

    try {
      await _localNotifications.zonedSchedule(
        notificationId,
        notifTitle,
        notifBody,
        tzScheduled,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );
      debugPrint(
        '⏰ Successfully scheduled reminder for "${task.title}" at $tzScheduled (ID: $notificationId)',
      );
    } catch (e) {
      debugPrint(
        '⚠️ exactAllowWhileIdle error: $e, trying inexact fallback...',
      );
      try {
        await _localNotifications.zonedSchedule(
          notificationId,
          notifTitle,
          notifBody,
          tzScheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id,
        );
        debugPrint(
          '⏰ Successfully scheduled reminder with inexact mode for "${task.title}"',
        );
      } catch (fallbackError) {
        debugPrint('❌ Failed to schedule reminder: $fallbackError');
      }
    }
  }

  /// Cancel a scheduled reminder for a specific task
  Future<void> cancelScheduledReminder(String taskId) async {
    final int notificationId = taskId.hashCode.abs() % 100000;
    await _localNotifications.cancel(notificationId);
    debugPrint(
      '🗑️ Cancelled scheduled reminder for task $taskId (ID: $notificationId)',
    );
  }

  /// Trigger notification on Task Creation
  Future<void> notifyTaskCreated(String taskTitle) async {
    await showLocalNotification(
      title: '📌 New Task Created',
      body: 'Task "$taskTitle" was created successfully!',
    );
  }

  /// Trigger notification on Task Completion
  Future<void> notifyTaskCompleted(String taskTitle) async {
    await showLocalNotification(
      title: '🎉 Task Completed',
      body: 'Great job! You completed "$taskTitle".',
    );
  }

  /// Trigger notification for High Priority reminder
  Future<void> notifyHighPriorityTask(String taskTitle) async {
    await showLocalNotification(
      title: taskTitle,
      body: 'High priority task • Tap to view details',
    );
  }

  /// Schedule a quick test notification in [seconds] to easily test background & terminated states
  Future<void> scheduleTestNotification({
    int seconds = 5,
    String? taskId,
  }) async {
    final scheduledTime = tz.TZDateTime.now(tz.local)
        .add(Duration(seconds: seconds));

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _localNotifications.zonedSchedule(
        99999,
        'Project Milestone Review',
        'Due in 1 hour • Tap to review details',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );
      debugPrint('⏰ Scheduled 5s test notification at $scheduledTime');
    } catch (e) {
      await _localNotifications.zonedSchedule(
        99999,
        'Project Milestone Review',
        'Due in 1 hour • Tap to review details',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: taskId,
      );
    }
  }

  /// Callback when user taps a Local Notification
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped with payload: ${response.payload}');
    _handlePayloadNavigation(response.payload);
  }

  /// Navigate when notification is clicked: Open TaskListScreen & highlight the task!
  void _handlePayloadNavigation(String? taskId) {
    debugPrint('Navigating for taskId: $taskId');

    final navState = navigatorKey.currentState;
    if (navState == null) return;

    // Navigate to TaskListScreen, highlight the specific task card with black border
    navState.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => TaskListScreen(highlightedTaskId: taskId),
      ),
      (route) => false,
    );
  }
}
