class CalculationRecord {
  String id;
  String productName;
  double originalPrice;
  double exchangeRate;
  double discountRate;
  double finalPrice;
  DateTime createdAt;
  String? notes;

  CalculationRecord({
    required this.id,
    required this.productName,
    required this.originalPrice,
    required this.exchangeRate,
    required this.discountRate,
    required this.finalPrice,
    required this.createdAt,
    this.notes,
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
    );
  }

  @override
  String toString() {
    return 'CalculationRecord(id: $id, productName: $productName, originalPrice: $originalPrice, exchangeRate: $exchangeRate, discountRate: $discountRate, finalPrice: $finalPrice, createdAt: $createdAt, notes: $notes)';
  }
}