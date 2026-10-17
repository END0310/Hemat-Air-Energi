import 'package:flutter_test/flutter_test.dart';
import 'package:nama_project/models/device_models.dart';

void main() {
  group('Device Model Unit Tests', () {
    test('Kalkulasi total watt dan daily kWh harus akurat', () {
      const device = Device(
        name: 'Kulkas Kos',
        powerWatt: 100.0,
        quantity: 2,
        dailyHours: 10.0,
      );

      // Total Watt: 100 Watt * 2 unit = 200 Watt
      expect(device.totalWatt, 200.0);

      // Daily kWh: (200 Watt * 10 jam) / 1000 = 2.0 kWh
      expect(device.dailyKwh, 2.0);
    });

    test('Konversi toMap dan fromMap harus konsisten untuk SQLite', () {
      const original = Device(
        id: 1,
        name: 'Kipas Angin',
        powerWatt: 45.0,
        quantity: 1,
        dailyHours: 8.0,
      );

      final map = original.toMap();
      final converted = Device.fromMap(map);

      expect(converted.id, original.id);
      expect(converted.name, original.name);
      expect(converted.powerWatt, original.powerWatt);
      expect(converted.quantity, original.quantity);
      expect(converted.dailyHours, original.dailyHours);
    });
  });
}
