import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/device_models.dart';

class DeviceDetailScreen extends StatelessWidget {
  final Device device;

  const DeviceDetailScreen({
    super.key,
    required this.device,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perangkat'),
        content: Text('Hapus "${device.name}" dari daftar pemantauan?'),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} berhasil dihapus'),
            backgroundColor: AppColors.textDark,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double electricityRate = 1445.0;
    final dailyCost = device.dailyKwh * electricityRate;
    final monthlyCost = dailyCost * 30;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Detail Perangkat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Perangkat',
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.electric_bolt,
                      color: AppColors.primaryGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    device.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${device.quantity} Unit Terpasang',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Spesifikasi Perangkat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildRow('Daya Satuan', '${device.powerWatt.toStringAsFixed(0)} Watt'),
              const Divider(height: 16, color: AppColors.cardBorder),
              _buildRow('Jumlah Unit', '${device.quantity} unit'),
              const Divider(height: 16, color: AppColors.cardBorder),
              _buildRow('Total Daya Terpasang', '${device.totalWatt.toStringAsFixed(0)} Watt', isBold: true),
              const Divider(height: 16, color: AppColors.cardBorder),
              _buildRow('Lama Pemakaian / Hari', '${device.dailyHours.toStringAsFixed(1)} Jam'),
            ]),
            const SizedBox(height: 20),

            const Text(
              'Konsumsi Energi & Estimasi Biaya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailCard([
              _buildRow(
                'Konsumsi Harian',
                '${device.dailyKwh.toStringAsFixed(2)} kWh',
                valueColor: AppColors.primaryGreen,
                isBold: true,
              ),
              const Divider(height: 16, color: AppColors.cardBorder),
              _buildRow(
                'Estimasi Biaya Harian',
                'Rp ${dailyCost.toStringAsFixed(0)}',
              ),
              const Divider(height: 16, color: AppColors.cardBorder),
              _buildRow(
                'Estimasi Biaya Bulanan (30 hari)',
                'Rp ${monthlyCost.toStringAsFixed(0)}',
                valueColor: AppColors.primaryGreen,
                isBold: true,
              ),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Kembali ke Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color valueColor = AppColors.textDark,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
