import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/consumption_models.dart';
import '../models/electricity_profile_model.dart';
import '../services/energy_calculator_service.dart';
import 'add_device_screen.dart';
import 'device_detail_screen.dart';

class DeviceAnalysisScreen extends StatefulWidget {
  const DeviceAnalysisScreen({super.key});

  @override
  State<DeviceAnalysisScreen> createState() => _DeviceAnalysisScreenState();
}

class _DeviceAnalysisScreenState extends State<DeviceAnalysisScreen> {
  List<DeviceConsumptionRanking> _rankedDevices = [];
  ElectricityProfile? _profile;
  double _totalDailyKwh = 0.0;
  double _totalMonthlyKwh = 0.0;
  double _totalMonthlyCost = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() => _isLoading = true);

    try {
      final devices = await DatabaseHelper.instance.getDevices();
      final profile = await DatabaseHelper.instance.getElectricityProfile();

      final ranked = EnergyCalculatorService.rankDevices(
        devices: devices,
        tariffPerKwh: profile.tariffPerKwh,
      );

      final totalDaily = devices.fold(0.0, (sum, d) => sum + d.dailyKwh);
      final totalMonthly = EnergyCalculatorService.calculateMonthlyKwh(totalDaily);
      final totalCost = EnergyCalculatorService.calculateCost(
        kwh: totalMonthly,
        tariffPerKwh: profile.tariffPerKwh,
      );

      if (mounted) {
        setState(() {
          _rankedDevices = ranked;
          _profile = profile;
          _totalDailyKwh = totalDaily;
          _totalMonthlyKwh = totalMonthly;
          _totalMonthlyCost = totalCost;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading device analysis: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToAddDevice() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
    );
    if (result == true && mounted) {
      _loadAnalysisData();
    }
  }

  Future<void> _navigateToDetail(DeviceConsumptionRanking item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => DeviceDetailScreen(device: item.device)),
    );
    if (result == true && mounted) {
      _loadAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Analisis Perangkat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Perbarui Data',
            onPressed: _loadAnalysisData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadAnalysisData,
              color: AppColors.primaryGreen,
              child: _rankedDevices.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 16),
                          _buildTopConsumerSpotlight(),
                          const SizedBox(height: 20),
                          const Text(
                            'PERINGKAT ESTIMASI KONSUMSI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRankedList(),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_rankedDevices.length} Perangkat Terdaftar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Estimasi Teoretis',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Konsumsi Harian',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_totalDailyKwh.toStringAsFixed(2)} kWh',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      '≈ ${_totalMonthlyKwh.toStringAsFixed(1)} kWh/bulan',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.cardBorder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimasi Biaya Bulanan',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_totalMonthlyCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Berdasarkan akumulasi pemakaian harian dengan tarif Rp ${(_profile?.tariffPerKwh ?? 1444.70).toStringAsFixed(2)}/kWh.',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTopConsumerSpotlight() {
    final top = _rankedDevices.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellowAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.yellowAccent, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.yellowAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star, color: AppColors.textDark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KONTRIBUTOR KONSUMSI TERBESAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${top.device.name} merupakan perangkat dengan estimasi konsumsi terbesar.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Menyumbang ${top.percentageOfTotal.toStringAsFixed(1)}% dari total estimasi energi kamar '
                  '(± ${top.monthlyKwh.toStringAsFixed(1)} kWh atau Rp ${top.monthlyCost.toStringAsFixed(0)}/bulan).',
                  style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rankedDevices.length,
      itemBuilder: (context, index) {
        final item = _rankedDevices[index];
        final rank = item.rank;

        Color rankBadgeColor = AppColors.primaryGreen;
        if (rank == 1) rankBadgeColor = AppColors.yellowAccent;
        if (rank == 2) rankBadgeColor = Colors.grey.shade400;
        if (rank == 3) rankBadgeColor = Colors.brown.shade300;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _navigateToDetail(item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: rankBadgeColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: rank == 1 ? AppColors.textDark : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.device.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${item.device.quantity} unit • ${item.device.powerWatt.toStringAsFixed(0)} W • ${item.device.dailyHours.toStringAsFixed(1)} jam/hari',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.monthlyKwh.toStringAsFixed(1)} kWh',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Text(
                            'Rp ${item.monthlyCost.toStringAsFixed(0)}/bln',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.percentageOfTotal / 100.0,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rank == 1 ? AppColors.yellowAccent : AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item.percentageOfTotal.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.analytics_outlined, size: 64, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Perangkat untuk Dianalisis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan perangkat listrik pada daftar inventaris untuk melihat peringkat dan analisis konsumsi energi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _navigateToAddDevice,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Perangkat'),
            ),
          ],
        ),
      ),
    );
  }
}
