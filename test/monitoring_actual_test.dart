import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/models/meter_reading_model.dart';
import 'package:nama_project/models/token_purchase_model.dart';
import 'package:nama_project/services/energy_calculator_service.dart';

void main() {
  group('FR-07: Monitoring Konsumsi Aktual Tests', () {
    final t1 = DateTime(2026, 10, 10, 8, 0);
    final t2 = DateTime(2026, 10, 11, 8, 0);
    final t3 = DateTime(2026, 10, 12, 8, 0);

    test('Perhitungan konsumsi aktual TANPA token masuk: Saldo sebelumnya - Saldo sekarang', () {
      final prev = MeterReading(
        id: 1,
        readingDate: t1,
        kwhMeter: 20.0,
        createdAt: t1,
      );
      final curr = MeterReading(
        id: 2,
        readingDate: t2,
        kwhMeter: 15.5,
        createdAt: t2,
      );

      final result = EnergyCalculatorService.calculatePeriodConsumption(
        previousReading: prev,
        currentReading: curr,
        allTokens: [],
      );

      // 20.0 - 15.5 = 4.5 kWh
      expect(result.actualKwh, 4.5);
      expect(result.tokensInPeriod.isEmpty, true);
      expect(result.isNegative, false);
      expect(result.periodDays, 1);
      expect(result.dailyAverageKwh, 4.5);
    });

    test('Perhitungan konsumsi aktual DENGAN token masuk: Saldo awal + Token - Saldo akhir', () {
      // Skenario PRD Bagian 12: Saldo awal 20 kWh + token masuk 10 kWh - saldo akhir 15 kWh = 15 kWh
      final prev = MeterReading(
        id: 1,
        readingDate: t1,
        kwhMeter: 20.0,
        createdAt: t1,
      );
      final curr = MeterReading(
        id: 2,
        readingDate: t2,
        kwhMeter: 15.0,
        createdAt: t2,
      );

      // Token dibeli di antara t1 dan t2
      final token = TokenPurchase(
        id: 1,
        purchaseDate: DateTime(2026, 10, 10, 14, 0),
        amountRp: 20000.0,
        kwhToken: 10.0,
        createdAt: DateTime(2026, 10, 10, 14, 0),
      );

      final result = EnergyCalculatorService.calculatePeriodConsumption(
        previousReading: prev,
        currentReading: curr,
        allTokens: [token],
      );

      // 20.0 + 10.0 - 15.0 = 15.0 kWh
      expect(result.actualKwh, 15.0);
      expect(result.tokensInPeriod.length, 1);
      expect(result.totalKwhTokensInPeriod, 10.0);
      expect(result.isNegative, false);
      expect(result.periodDays, 1);
      expect(result.dailyAverageKwh, 15.0);
    });

    test('Penanganan konsumsi negatif jika saldo akhir lebih besar tanpa pencatatan token', () {
      final prev = MeterReading(
        id: 1,
        readingDate: t1,
        kwhMeter: 10.0,
        createdAt: t1,
      );
      final curr = MeterReading(
        id: 2,
        readingDate: t2,
        kwhMeter: 18.0, // Saldo tiba-tiba bertambah tanpa catatan token
        createdAt: t2,
      );

      final result = EnergyCalculatorService.calculatePeriodConsumption(
        previousReading: prev,
        currentReading: curr,
        allTokens: [],
      );

      // 10.0 - 18.0 = -8.0 kWh
      expect(result.actualKwh, -8.0);
      expect(result.isNegative, true);
    });

    test('Data pencatatan kurang dari 2 tidak menghasilkan periode konsumsi', () {
      final singleReading = [
        MeterReading(id: 1, readingDate: t1, kwhMeter: 20.0, createdAt: t1),
      ];

      final periods = EnergyCalculatorService.calculateAllPeriods(
        sortedReadingsAsc: singleReading,
        allTokens: [],
      );

      expect(periods.isEmpty, true);
    });

    test('Perhitungan baseline rata-rata harian dari kumpulan periode historis', () {
      final r1 = MeterReading(id: 1, readingDate: t1, kwhMeter: 25.0, createdAt: t1);
      final r2 = MeterReading(id: 2, readingDate: t2, kwhMeter: 21.0, createdAt: t2); // 4.0 kWh / 1 hari
      final r3 = MeterReading(id: 3, readingDate: t3, kwhMeter: 17.0, createdAt: t3); // 4.0 kWh / 1 hari

      final periods = EnergyCalculatorService.calculateAllPeriods(
        sortedReadingsAsc: [r1, r2, r3],
        allTokens: [],
      );

      expect(periods.length, 2);
      final baseline = EnergyCalculatorService.calculateBaselineDailyAverage(periods);
      expect(baseline, 4.0);
    });

    test('Grafik 7 hari menghasilkan tepat 7 titik hari', () {
      final points = EnergyCalculatorService.generateWeeklyChartPoints(
        periods: [],
        referenceDate: DateTime(2026, 10, 12),
      );

      expect(points.length, 7);
      expect(points.last.isToday, true);
    });
  });
}
