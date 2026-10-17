class TokenPurchase {
  final int? id;
  final DateTime purchaseDate;
  final double amountRp;
  final double kwhToken;
  final DateTime createdAt;

  const TokenPurchase({
    this.id,
    required this.purchaseDate,
    required this.amountRp,
    required this.kwhToken,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_date': purchaseDate.toIso8601String(),
      'amount_rp': amountRp,
      'kwh_token': kwhToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TokenPurchase.fromMap(Map<String, dynamic> map) {
    return TokenPurchase(
      id: map['id'] as int?,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      amountRp: (map['amount_rp'] as num).toDouble(),
      kwhToken: (map['kwh_token'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  TokenPurchase copyWith({
    int? id,
    DateTime? purchaseDate,
    double? amountRp,
    double? kwhToken,
    DateTime? createdAt,
  }) {
    return TokenPurchase(
      id: id ?? this.id,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      amountRp: amountRp ?? this.amountRp,
      kwhToken: kwhToken ?? this.kwhToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
