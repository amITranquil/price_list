import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/discount_preset.dart';
import '../utils/text_input_helpers.dart';

class PricingInputCard extends StatelessWidget {
  final TextEditingController priceController;
  final String selectedCurrency;
  final List<DiscountPreset> presets;
  final DiscountPreset? selectedPreset;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<DiscountPreset?> onPresetChanged;
  final TextEditingController? usdRateController;
  final TextEditingController? eurRateController;
  final TextEditingController? tlRateController;

  const PricingInputCard({
    super.key,
    required this.priceController,
    required this.selectedCurrency,
    required this.presets,
    required this.selectedPreset,
    required this.onCurrencyChanged,
    required this.onPresetChanged,
    this.usdRateController,
    this.eurRateController,
    this.tlRateController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.productPricing,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Orijinal fiyat girişi
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) => TextInputHelpers.handleCommaToDecimal(value, priceController),
              decoration: InputDecoration(
                labelText: l10n.originalPrice,
                hintText: l10n.enterPriceHelp,
                prefixText: _getCurrencySymbol(selectedCurrency),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 10),
            
            // Para birimi seçimi
            Row(
              children: [
                Text(
                  l10n.currency,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'USD',
                        label: Text('USD'),
                      ),
                      ButtonSegment<String>(
                        value: 'EUR',
                        label: Text('EUR'),
                      ),
                      ButtonSegment<String>(
                        value: 'TRY',
                        label: Text('TL'),
                      ),
                    ],
                    selected: {selectedCurrency},
                    onSelectionChanged: (Set<String> selection) {
                      onCurrencyChanged(selection.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Manuel kur girişi
            if (usdRateController != null && eurRateController != null && tlRateController != null) ...[
              Text(
                l10n.manualExchangeRates,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: usdRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) =>
                          TextInputHelpers.handleCommaToDecimal(
                              value, usdRateController!),
                      decoration: InputDecoration(
                        labelText: l10n.usdRateManual,
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: eurRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) =>
                          TextInputHelpers.handleCommaToDecimal(
                              value, eurRateController!),
                      decoration: InputDecoration(
                        labelText: l10n.eurRateManual,
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: tlRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) =>
                          TextInputHelpers.handleCommaToDecimal(
                              value, tlRateController!),
                      decoration: InputDecoration(
                        labelText: l10n.tryRateManual,
                        hintText: '1.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            
            // Preset seçimi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.savedPresets,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<DiscountPreset?>(
                  value: selectedPreset,
                  onChanged: onPresetChanged,
                  decoration: InputDecoration(
                    hintText: l10n.selectPreset,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  items: [
                    DropdownMenuItem<DiscountPreset?>(
                      value: null,
                      child: Text(l10n.manualInput),
                    ),
                    ...presets.map((preset) => DropdownMenuItem<DiscountPreset?>(
                      value: preset,
                      child: Text(preset.label),
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'TRY':
        return '₺ ';
      default:
        return '';
    }
  }
}