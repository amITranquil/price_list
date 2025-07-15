class CalculationRecord {
  String id;
  String productName;
  double originalPrice;
  double exchangeRate;
  double discount1;
  double discount2;
  double discount3;
  double profitMargin;
  double finalPrice;
  DateTime createdAt;
  String? notes;
  String currency;

  CalculationRecord({
    required this.id,
    required this.productName,
    required this.originalPrice,
    required this.exchangeRate,
    this.discount1 = 0.0,
    this.discount2 = 0.0,
    this.discount3 = 0.0,
    this.profitMargin = 40.0,
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
    double? discount1,
    double? discount2,
    double? discount3,
    double? profitMargin,
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
      discount1: discount1 ?? this.discount1,
      discount2: discount2 ?? this.discount2,
      discount3: discount3 ?? this.discount3,
      profitMargin: profitMargin ?? this.profitMargin,
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
      'discount1': discount1,
      'discount2': discount2,
      'discount3': discount3,
      'profitMargin': profitMargin,
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
      discount1: (json['discount1'] ?? json['discountRate'] ?? 0).toDouble(),
      discount2: (json['discount2'] ?? 0).toDouble(),
      discount3: (json['discount3'] ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 40.0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? 
        DateTime.parse(json['createdAt']) : DateTime.now(),
      notes: json['notes'],
      currency: json['currency'] ?? 'USD',
    );
  }

  // Backward compatibility getter
  double get discountRate => discount1;

  // Helper method to get all discounts as a list
  List<double> get discounts => [discount1, discount2, discount3].where((d) => d > 0).toList();

  @override
  String toString() {
    return 'CalculationRecord(id: $id, productName: $productName, originalPrice: $originalPrice, exchangeRate: $exchangeRate, discount1: $discount1, discount2: $discount2, discount3: $discount3, profitMargin: $profitMargin, finalPrice: $finalPrice, createdAt: $createdAt, notes: $notes, currency: $currency)';
  }
}