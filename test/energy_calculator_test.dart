import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/models/device_models.dart';
import 'package:nama_project/services/energy_calculator_service.dart';

void main() {
  group('FR-06: Kalkulator Konsumsi kWh & Estimasi Biaya Tests', () {
    test('Perhitungan konsumsi harian dan bulanan harus akurat sesuai rumus PRD', () {
      // AC 500 Watt, 1 unit, 6 jam/hari
      // kWh/hari = (500 * 6 * 1) / 1000 = 3.0 kWh/hari
      final dailyKwh = EnergyCalculatorService.calculateDailyKwh(
        powerWatt: 500.0,
        dailyHours: 6.0,
        quantity: 1,
      );
      expect(dailyKwh, 3.0);

      // kWh/bulan = 3.0 * 30 = 90.0 kWh/bulan
      final monthlyKwh = EnergyCalculatorService.calculateMonthlyKwh(dailyKwh);
      expect(monthlyKwh, 90.0);
    });

    test('Perhitungan estimasi biaya berdasarkan tarif resmi PLN (R-1 1.300 VA)', () {
      const tariff = 1444.70; // Rp/kWh
      final dailyKwh = EnergyCalculatorService.calculateDailyKwh(
        powerWatt: 500.0,
        dailyHours: 6.0,
        quantity: 1,
      );
      final monthlyKwh = EnergyCalculatorService.calculateMonthlyKwh(dailyKwh);

      // Biaya harian = 3.0 * 1444.70 = 4334.10
      final dailyCost = EnergyCalculatorService.calculateCost(kwh: dailyKwh, tariffPerKwh: tariff);
      expect(dailyCost, closeTo(4334.10, 0.01));

      // Biaya bulanan = 90.0 * 1444.70 = 130023.00
      final monthlyCost = EnergyCalculatorService.calculateCost(kwh: monthlyKwh, tariffPerKwh: tariff);
      expect(monthlyCost, closeTo(130023.00, 0.01));
    });

    test('Input tidak valid (angka nol atau negatif) mengembalikan 0.0', () {
      expect(
        EnergyCalculatorService.calculateDailyKwh(powerWatt: 0, dailyHours: 5, quantity: 1),
        0.0,
      );
      expect(
        EnergyCalculatorService.calculateDailyKwh(powerWatt: 100, dailyHours: -2, quantity: 1),
        0.0,
      );
      expect(
        EnergyCalculatorService.calculateDailyKwh(powerWatt: 100, dailyHours: 5, quantity: 0),
        0.0,
      );
      expect(
        EnergyCalculatorService.calculateMonthlyKwh(-10),
        0.0,
      );
      expect(
        EnergyCalculatorService.calculateCost(kwh: -5, tariffPerKwh: 1444.70),
        0.0,
      );
    });

    test('Perubahan data perangkat secara langsung mengubah hasil perhitungan', () {
      var device = const Device(
        name: 'Kipas Angin',
        powerWatt: 50.0,
        quantity: 1,
        dailyHours: 8.0,
      );
      // (50 * 8 * 1) / 1000 = 0.4 kWh/hari
      expect(device.dailyKwh, 0.4);

      // Ubah durasi dari 8 jam menjadi 12 jam
      device = device.copyWith(dailyHours: 12.0);
      // (50 * 12 * 1) / 1000 = 0.6 kWh/hari
      expect(device.dailyKwh, 0.6);

      // Ubah jumlah unit dari 1 menjadi 2
      device = device.copyWith(quantity: 2);
      // (50 * 12 * 2) / 1000 = 1.2 kWh/hari
      expect(device.dailyKwh, 1.2);
    });
  });
}
