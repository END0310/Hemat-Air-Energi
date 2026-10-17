import '../models/consumption_models.dart';
import '../models/device_models.dart';
import '../models/meter_reading_model.dart';
import '../models/token_purchase_model.dart';

class EnergyCalculatorService {
  /// FR-06: Menghitung estimasi konsumsi harian (kWh)
  /// Rumus: (Watt * Jam * Jumlah) / 1000
  static double calculateDailyKwh({
    required double powerWatt,
    required double dailyHours,
    required int quantity,
  }) {
    if (powerWatt <= 0 || dailyHours <= 0 || quantity <= 0) return 0.0;
    return (powerWatt * dailyHours * quantity) / 1000.0;
  }

  /// FR-06: Menghitung estimasi konsumsi bulanan (kWh)
  /// Rumus: kWh/hari * 30
  static double calculateMonthlyKwh(double dailyKwh) {
    if (dailyKwh <= 0) return 0.0;
    return dailyKwh * 30.0;
  }

  /// FR-06: Menghitung estimasi biaya listrik
  /// Rumus: kWh * Tarif
  static double calculateCost({
    required double kwh,
    required double tariffPerKwh,
  }) {
    if (kwh <= 0 || tariffPerKwh <= 0) return 0.0;
    return kwh * tariffPerKwh;
  }

  /// FR-07: Menghitung konsumsi aktual antara dua catatan meter
  /// Rumus PRD:
  /// Jika ada token masuk selama periode:
  ///   Konsumsi aktual = Saldo awal + Total kWh token masuk - Saldo akhir
  /// Jika tidak ada token masuk:
  ///   Konsumsi aktual = Saldo sebelumnya - Saldo sekarang
  static PeriodConsumption calculatePeriodConsumption({
    required MeterReading previousReading,
    required MeterReading currentReading,
    required List<TokenPurchase> allTokens,
  }) {
    // Cari token yang dibeli di antara waktu previousReading dan currentReading
    final start = previousReading.readingDate;
    final end = currentReading.readingDate;

    final tokensInPeriod = allTokens.where((t) {
      final tDate = t.purchaseDate;
      return tDate.isAfter(start) && !tDate.isAfter(end);
    }).toList();

    final double totalTokenKwh = tokensInPeriod.fold(
      0.0,
      (sum, item) => sum + item.kwhToken,
    );

    double actualKwh;
    String formulaExplanation;

    if (tokensInPeriod.isNotEmpty) {
      actualKwh = previousReading.kwhMeter + totalTokenKwh - currentReading.kwhMeter;
      formulaExplanation =
          '${previousReading.kwhMeter.toStringAsFixed(2)} kWh (saldo awal) + '
          '${totalTokenKwh.toStringAsFixed(2)} kWh (token masuk) - '
          '${currentReading.kwhMeter.toStringAsFixed(2)} kWh (saldo akhir) = '
          '${actualKwh.toStringAsFixed(2)} kWh';
    } else {
      actualKwh = previousReading.kwhMeter - currentReading.kwhMeter;
      formulaExplanation =
          '${previousReading.kwhMeter.toStringAsFixed(2)} kWh (saldo sebelumnya) - '
          '${currentReading.kwhMeter.toStringAsFixed(2)} kWh (saldo sekarang) = '
          '${actualKwh.toStringAsFixed(2)} kWh';
    }

    // Hitung jumlah hari periode (minimal 1 hari untuk mencegah pembagian dengan nol)
    final diffInSeconds = end.difference(start).inSeconds;
    final double daysExact = diffInSeconds / 86400.0;
    final int periodDays = daysExact < 1.0 ? 1 : daysExact.round();
    final double divisor = daysExact < 1.0 ? 1.0 : daysExact;
    final double dailyAverage = actualKwh / divisor;

    return PeriodConsumption(
      previousReading: previousReading,
      currentReading: currentReading,
      tokensInPeriod: tokensInPeriod,
      totalKwhTokensInPeriod: totalTokenKwh,
      actualKwh: actualKwh,
      periodDays: periodDays,
      dailyAverageKwh: dailyAverage,
      isNegative: actualKwh < 0,
      formulaExplanation: formulaExplanation,
    );
  }

  /// Menghitung semua periode konsumsi historis dari daftar meter readings
  static List<PeriodConsumption> calculateAllPeriods({
    required List<MeterReading> sortedReadingsAsc, // Terurut dari terlama ke terbaru
    required List<TokenPurchase> allTokens,
  }) {
    final List<PeriodConsumption> results = [];
    if (sortedReadingsAsc.length < 2) return results;

    for (int i = 0; i < sortedReadingsAsc.length - 1; i++) {
      final prev = sortedReadingsAsc[i];
      final curr = sortedReadingsAsc[i + 1];
      results.add(calculatePeriodConsumption(
        previousReading: prev,
        currentReading: curr,
        allTokens: allTokens,
      ));
    }

    return results;
  }

