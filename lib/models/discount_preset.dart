class DiscountPreset {
  final String id;
  final String label;
  final List<double> discounts;
  final double profitMargin;
  
  DiscountPreset({
    required this.id,
    required this.label,
    required this.discounts,
    required this.profitMargin,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'discounts': discounts,
      'profitMargin': profitMargin,
    };
  }
  
  factory DiscountPreset.fromJson(Map<String, dynamic> json) {
    return DiscountPreset(
      id: json['id'],
      label: json['label'],
      discounts: List<double>.from(json['discounts']),
      profitMargin: json['profitMargin'],
    );
  }
  
  String toStorageString() {
    return '$id|$label|${discounts.join(',')}|$profitMargin';
  }
  
  factory DiscountPreset.fromStorageString(String storageString) {
    final parts = storageString.split('|');
    if (parts.length != 4) {
      throw const FormatException('Invalid storage string format');
    }
    
    final discounts = parts[2].split(',').map((e) => double.parse(e)).toList();
    return DiscountPreset(
      id: parts[0],
      label: parts[1],
      discounts: discounts,
      profitMargin: double.parse(parts[3]),
    );
  }
}