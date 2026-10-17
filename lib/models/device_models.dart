class Device {
  final int? id;
  final String name;
  final double powerWatt;
  final int quantity;
  final double dailyHours;

  const Device({
    this.id,
    required this.name,
    required this.powerWatt,
    required this.quantity,
    required this.dailyHours,
  });

  double get totalWatt => powerWatt * quantity;

  double get dailyKwh => (totalWatt * dailyHours) / 1000.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'power_watt': powerWatt,
      'quantity': quantity,
      'daily_hours': dailyHours,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int?,
      name: map['name'] as String,
      powerWatt: (map['power_watt'] as num).toDouble(),
      quantity: map['quantity'] as int,
      dailyHours: (map['daily_hours'] as num).toDouble(),
    );
  }

  Device copyWith({
    int? id,
    String? name,
    double? powerWatt,
    int? quantity,
    double? dailyHours,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      powerWatt: powerWatt ?? this.powerWatt,
      quantity: quantity ?? this.quantity,
      dailyHours: dailyHours ?? this.dailyHours,
    );
  }
}
