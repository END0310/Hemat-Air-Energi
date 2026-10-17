import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/database_helper.dart';
import '../models/notification_model.dart';
import 'energy_calculator_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Request notification permission for Android 13+
      await requestPermission();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
    return false;
  }

  /// Mengevaluasi data konsumsi aktual dan mengirimkan notifikasi lokal jika konsumsi melonjak
  /// Menggunakan batas threshold PRD (default 30%) dan baseline rata-rata harian
  Future<bool> checkAndNotifyConsumptionSpike({
    required double todayConsumption,
    required double baselineAverage,
    double thresholdPercent = 30.0,
  }) async {
    if (baselineAverage <= 0 || todayConsumption <= 0) {
      debugPrint('Data konsumsi atau baseline belum mencukupi untuk evaluasi notifikasi.');
      return false;
    }

    final bool shouldTrigger = EnergyCalculatorService.shouldTriggerIncreaseNotification(
      todayConsumption: todayConsumption,
      baselineAverage: baselineAverage,
      thresholdPercent: thresholdPercent,
    );

    if (!shouldTrigger) {
      debugPrint('Konsumsi hari ini masih di bawah ambang batas peringatan.');
      return false;
    }

    final double percentIncrease = EnergyCalculatorService.calculatePercentageIncrease(
      todayConsumption: todayConsumption,
      baselineAverage: baselineAverage,
    );

    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Anti-duplikasi: Periksa apakah notifikasi untuk tanggal hari ini sudah pernah dikirim
    final hasNotifiedToday = await DatabaseHelper.instance.hasNotificationForDateAndType(
      datePrefix: dateKey,
      type: 'consumption_increase',
    );

    if (hasNotifiedToday) {
      debugPrint('Peringatan konsumsi meningkat sudah dikirimkan hari ini. Pencegahan duplikasi aktif.');
      return false;
    }

    // Buat pesan notifikasi sesuai UI & UX Frame 20
    final String title = 'Konsumsi Meningkat';
    final String message =
        'Konsumsi hari ini ${percentIncrease.toStringAsFixed(0)}% lebih tinggi dari rata-rata harianmu. '
        'Periksa peralatan listrik berdaya besar.';

    // Simpan ke database lokal
    final notificationItem = AppNotificationItem(
      title: title,
      message: message,
      type: 'consumption_increase',
      dateTime: DateTime.now(),
      payload: 'today_kwh=${todayConsumption.toStringAsFixed(2)}&baseline=${baselineAverage.toStringAsFixed(2)}',
    );
    await DatabaseHelper.instance.insertNotification(notificationItem);

    // Tampilkan notifikasi Android lokal
    await showLocalNotification(
      id: 201, // ID unik untuk Modul 2
      title: title,
      body: message,
      payload: notificationItem.payload,
    );

    return true;
  }

  /// Menampilkan notifikasi lokal secara langsung di HP Android
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'hemat_energi_module_2',
        'Peringatan Konsumsi Listrik',
        channelDescription: 'Notifikasi peningkatan konsumsi listrik di atas ambang batas (Modul 2)',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
}
