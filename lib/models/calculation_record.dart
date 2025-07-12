class CalculationRecord {
  String id;
  String productName;
  double originalPrice;
  double exchangeRate;
  double discountRate;
  double finalPrice;
  DateTime createdAt;
  String? notes;
  String currency;

  CalculationRecord({
    required this.id,
    required this.productName,
    required this.originalPrice,
    required this.exchangeRate,
    required this.discountRate,
    required this.finalPrice,
    required this.createdAt,
    this.notes,
    this.currency = 'USD',
  });

  CalculationRecord copyWith({
    String? id,
    String? productName,
    double? originalPrice,
    double? exchangeRate,
    double? discountRate,
    double? finalPrice,
    DateTime? createdAt,
    String? notes,
    String? currency,
  }) {
    return CalculationRecord(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      originalPrice: originalPrice ?? this.originalPrice,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      discountRate: discountRate ?? this.discountRate,
      finalPrice: finalPrice ?? this.finalPrice,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'originalPrice': originalPrice,
      'exchangeRate': exchangeRate,
      'discountRate': discountRate,
      'finalPrice': finalPrice,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'currency': currency,
    };
  }

  factory CalculationRecord.fromJson(Map<String, dynamic> json) {
    return CalculationRecord(
      id: json['id'] ?? 'record_${DateTime.now().millisecondsSinceEpoch}',
      productName: json['productName'] ?? 'Ürün',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      exchangeRate: (json['exchangeRate'] ?? 1).toDouble(),
      discountRate: (json['discountRate'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? 
        DateTime.parse(json['createdAt']) : DateTime.now(),
      notes: json['notes'],
      currency: json['currency'] ?? 'USD',
    );
  }

  @override
  String toString() {
    return 'CalculationRecord(id: $id, productName: $productName, originalPrice: $originalPrice, exchangeRate: $exchangeRate, discountRate: $discountRate, finalPrice: $finalPrice, createdAt: $createdAt, notes: $notes, currency: $currency)';
  }
}