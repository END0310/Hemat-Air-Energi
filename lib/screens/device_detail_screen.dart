import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/device_models.dart';
import '../models/electricity_profile_model.dart';
import '../services/energy_calculator_service.dart';
import 'calculator_screen.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  ElectricityProfile? _profile;
  bool _isTopConsumer = false;
  int _rank = 1;
  int _totalDevices = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndRank();
  }

  Future<void> _loadProfileAndRank() async {
    final profile = await DatabaseHelper.instance.getElectricityProfile();
    final devices = await DatabaseHelper.instance.getDevices();

    if (mounted) {
      final ranked = EnergyCalculatorService.rankDevices(
        devices: devices,
        tariffPerKwh: profile.tariffPerKwh,
      );

      final index = ranked.indexWhere((r) => r.device.id == widget.device.id || r.device.name == widget.device.name);
      final rank = index != -1 ? ranked[index].rank : 1;

      setState(() {
        _profile = profile;
        _totalDevices = devices.length;
        _rank = rank;
        _isTopConsumer = rank == 1;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Perangkat'),
        content: Text('Hapus "${widget.device.name}" dari daftar pemantauan?'),
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

    if (confirm == true && widget.device.id != null) {
      await DatabaseHelper.instance.deleteDevice(widget.device.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.device.name} berhasil dihapus'),
            backgroundColor: AppColors.textDark,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _openInCalculator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorScreen(initialDevice: widget.device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rate = _profile?.tariffPerKwh ?? 1444.70;
    final dailyCost = widget.device.dailyKwh * rate;
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
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
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
                          widget.device.name,
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
                            '${widget.device.quantity} Unit Terpasang',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        if (_isTopConsumer) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.yellowAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.yellowAccent),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: AppColors.textDark, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Perangkat dengan konsumsi terbesar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text(
                            'Peringkat #$_rank dari $_totalDevices perangkat',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
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
                    _buildRow('Daya Satuan', '${widget.device.powerWatt.toStringAsFixed(0)} Watt'),
                    const Divider(height: 16, color: AppColors.cardBorder),
                    _buildRow('Jumlah Unit', '${widget.device.quantity} unit'),
                    const Divider(height: 16, color: AppColors.cardBorder),
                    _buildRow('Total Daya Terpasang', '${widget.device.totalWatt.toStringAsFixed(0)} Watt', isBold: true),
                    const Divider(height: 16, color: AppColors.cardBorder),
                    _buildRow('Lama Pemakaian / Hari', '${widget.device.dailyHours.toStringAsFixed(1)} Jam'),
                  ]),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Konsumsi Energi & Estimasi Biaya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.yellowAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Estimasi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard([
                    _buildRow(
                      'Konsumsi Harian (Estimasi)',
                      '${widget.device.dailyKwh.toStringAsFixed(2)} kWh',
                      valueColor: AppColors.primaryGreen,
                      isBold: true,
                    ),
                    const Divider(height: 16, color: AppColors.cardBorder),
                    _buildRow(
                      'Tarif Listrik Digunakan',
                      'Rp ${rate.toStringAsFixed(2)} / kWh',
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
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _openInCalculator,
                      icon: const Icon(Icons.calculate_outlined, size: 20),
                      label: const Text('Buka di Kalkulator kWh'),
                    ),
                  ),
                  const SizedBox(height: 12),
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
