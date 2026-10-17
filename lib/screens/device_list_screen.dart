import 'dart:async';

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/device_models.dart';
import 'add_device_screen.dart';
import 'device_detail_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<Device> _devices = [];
  bool _isLoading = true;
  OverlayEntry? _successOverlay;
  Timer? _successOverlayTimer;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getDevices();
      if (mounted) {
        setState(() {
          _devices = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading devices: $e');
      if (mounted) {
        setState(() {
          _devices = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToAddDevice() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
    );

    if (result == true && mounted) {
      _showSuccessNotification();
      _loadDevices();
    }
  }

  void _showSuccessNotification() {
    _successOverlayTimer?.cancel();
    _successOverlay?.remove();

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 16,
        left: 24,
        right: 24,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Perangkat berhasil ditambahkan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _successOverlay = entry;
    overlay.insert(entry);
    _successOverlayTimer = Timer(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_successOverlay == entry) {
        _successOverlay = null;
      }
    });
  }

  @override
  void dispose() {
    _successOverlayTimer?.cancel();
    _successOverlay?.remove();
    super.dispose();
  }

  Future<void> _navigateToDetail(Device device) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailScreen(device: device),
      ),
    );

    if (result == true && mounted) {
      _loadDevices();
    }
  }
  Future<void> _confirmDelete(Device device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perangkat'),
        content: Text('Apakah Anda yakin ingin menghapus "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && device.id != null) {
      await DatabaseHelper.instance.deleteDevice(device.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} berhasil dihapus'),
            backgroundColor: AppColors.textDark,
          ),
        );
        _loadDevices();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Daftar Perangkat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddDevice,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Perangkat'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (_devices.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return _buildDeviceCard(device);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.devices_other,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Perangkat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan peralatan listrik kos Anda untuk mulai memantau dan menghemat konsumsi energi harian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(device),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.electric_bolt,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.quantity} unit • ${device.powerWatt.toStringAsFixed(0)} Watt • ${device.dailyHours.toStringAsFixed(1)} jam/hari',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimasi: ${device.dailyKwh.toStringAsFixed(2)} kWh/hari',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                onPressed: () => _confirmDelete(device),
                tooltip: 'Hapus Perangkat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
