import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/database_helper.dart';
import '../models/consumption_models.dart';
import '../models/electricity_profile_model.dart';
import '../models/meter_reading_model.dart';
import '../models/token_purchase_model.dart';
import '../services/energy_calculator_service.dart';
import '../services/notification_service.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  List<MeterReading> _meterReadings = [];
  List<TokenPurchase> _tokenPurchases = [];
  ElectricityProfile? _profile;
  List<PeriodConsumption> _periods = [];
  List<DailyChartPoint> _weeklyPoints = [];
  double _baselineDailyAverage = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final readingsAsc = await DatabaseHelper.instance.getMeterReadings(ascending: true);
      final tokensAsc = await DatabaseHelper.instance.getTokenPurchases(ascending: true);
      final profile = await DatabaseHelper.instance.getElectricityProfile();

      final periods = EnergyCalculatorService.calculateAllPeriods(
        sortedReadingsAsc: readingsAsc,
        allTokens: tokensAsc,
      );

      final baseline = EnergyCalculatorService.calculateBaselineDailyAverage(periods);
      final weekly = EnergyCalculatorService.generateWeeklyChartPoints(periods: periods);

      if (mounted) {
        setState(() {
          _meterReadings = readingsAsc.reversed.toList(); // descending untuk tampilan riwayat
          _tokenPurchases = tokensAsc.reversed.toList();
          _profile = profile;
          _periods = periods.reversed.toList(); // periode terbaru di atas
          _baselineDailyAverage = baseline;
          _weeklyPoints = weekly;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading monitoring data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _simulateNextDummyReading() async {
    final lastKwh = _meterReadings.isNotEmpty ? _meterReadings.first.kwhMeter : 12.7;
    final nextKwh = (lastKwh - 5.5) > 0 ? (lastKwh - 5.5) : (lastKwh + 15.0);
    final newReading = MeterReading(
      readingDate: DateTime.now(),
      kwhMeter: double.parse(nextKwh.toStringAsFixed(1)),
      createdAt: DateTime.now(),
    );
    await DatabaseHelper.instance.insertMeterReading(newReading);

    final allReadings = await DatabaseHelper.instance.getMeterReadings(ascending: true);
    final allTokens = await DatabaseHelper.instance.getTokenPurchases(ascending: true);
    final periods = EnergyCalculatorService.calculateAllPeriods(
      sortedReadingsAsc: allReadings,
      allTokens: allTokens,
    );
    if (periods.isNotEmpty) {
      final latestPeriod = periods.last;
      final baseline = EnergyCalculatorService.calculateBaselineDailyAverage(periods);
      if (!latestPeriod.isNegative && baseline > 0) {
        await NotificationService.instance.checkAndNotifyConsumptionSpike(
          todayConsumption: latestPeriod.dailyAverageKwh,
          baselineAverage: baseline,
          thresholdPercent: 30.0,
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulasi pencatatan saldo dummy (${newReading.kwhMeter} kWh) ditambahkan!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _loadData();
    }
  }

  Future<void> _resetDummyData() async {
    await DatabaseHelper.instance.resetDummyModule1Data();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data dummy Modul 1 berhasil di-reset ke kondisi awal!'),
          backgroundColor: AppColors.textDark,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Monitoring Konsumsi Aktual',
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
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    if (_periods.isEmpty) _buildInsufficientDataCard(),
                    if (_periods.isNotEmpty && _periods.first.isNegative) _buildNegativeWarningCard(_periods.first),
                    if (_periods.isNotEmpty) ...[
                      _buildLatestConsumptionCard(_periods.first),
                      const SizedBox(height: 20),
                      _buildWeeklyChartCard(),
                      const SizedBox(height: 20),
                      _buildPeriodHistoryCard(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    final latestReading = _meterReadings.isNotEmpty ? _meterReadings.first : null;
    final currentKwh = latestReading?.kwhMeter ?? 0.0;

    double? daysRemaining;
    if (_baselineDailyAverage > 0) {
      daysRemaining = currentKwh / _baselineDailyAverage;
    }

    final isLow = daysRemaining != null && daysRemaining <= 2.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLow ? AppColors.errorRed.withValues(alpha: 0.4) : AppColors.cardBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SALDO LISTRIK METERAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLow ? AppColors.errorRed.withValues(alpha: 0.15) : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLow ? 'Saldo Rendah' : 'Aman',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isLow ? AppColors.errorRed : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentKwh.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'kWh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            daysRemaining != null
                ? 'Cukup untuk ± ${daysRemaining.toStringAsFixed(1)} hari ke depan'
                : 'Belum ada data baseline rata-rata harian',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isLow ? AppColors.errorRed : AppColors.textSecondary,
            ),
          ),
          if (_tokenPurchases.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.receipt_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${_tokenPurchases.length} riwayat pembelian token (+${_tokenPurchases.fold<double>(0.0, (s, t) => s + t.kwhToken).toStringAsFixed(1)} kWh)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
          if (latestReading != null) ...[
            const SizedBox(height: 8),
            Text(
              'Dicatat pada ${latestReading.readingDate.day}/${latestReading.readingDate.month}/${latestReading.readingDate.year} pukul ${latestReading.readingDate.hour.toString().padLeft(2, '0')}:${latestReading.readingDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _simulateNextDummyReading,
            icon: const Icon(Icons.play_circle_outline, size: 20),
            label: const Text('Simulasi Catat Meter', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _resetDummyData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset Data', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildInsufficientDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timeline, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Data Belum Cukup untuk Perhitungan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Untuk menghitung konsumsi aktual, sistem memerlukan minimal 2 catatan saldo meter pada waktu berbeda.\n\n'
            'Silakan gunakan tombol "Simulasi Catat Meter" di atas untuk menambah pencatatan dummy.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildNegativeWarningCard(PeriodConsumption period) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
              SizedBox(width: 8),
              Text(
                'Peringatan: Nilai Konsumsi Negatif',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorRed,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hasil kalkulasi periode terakhir bernilai ${period.actualKwh.toStringAsFixed(2)} kWh. '
            'Kondisi ini terjadi jika saldo akhir tercatat lebih besar daripada saldo awal padahal tidak ada transaksi token yang dicatat. '
            'Harap periksa kembali ketepatan angka saldo meter atau catat transaksi token yang bersangkutan.',
            style: const TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestConsumptionCard(PeriodConsumption latest) {
    final rate = _profile?.tariffPerKwh ?? 1444.70;
    final estimatedCost = latest.actualKwh > 0 ? latest.actualKwh * rate : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KONSUMSI AKTUAL PERIODE TERAKHIR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Aktual',
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
                    Text(
                      '${latest.actualKwh.toStringAsFixed(2)} kWh',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: latest.isNegative ? AppColors.errorRed : AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Terpakai selama ${latest.periodDays} hari',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.cardBorder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${latest.dailyAverageKwh.toStringAsFixed(2)} kWh/hari',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '± Rp ${estimatedCost.toStringAsFixed(0)} biaya periode',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.functions, color: AppColors.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Logika Perhitungan (PRD):\n${latest.formulaExplanation}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard() {
    final maxKwh = _weeklyPoints.fold<double>(
      1.0,
      (max, p) => p.kwh > max ? p.kwh : max,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GRAFIK KONSUMSI 7 HARI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Rata-rata: ${_baselineDailyAverage.toStringAsFixed(2)} kWh/hari',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyPoints.map((point) {
                final heightFactor = (point.kwh / maxKwh).clamp(0.08, 1.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      point.kwh > 0 ? point.kwh.toStringAsFixed(1) : '-',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: point.isToday ? FontWeight.bold : FontWeight.normal,
                        color: point.isToday ? AppColors.primaryGreen : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 80 * heightFactor,
                      decoration: BoxDecoration(
                        color: point.isToday
                            ? AppColors.primaryGreen
                            : (point.kwh > 0 ? AppColors.lightGreen : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(6),
                        border: point.isToday
                            ? Border.all(color: AppColors.yellowAccent, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      point.dayLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: point.isToday ? FontWeight.bold : FontWeight.w500,
                        color: point.isToday ? AppColors.primaryGreen : AppColors.textDark,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Grafik disusun dari pencatatan aktual meter & token dalam 7 hari terakhir',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RIWAYAT PERIODE KONSUMSI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _periods.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final p = _periods[index];
              final prevDate = p.previousReading.readingDate;
              final currDate = p.currentReading.readingDate;

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: p.isNegative ? AppColors.errorRed.withValues(alpha: 0.1) : AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      p.isNegative ? Icons.error_outline : Icons.electric_meter,
                      color: p.isNegative ? AppColors.errorRed : AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currDate.day}/${currDate.month} vs ${prevDate.day}/${prevDate.month}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${p.previousReading.kwhMeter.toStringAsFixed(1)} kWh → ${p.currentReading.kwhMeter.toStringAsFixed(1)} kWh'
                          '${p.totalKwhTokensInPeriod > 0 ? " (+${p.totalKwhTokensInPeriod.toStringAsFixed(1)} token)" : ""}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${p.actualKwh.toStringAsFixed(2)} kWh',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: p.isNegative ? AppColors.errorRed : AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        '${p.dailyAverageKwh.toStringAsFixed(1)} kWh/hari',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
