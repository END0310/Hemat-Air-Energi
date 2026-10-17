import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/notification_model.dart';
import '../services/energy_calculator_service.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final items = await DatabaseHelper.instance.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(AppNotificationItem item) async {
    if (item.id != null) {
      await DatabaseHelper.instance.markNotificationAsRead(item.id!);
      _loadNotifications();
    }
  }

  Future<void> _triggerTestNotification() async {
    // Jalankan simulasi kenaikan konsumsi 50% di atas rata-rata baseline (misal rata-rata 4.0 kWh, hari ini 6.0 kWh)
    const baseline = 4.0;
    const todayKwh = 6.0;

    final percent = EnergyCalculatorService.calculatePercentageIncrease(
      todayConsumption: todayKwh,
      baselineAverage: baseline,
    );

    final title = 'Konsumsi Meningkat (Uji Coba)';
    final message =
        'Konsumsi hari ini ${percent.toStringAsFixed(0)}% lebih tinggi dari rata-rata harianmu (Baseline: ${baseline.toStringAsFixed(1)} kWh/hari).';

    await NotificationService.instance.showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: message,
      payload: 'test_trigger=true',
    );

    // Simpan ke log database
    final item = AppNotificationItem(
      title: title,
      message: message,
      type: 'consumption_increase',
      dateTime: DateTime.now(),
      payload: 'simulation=true',
    );
    await DatabaseHelper.instance.insertNotification(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi lokal kenaikan konsumsi berhasil dipicu!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Notifikasi & Peringatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRuleCard(),
                  const SizedBox(height: 16),
                  _buildTestNotificationButton(),
                  const SizedBox(height: 20),
                  const Text(
                    'DAFTAR NOTIFIKASI LOKAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_notifications.isEmpty)
                    _buildEmptyState()
                  else
                    _buildNotificationList(),
                ],
              ),
            ),
    );
  }

  Widget _buildRuleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active, color: AppColors.primaryGreen, size: 22),
              SizedBox(width: 8),
              Text(
                'Aturan Notifikasi Modul 2 (PRD)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• Pemicu: Konsumsi harian aktual melonjak melewati rata-rata baseline × (1 + 30%).\n'
            '• Sumber: Catatan meter fisik & token riil (FR-07).\n'
            '• Pemrosesan: 100% lokal di perangkat Android tanpa server/internet.\n'
            '• Anti-spam: Mencegah notifikasi berulang untuk tanggal pencatatan yang sama.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _triggerTestNotification,
        icon: const Icon(Icons.send_to_mobile),
        label: const Text(
          'Uji Notifikasi Kenaikan Konsumsi (+50%)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        final dt = notif.dateTime;
        final timeStr =
            '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: notif.isRead ? AppColors.cardBorder : AppColors.primaryGreen,
              width: notif.isRead ? 1 : 1.5,
            ),
          ),
          color: notif.isRead ? Colors.white : AppColors.lightGreen.withValues(alpha: 0.3),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead ? Colors.grey.shade100 : AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up,
                color: notif.isRead ? AppColors.textSecondary : AppColors.primaryGreen,
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                notif.message,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
              ),
            ),
            onTap: notif.isRead ? null : () => _markRead(notif),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Belum Ada Notifikasi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          SizedBox(height: 6),
          Text(
            'Notifikasi peringatan akan otomatis muncul di sini ketika konsumsi harian meningkat di atas ambang batas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
