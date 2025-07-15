import '../models/calculation_record.dart';
import '../services/price_calculation_service.dart';
import '../di/injection.dart';

/// Reusable calculation helper following DRY principle
/// This class provides centralized calculation methods to avoid code duplication
class CalculationHelper {
  static final PriceCalculationService _priceCalculationService = getIt<PriceCalculationService>();

  /// Calculate price from CalculationRecord
  /// This method provides a consistent way to calculate prices across the app
  static PriceCalculationResult calculateFromRecord(CalculationRecord record) {
    return _priceCalculationService.calculatePrice(
      PriceCalculationRequest(
        originalPrice: record.originalPrice,
        exchangeRate: record.exchangeRate,
        currency: record.currency,
        discountRates: record.discounts,
        profitMargin: record.profitMargin,
        vatRate: 20.0, // Default VAT rate
      ),
    );
  }

  /// Calculate price from individual parameters
  /// Use this when you have individual discount values
  static PriceCalculationResult calculateFromParameters({
    required double originalPrice,
    required double exchangeRate,
    required String currency,
    required double discount1,
    required double discount2,
    required double discount3,
    required double profitMargin,
    double vatRate = 20.0,
  }) {
    final discounts = [discount1, discount2, discount3].where((d) => d > 0).toList();
    
    return _priceCalculationService.calculatePrice(
      PriceCalculationRequest(
        originalPrice: originalPrice,
        exchangeRate: exchangeRate,
        currency: currency,
        discountRates: discounts,
        profitMargin: profitMargin,
        vatRate: vatRate,
      ),
    );
  }

  /// Update CalculationRecord with new calculation
  /// This method ensures consistent record updates
  static CalculationRecord updateRecordWithCalculation(CalculationRecord record) {
    final result = calculateFromRecord(record);
    
    return record.copyWith(
      finalPrice: result.finalPriceWithVat,
      createdAt: DateTime.now(),
    );
  }

  /// Create CalculationRecord from current provider state
  /// Use this when saving calculations from the UI
  static CalculationRecord createRecordFromCalculation({
    required String productName,
    required double originalPrice,
    required double exchangeRate,
    required String currency,
    required double discount1,
    required double discount2,
    required double discount3,
    required double profitMargin,
    String? notes,
  }) {
    final result = calculateFromParameters(
      originalPrice: originalPrice,
      exchangeRate: exchangeRate,
      currency: currency,
      discount1: discount1,
      discount2: discount2,
      discount3: discount3,
      profitMargin: profitMargin,
    );

    return CalculationRecord(
      id: 'record_${DateTime.now().millisecondsSinceEpoch}',
      productName: productName,
      originalPrice: originalPrice,
      exchangeRate: exchangeRate,
      discount1: discount1,
      discount2: discount2,
      discount3: discount3,
      profitMargin: profitMargin,
      finalPrice: result.finalPriceWithVat,
      createdAt: DateTime.now(),
      notes: notes,
      currency: currency,
    );
  }

  /// Get cumulative discount rate from individual discounts
  /// This calculates the total discount effect
  static double getCumulativeDiscountRate(List<double> discounts) {
    if (discounts.isEmpty) return 0.0;
    
    double cumulativeRate = 0.0;
    double remainingRate = 100.0;
    
    for (double discount in discounts) {
      if (discount > 0) {
        cumulativeRate += (remainingRate * discount / 100);
        remainingRate -= (remainingRate * discount / 100);
      }
    }
    
    return cumulativeRate;
  }

  /// Get cumulative discount rate from CalculationRecord
  static double getCumulativeDiscountRateFromRecord(CalculationRecord record) {
    return getCumulativeDiscountRate(record.discounts);
  }
}