  /// Menghitung rata-rata konsumsi harian dari seluruh periode valid (Baseline)
  static double calculateBaselineDailyAverage(List<PeriodConsumption> periods) {
    final validPeriods = periods.where((p) => !p.isNegative && p.actualKwh >= 0).toList();
    if (validPeriods.isEmpty) return 0.0;

    double totalKwh = 0.0;
    double totalDays = 0.0;

    for (final p in validPeriods) {
      final days = p.currentReading.readingDate.difference(p.previousReading.readingDate).inSeconds / 86400.0;
      final effectiveDays = days < 1.0 ? 1.0 : days;
      totalKwh += p.actualKwh;
      totalDays += effectiveDays;
    }

    if (totalDays <= 0) return 0.0;
    return totalKwh / totalDays;
  }

  /// FR-08: Analisis & Peringkat Perangkat
  /// Mengurutkan perangkat dari estimasi konsumsi kWh terbesar ke terkecil
  static List<DeviceConsumptionRanking> rankDevices({
    required List<Device> devices,
    required double tariffPerKwh,
  }) {
    if (devices.isEmpty) return [];

    // Hitung total konsumsi harian semua perangkat
    final double totalDailyKwh = devices.fold(
      0.0,
      (sum, dev) => sum + dev.dailyKwh,
    );

    // Salin dan urutkan berdasarkan dailyKwh descending
    final sortedDevices = List<Device>.from(devices)
      ..sort((a, b) => b.dailyKwh.compareTo(a.dailyKwh));

    return List.generate(sortedDevices.length, (index) {
      final device = sortedDevices[index];
      final dailyKwh = device.dailyKwh;
      final monthlyKwh = calculateMonthlyKwh(dailyKwh);
      final monthlyCost = calculateCost(kwh: monthlyKwh, tariffPerKwh: tariffPerKwh);
      final percentage = totalDailyKwh > 0 ? (dailyKwh / totalDailyKwh) * 100.0 : 0.0;

      return DeviceConsumptionRanking(
        device: device,
        dailyKwh: dailyKwh,
        monthlyKwh: monthlyKwh,
        monthlyCost: monthlyCost,
        percentageOfTotal: percentage,
        rank: index + 1,
      );
    });
  }

  /// Notifikasi Modul 2: Evaluasi kenaikan konsumsi terhadap baseline rata-rata
  /// Rumus kenaikan: ((Konsumsi hari ini - Rata-rata) / Rata-rata) * 100%
  static double calculatePercentageIncrease({
    required double todayConsumption,
    required double baselineAverage,
  }) {
    if (baselineAverage <= 0) return 0.0;
    return ((todayConsumption - baselineAverage) / baselineAverage) * 100.0;
  }

  /// Memeriksa apakah kenaikan konsumsi memenuhi syarat peringatan notifikasi
  static bool shouldTriggerIncreaseNotification({
    required double todayConsumption,
    required double baselineAverage,
    double thresholdPercent = 30.0,
  }) {
    if (baselineAverage <= 0 || todayConsumption <= 0) return false;
    final increase = calculatePercentageIncrease(
      todayConsumption: todayConsumption,
      baselineAverage: baselineAverage,
    );
    return increase >= thresholdPercent;
  }

  /// Menghasilkan 7 titik data konsumsi mingguan untuk grafik sesuai UI & UX Frame 04
  static List<DailyChartPoint> generateWeeklyChartPoints({
    required List<PeriodConsumption> periods,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final List<DailyChartPoint> points = [];

    // 7 hari ke belakang termasuk hari ini
    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayLabel = dayNames[day.weekday % 7];

      // Cari apakah ada periode konsumsi yang jatuh pada tanggal ini
      double kwhOnThisDay = 0.0;
      for (final p in periods) {
        final pDate = p.currentReading.readingDate;
        if (pDate.year == day.year && pDate.month == day.month && pDate.day == day.day) {
          if (!p.isNegative) {
            kwhOnThisDay += p.actualKwh;
          }
        }
      }

      points.add(DailyChartPoint(
        dayLabel: dayLabel,
        date: day,
        kwh: kwhOnThisDay,
        isToday: i == 0,
      ));
    }

    return points;
  }
}
