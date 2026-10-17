import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/models/device_models.dart';
import 'package:nama_project/services/energy_calculator_service.dart';

void main() {
  group('FR-08: Analisis & Peringkat Perangkat Tests', () {
    const tariff = 1444.70;

    final devices = [
      const Device(id: 1, name: 'Lampu Belajar', powerWatt: 12.0, quantity: 2, dailyHours: 8.0),
      // Lampu: (12 * 8 * 2) / 1000 = 0.192 kWh/hari
      const Device(id: 2, name: 'AC Kamar', powerWatt: 500.0, quantity: 1, dailyHours: 6.0),
      // AC: (500 * 6 * 1) / 1000 = 3.0 kWh/hari
      const Device(id: 3, name: 'Kulkas Kos', powerWatt: 100.0, quantity: 1, dailyHours: 15.0),
      // Kulkas: (100 * 15 * 1) / 1000 = 1.5 kWh/hari
      const Device(id: 4, name: 'TV LED', powerWatt: 100.0, quantity: 1, dailyHours: 4.0),
      // TV: (100 * 4 * 1) / 1000 = 0.4 kWh/hari
    ];

    test('Perangkat harus terurut dari estimasi konsumsi kWh terbesar ke terkecil', () {
      final ranked = EnergyCalculatorService.rankDevices(
        devices: devices,
        tariffPerKwh: tariff,
      );

      expect(ranked.length, 4);

      // Rank 1: AC Kamar (3.0 kWh/hari)
      expect(ranked[0].rank, 1);
      expect(ranked[0].device.name, 'AC Kamar');
      expect(ranked[0].dailyKwh, 3.0);
      expect(ranked[0].monthlyKwh, 90.0);

      // Rank 2: Kulkas Kos (1.5 kWh/hari)
      expect(ranked[1].rank, 2);
      expect(ranked[1].device.name, 'Kulkas Kos');
      expect(ranked[1].dailyKwh, 1.5);
      expect(ranked[1].monthlyKwh, 45.0);

      // Rank 3: TV LED (0.4 kWh/hari)
      expect(ranked[2].rank, 3);
      expect(ranked[2].device.name, 'TV LED');
      expect(ranked[2].dailyKwh, 0.4);

      // Rank 4: Lampu Belajar (0.192 kWh/hari)
      expect(ranked[3].rank, 4);
      expect(ranked[3].device.name, 'Lampu Belajar');
      expect(ranked[3].dailyKwh, 0.192);
    });

    test('Persentase kontribusi beban masing-masing perangkat harus konsisten dan berjumlah 100%', () {
      final ranked = EnergyCalculatorService.rankDevices(
        devices: devices,
        tariffPerKwh: tariff,
      );

      final totalPercentage = ranked.fold<double>(0.0, (sum, r) => sum + r.percentageOfTotal);
      expect(totalPercentage, closeTo(100.0, 0.01));

      // AC: 3.0 / (3.0 + 1.5 + 0.4 + 0.192) = 3.0 / 5.092 ≈ 58.91%
      expect(ranked[0].percentageOfTotal, closeTo(58.91, 0.1));
    });

    test('Daftar perangkat kosong menghasilkan list ranking kosong tanpa error', () {
      final ranked = EnergyCalculatorService.rankDevices(
        devices: [],
        tariffPerKwh: tariff,
      );

      expect(ranked.isEmpty, true);
    });
  });
}
