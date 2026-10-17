import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/services/energy_calculator_service.dart';

void main() {
  group('Notifikasi Modul 2: Kenaikan Konsumsi & Ambang Batas Tests', () {
    test('Perhitungan persentase kenaikan konsumsi terhadap baseline rata-rata', () {
      // Contoh PRD: Rata-rata 4 kWh/hari, hari ini 6 kWh -> Naik 50%
      final percent = EnergyCalculatorService.calculatePercentageIncrease(
        todayConsumption: 6.0,
        baselineAverage: 4.0,
      );
      expect(percent, 50.0);
    });

    test('Konsumsi melampaui ambang batas 30% harus memicu peringatan (true)', () {
      // Rata-rata 4.0 kWh, hari ini 6.0 kWh -> Kenaikan 50% >= 30% threshold
      final shouldTrigger = EnergyCalculatorService.shouldTriggerIncreaseNotification(
        todayConsumption: 6.0,
        baselineAverage: 4.0,
        thresholdPercent: 30.0,
      );
      expect(shouldTrigger, true);
    });

    test('Konsumsi di bawah ambang batas 30% tidak memicu peringatan (false)', () {
      // Rata-rata 4.0 kWh, hari ini 4.8 kWh -> Kenaikan 20% < 30% threshold
      final shouldTrigger = EnergyCalculatorService.shouldTriggerIncreaseNotification(
        todayConsumption: 4.8,
        baselineAverage: 4.0,
        thresholdPercent: 30.0,
      );
      expect(shouldTrigger, false);
    });

    test('Baseline nol atau belum tersedia tidak memicu notifikasi', () {
      final shouldTriggerZeroBaseline = EnergyCalculatorService.shouldTriggerIncreaseNotification(
        todayConsumption: 5.0,
        baselineAverage: 0.0,
      );
      expect(shouldTriggerZeroBaseline, false);

      final shouldTriggerNegativeBaseline = EnergyCalculatorService.shouldTriggerIncreaseNotification(
        todayConsumption: 5.0,
        baselineAverage: -2.0,
      );
      expect(shouldTriggerNegativeBaseline, false);
    });

    test('Konsumsi hari ini nol atau negatif tidak memicu notifikasi', () {
      final shouldTrigger = EnergyCalculatorService.shouldTriggerIncreaseNotification(
        todayConsumption: 0.0,
        baselineAverage: 4.0,
      );
      expect(shouldTrigger, false);
    });
  });
}
