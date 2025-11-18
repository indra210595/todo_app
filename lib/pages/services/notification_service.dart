import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  // Fungsi untuk menyalakan service
  Future<void> initialize() async {
    // Setting Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Icon app

    // Setting iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Gabungkan setting
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    // Inisialisasi plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fungsi buat JADWALKAN notifikasi
  Future<void> scheduleNotification({
    required int id, // ID unik buat tiap notif
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Detail notifikasi untuk Android
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_channel', // ID Channel (harus unik)
      'Task Notifications', // Nama Channel
      channelDescription: 'Notifications for tasks with due dates',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    // Detail notifikasi untuk iOS
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    // Gabungkan detail
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // JADWALKAN NOTIFIKASINYA!
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      // Konversi waktu lokal ke zona waktu yang udah di-inisialisasi
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      // Biar notifikasi tetap muncul meski HP mode low power
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Pastikan notifikasi tepat waktu
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Cuma jalan di waktu yang spesifik (jam, menit, detik)
      //matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Fungsi buat BATALKAN notifikasi
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}