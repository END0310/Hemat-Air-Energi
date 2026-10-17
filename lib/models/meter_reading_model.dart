class MeterReading {
  final int? id;
  final DateTime readingDate;
  final double kwhMeter;
  final String? photoPath;
  final DateTime createdAt;

  const MeterReading({
    this.id,
    required this.readingDate,
    required this.kwhMeter,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reading_date': readingDate.toIso8601String(),
      'kwh_meter': kwhMeter,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MeterReading.fromMap(Map<String, dynamic> map) {
    return MeterReading(
      id: map['id'] as int?,
      readingDate: DateTime.parse(map['reading_date'] as String),
      kwhMeter: (map['kwh_meter'] as num).toDouble(),
      photoPath: map['photo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  MeterReading copyWith({
    int? id,
    DateTime? readingDate,
    double? kwhMeter,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return MeterReading(
      id: id ?? this.id,
      readingDate: readingDate ?? this.readingDate,
      kwhMeter: kwhMeter ?? this.kwhMeter,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
