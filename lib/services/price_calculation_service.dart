class PriceCalculationRequest {
  final double originalPrice;
  final double exchangeRate;
  final String currency;
  final List<double> discountRates;
  final double profitMargin;
  final double vatRate;

  PriceCalculationRequest({
    required this.originalPrice,
    required this.exchangeRate,
    required this.currency,
    required this.discountRates,
    this.profitMargin = 40.0, // Default %40 kar marjı
    this.vatRate = 20.0, // Default %20 KDV
  });
}

class PriceCalculationResult {
  final double convertedPrice;
  final double priceAfterDiscounts;
  final double purchasePrice;
  final double purchasePriceWithTax;
  final double salePriceWithProfit;
  final double finalPriceWithVat;
  final double totalDiscountRate;
  final List<CalculationStep> steps;

  PriceCalculationResult({
    required this.convertedPrice,
    required this.priceAfterDiscounts,
    required this.purchasePrice,
    required this.purchasePriceWithTax,
    required this.salePriceWithProfit,
    required this.finalPriceWithVat,
    required this.totalDiscountRate,
    required this.steps,
  });
}

class CalculationStep {
  final String description;
  final double value;
  final String formula;

  CalculationStep({
    required this.description,
    required this.value,
    required this.formula,
  });
}

abstract class PriceCalculationService {
  PriceCalculationResult calculatePrice(PriceCalculationRequest request);
}

class StandardPriceCalculationService implements PriceCalculationService {
  @override
  PriceCalculationResult calculatePrice(PriceCalculationRequest request) {
    final steps = <CalculationStep>[];
    
    // 1. Döviz çevirimi
    final convertedPrice = request.originalPrice * request.exchangeRate;
    steps.add(CalculationStep(
      description: 'Döviz Çevirimi',
      value: convertedPrice,
      formula: '${request.originalPrice} ${request.currency} × ${request.exchangeRate} = ${convertedPrice.toStringAsFixed(2)} ₺',
    ));

    // 2. Kümülatif indirim hesaplama
    final totalDiscountRate = _calculateCumulativeDiscount(request.discountRates);
    final priceAfterDiscounts = request.originalPrice * (1 - totalDiscountRate / 100);
    steps.add(CalculationStep(
      description: 'Kümülatif İndirim',
      value: priceAfterDiscounts,
      formula: '${request.originalPrice} ${request.currency} × (1 - %${totalDiscountRate.toStringAsFixed(2)}) = ${priceAfterDiscounts.toStringAsFixed(2)} ${request.currency}',
    ));

    // 3. İndirimli fiyatın TL karşılığı (alış fiyatı)
    final purchasePrice = priceAfterDiscounts * request.exchangeRate;
    steps.add(CalculationStep(
      description: 'Alış Fiyatı',
      value: purchasePrice,
      formula: '${priceAfterDiscounts.toStringAsFixed(2)} ${request.currency} × ${request.exchangeRate} = ${purchasePrice.toStringAsFixed(2)} ₺',
    ));

    // 4. Alış fiyatı + KDV
    final purchasePriceWithTax = purchasePrice * (1 + request.vatRate / 100);
    steps.add(CalculationStep(
      description: 'Alış + KDV',
      value: purchasePriceWithTax,
      formula: '${purchasePrice.toStringAsFixed(2)} ₺ × (1 + %${request.vatRate}) = ${purchasePriceWithTax.toStringAsFixed(2)} ₺',
    ));

    // 5. Satış fiyatı (alış fiyatı + kar marjı)
    final salePriceWithProfit = purchasePrice * (1 + request.profitMargin / 100);
    steps.add(CalculationStep(
      description: 'Satış Fiyatı (+%${request.profitMargin} kar)',
      value: salePriceWithProfit,
      formula: '${purchasePrice.toStringAsFixed(2)} ₺ × (1 + %${request.profitMargin}) = ${salePriceWithProfit.toStringAsFixed(2)} ₺',
    ));

    // 6. Final fiyat (satış fiyatı + KDV)
    final finalPriceWithVat = salePriceWithProfit * (1 + request.vatRate / 100);
    steps.add(CalculationStep(
      description: 'Final Fiyat (KDV Dahil)',
      value: finalPriceWithVat,
      formula: '${salePriceWithProfit.toStringAsFixed(2)} ₺ × (1 + %${request.vatRate}) = ${finalPriceWithVat.toStringAsFixed(2)} ₺',
    ));

    return PriceCalculationResult(
      convertedPrice: convertedPrice,
      priceAfterDiscounts: priceAfterDiscounts,
      purchasePrice: purchasePrice,
      purchasePriceWithTax: purchasePriceWithTax,
      salePriceWithProfit: salePriceWithProfit,
      finalPriceWithVat: finalPriceWithVat,
      totalDiscountRate: totalDiscountRate,
      steps: steps,
    );
  }

  double _calculateCumulativeDiscount(List<double> discountRates) {
    double cumulativeDiscount = 0;
    double currentPrice = 100; // Başlangıç fiyatı olarak 100 alıyoruz

    for (final discountRate in discountRates) {
      if (discountRate > 0) {
        final discountAmount = currentPrice * (discountRate / 100);
        currentPrice -= discountAmount;
        cumulativeDiscount += discountAmount;
      }
    }

    return cumulativeDiscount; // Toplam indirim yüzdesi
  }
}