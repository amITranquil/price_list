import 'package:flutter_test/flutter_test.dart';
import 'package:price_list/services/price_calculation_service.dart';

void main() {
  group('StandardPriceCalculationService', () {
    late PriceCalculationService calculationService;

    setUp(() {
      calculationService = StandardPriceCalculationService();
    });

    group('calculatePrice', () {
      test('should calculate price with no discounts', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3000.0); // 100 * 30
        expect(result.priceAfterDiscounts, 3000.0); // No discounts
        expect(result.purchasePrice, 2400.0); // 3000 * 0.8 (20% tax)
        expect(result.purchasePriceWithTax, 3000.0); // 2400 * 1.25 (25% tax)
        expect(result.salePriceWithProfit, 3360.0); // 2400 * 1.4 (40% profit)
        expect(result.finalPriceWithVat, 4032.0); // 3360 * 1.2 (20% VAT)
        expect(result.totalDiscountRate, 0.0);
      });

      test('should calculate price with single discount', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [10.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3000.0); // 100 * 30
        expect(result.priceAfterDiscounts, 2700.0); // 3000 * 0.9 (10% discount)
        expect(result.purchasePrice, 2160.0); // 2700 * 0.8 (20% tax)
        expect(result.purchasePriceWithTax, 2700.0); // 2160 * 1.25 (25% tax)
        expect(result.salePriceWithProfit, 3024.0); // 2160 * 1.4 (40% profit)
        expect(result.finalPriceWithVat, 3628.8); // 3024 * 1.2 (20% VAT)
        expect(result.totalDiscountRate, 10.0);
      });

      test('should calculate price with multiple discounts', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [10.0, 5.0, 2.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3000.0); // 100 * 30
        
        // Cumulative discount: 10% + 5% + 2% = 17%
        // But calculated as: 3000 * 0.9 * 0.95 * 0.98 = 2508.9
        expect(result.priceAfterDiscounts, closeTo(2508.9, 0.1));
        
        // Total discount rate should be approximately 16.37%
        expect(result.totalDiscountRate, closeTo(16.37, 0.1));
      });

      test('should calculate price with zero profit margin', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 0.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3000.0);
        expect(result.priceAfterDiscounts, 3000.0);
        expect(result.purchasePrice, 2400.0);
        expect(result.purchasePriceWithTax, 3000.0);
        expect(result.salePriceWithProfit, 2400.0); // No profit added
        expect(result.finalPriceWithVat, 2880.0); // 2400 * 1.2 (20% VAT)
      });

      test('should calculate price with high profit margin', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 100.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3000.0);
        expect(result.priceAfterDiscounts, 3000.0);
        expect(result.purchasePrice, 2400.0);
        expect(result.purchasePriceWithTax, 3000.0);
        expect(result.salePriceWithProfit, 4800.0); // 2400 * 2.0 (100% profit)
        expect(result.finalPriceWithVat, 5760.0); // 4800 * 1.2 (20% VAT)
      });

      test('should calculate price with small amounts', () {
        final request = PriceCalculationRequest(
          originalPrice: 1.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 30.0);
        expect(result.priceAfterDiscounts, 30.0);
        expect(result.purchasePrice, 24.0);
        expect(result.purchasePriceWithTax, 30.0);
        expect(result.salePriceWithProfit, 33.6);
        expect(result.finalPriceWithVat, 40.32);
      });

      test('should calculate price with large amounts', () {
        final request = PriceCalculationRequest(
          originalPrice: 10000.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 300000.0);
        expect(result.priceAfterDiscounts, 300000.0);
        expect(result.purchasePrice, 240000.0);
        expect(result.purchasePriceWithTax, 300000.0);
        expect(result.salePriceWithProfit, 336000.0);
        expect(result.finalPriceWithVat, 403200.0);
      });

      test('should generate calculation steps', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [10.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.steps.length, greaterThan(0));
        
        // Check that steps contain expected descriptions
        final stepDescriptions = result.steps.map((step) => step.description).toList();
        expect(stepDescriptions.any((desc) => desc.contains('Original price')), true);
        expect(stepDescriptions.any((desc) => desc.contains('Exchange rate')), true);
        expect(stepDescriptions.any((desc) => desc.contains('Discount')), true);
        expect(stepDescriptions.any((desc) => desc.contains('Profit margin')), true);
        expect(stepDescriptions.any((desc) => desc.contains('VAT')), true);
      });

      test('should handle EUR currency', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 35.0,
          currency: 'EUR',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3500.0); // 100 * 35
        expect(result.priceAfterDiscounts, 3500.0);
        expect(result.purchasePrice, 2800.0);
        expect(result.purchasePriceWithTax, 3500.0);
        expect(result.salePriceWithProfit, 3920.0);
        expect(result.finalPriceWithVat, 4704.0);
      });

      test('should handle maximum discount combination', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [50.0, 30.0, 20.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 3000.0);
        
        // Cumulative discount: 50% + 30% + 20%
        // 3000 * 0.5 * 0.7 * 0.8 = 840
        expect(result.priceAfterDiscounts, 840.0);
        
        // Total discount rate should be 72%
        expect(result.totalDiscountRate, 72.0);
      });

      test('should handle zero exchange rate', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 0.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, 0.0);
        expect(result.priceAfterDiscounts, 0.0);
        expect(result.purchasePrice, 0.0);
        expect(result.purchasePriceWithTax, 0.0);
        expect(result.salePriceWithProfit, 0.0);
        expect(result.finalPriceWithVat, 0.0);
      });

      test('should handle fractional values correctly', () {
        final request = PriceCalculationRequest(
          originalPrice: 99.99,
          exchangeRate: 30.15,
          currency: 'USD',
          discountRates: [15.5, 0.0, 0.0],
          profitMargin: 35.5,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.convertedPrice, closeTo(3014.9985, 0.01));
        expect(result.priceAfterDiscounts, closeTo(2547.673175, 0.01));
        expect(result.totalDiscountRate, 15.5);
      });
    });

    group('Edge cases', () {
      test('should handle negative profit margin', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [0.0, 0.0, 0.0],
          profitMargin: -10.0,
        );

        final result = calculationService.calculatePrice(request);

        expect(result.salePriceWithProfit, 2160.0); // 2400 * 0.9 (negative 10% profit)
      });

      test('should handle discount rates over 100%', () {
        final request = PriceCalculationRequest(
          originalPrice: 100.0,
          exchangeRate: 30.0,
          currency: 'USD',
          discountRates: [120.0, 0.0, 0.0],
          profitMargin: 40.0,
        );

        final result = calculationService.calculatePrice(request);

        // This should result in negative values or be handled gracefully
        expect(result.priceAfterDiscounts, lessThan(0));
      });
    });
  });
}