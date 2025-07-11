import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/discount_preset.dart';

class PricingInputCard extends StatelessWidget {
  final TextEditingController priceController;
  final String selectedCurrency;
  final List<DiscountPreset> presets;
  final DiscountPreset? selectedPreset;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<DiscountPreset?> onPresetChanged;

  const PricingInputCard({
    super.key,
    required this.priceController,
    required this.selectedCurrency,
    required this.presets,
    required this.selectedPreset,
    required this.onCurrencyChanged,
    required this.onPresetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.productPricing,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Orijinal fiyat girişi
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.originalPrice,
                hintText: l10n.enterPriceHelp,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),
            
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
                    ],
                    selected: {selectedCurrency},
                    onSelectionChanged: (Set<String> selection) {
                      onCurrencyChanged(selection.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
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
                const SizedBox(height: 8),
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
}