class TariffConfig {
  final int? id;
  final String category;
  final int powerVa;
  final double tariffPerKwh;

  const TariffConfig({
    this.id,
    required this.category,
    required this.powerVa,
    required this.tariffPerKwh,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'power_va': powerVa,
      'tariff_per_kwh': tariffPerKwh,
    };
  }

  factory TariffConfig.fromMap(Map<String, dynamic> map) {
    return TariffConfig(
      id: map['id'] as int?,
      category: map['category'] as String,
      powerVa: map['power_va'] as int,
      tariffPerKwh: (map['tariff_per_kwh'] as num).toDouble(),
    );
  }

  String get displayName => '$category - $powerVa VA (Rp ${tariffPerKwh.toStringAsFixed(2)}/kWh)';
}

class ElectricityProfile {
  final int? id;
  final String category;
  final int powerVa;
  final String connectionType;
  final double tariffPerKwh;

  const ElectricityProfile({
    this.id,
    required this.category,
    required this.powerVa,
    this.connectionType = 'Prabayar / Token',
    required this.tariffPerKwh,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'power_va': powerVa,
      'connection_type': connectionType,
      'tariff_per_kwh': tariffPerKwh,
    };
  }

  factory ElectricityProfile.fromMap(Map<String, dynamic> map) {
    return ElectricityProfile(
      id: map['id'] as int?,
      category: map['category'] as String,
      powerVa: map['power_va'] as int,
      connectionType: map['connection_type'] as String? ?? 'Prabayar / Token',
      tariffPerKwh: (map['tariff_per_kwh'] as num).toDouble(),
    );
  }

  ElectricityProfile copyWith({
    int? id,
    String? category,
    int? powerVa,
    String? connectionType,
    double? tariffPerKwh,
  }) {
    return ElectricityProfile(
      id: id ?? this.id,
      category: category ?? this.category,
      powerVa: powerVa ?? this.powerVa,
      connectionType: connectionType ?? this.connectionType,
      tariffPerKwh: tariffPerKwh ?? this.tariffPerKwh,
    );
  }
}
