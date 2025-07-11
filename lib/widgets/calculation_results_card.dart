import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/price_calculation_service.dart';

class CalculationResultsCard extends StatelessWidget {
  final PriceCalculationResult? result;
  final String? pinCode;
  final bool showPrices;
  final VoidCallback onTogglePriceVisibility;
  final VoidCallback onSaveRecord;
  final VoidCallback onShowRecords;

  const CalculationResultsCard({
    super.key,
    this.result,
    this.pinCode,
    required this.showPrices,
    required this.onTogglePriceVisibility,
    required this.onSaveRecord,
    required this.onShowRecords,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');

    if (result == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve aksiyonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.calculationResults,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: onSaveRecord,
                      tooltip: l10n.saveCalculationButton,
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: onShowRecords,
                      tooltip: l10n.calculationRecordsTooltip,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sonuçlar listesi
            Column(
              children: [
                _buildResultRow(
                  context,
                  l10n.convertedPrice,
                  result!.convertedPrice,
                  numberFormat,
                  isHighlighted: false,
                ),
                const SizedBox(height: 8),
                
                // Kümülatif iskonto oranı (her zaman görünür)
                if (result!.totalDiscountRate > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.totalDiscount,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        Text(
                          '%${result!.totalDiscountRate.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Detay fiyatları sadece PIN ile görüntülenir
                if (pinCode != null && showPrices) ...[
                  _buildResultRow(
                    context,
                    l10n.purchasePrice,
                    result!.purchasePrice,
                    numberFormat,
                    isHighlighted: true,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    l10n.purchasePriceWithTax,
                    result!.purchasePriceWithTax,
                    numberFormat,
                    isHighlighted: false,
                  ),
                  const SizedBox(height: 8),
                  _buildResultRow(
                    context,
                    l10n.salePrice,
                    result!.salePriceWithProfit,
                    numberFormat,
                    isHighlighted: true,
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Final fiyat (Satış + KDV) - her zaman görünür
                _buildResultRow(
                  context,
                  l10n.salePriceWithTax,
                  result!.finalPriceWithVat,
                  numberFormat,
                  isHighlighted: true,
                  isFinal: true,
                ),
              ],
            ),
            
            // PIN kodu gerektiren fiyatlar için gizlilik kontrolü
            if (pinCode != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.profitMarginDetails,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onTogglePriceVisibility,
                    icon: Icon(showPrices ? Icons.visibility_off : Icons.visibility),
                    label: Text(showPrices ? l10n.hide : l10n.show),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.enterPinToViewDetails,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    double value,
    NumberFormat numberFormat, {
    bool isHighlighted = false,
    bool isFinal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isFinal 
            ? Theme.of(context).colorScheme.primaryContainer
            : isHighlighted 
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
              color: isFinal 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
            ),
          ),
          Text(
            '${numberFormat.format(value)} ₺',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isFinal 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}