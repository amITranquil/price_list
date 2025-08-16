import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:price_list/utils/text_input_helpers.dart';
import '../models/discount_preset.dart';

class DiscountConfigCard extends StatelessWidget {
  final TextEditingController discount1Controller;
  final TextEditingController discount2Controller;
  final TextEditingController discount3Controller;
  final TextEditingController profitController;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onSavePreset;
  final VoidCallback onDeletePreset;
  final ValueChanged<DiscountPreset> onEditPreset;
  final List<DiscountPreset> presets;
  final DiscountPreset? selectedPreset;
  final bool showProfitMargin;
  final VoidCallback onToggleProfitVisibility;

  const DiscountConfigCard({
    super.key,
    required this.discount1Controller,
    required this.discount2Controller,
    required this.discount3Controller,
    required this.profitController,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onSavePreset,
    required this.onDeletePreset,
    required this.onEditPreset,
    required this.presets,
    required this.selectedPreset,
    required this.showProfitMargin,
    required this.onToggleProfitVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        children: [
          // Başlık ve genişletme düğmesi
          ListTile(
            title: Text(
              l10n.discountsAndProfit,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: isExpanded 
                ? null 
                : Text(
                    l10n.tapToConfigureDiscounts,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: onToggleExpanded,
            ),
          ),
          
          // Genişletilmiş içerik
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İndirim alanları
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discount1Controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) => TextInputHelpers.handleCommaToDecimal(value, discount1Controller),
                          decoration: InputDecoration(
                            labelText: l10n.discount1,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: discount2Controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) =>
                              TextInputHelpers.handleCommaToDecimal(
                                  value, discount2Controller),
                          decoration: InputDecoration(
                            labelText: l10n.discount2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discount3Controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) =>
                              TextInputHelpers.handleCommaToDecimal(
                                  value, discount3Controller),
                          decoration: InputDecoration(
                            labelText: l10n.discount3,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: profitController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) =>
                              TextInputHelpers.handleCommaToDecimal(
                                  value, profitController),
                          obscureText: !showProfitMargin,
                          decoration: InputDecoration(
                            labelText: l10n.profitMargin,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            suffixIcon: IconButton(
                              icon: Icon(
                                showProfitMargin ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: onToggleProfitVisibility,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Preset yönetimi düğmeleri
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: selectedPreset == null ? onSavePreset : null,
                          icon: const Icon(Icons.save),
                          label: Text(l10n.saveCurrentValues),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: selectedPreset == null 
                                ? null 
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (selectedPreset != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onEditPreset(selectedPreset!),
                            icon: const Icon(Icons.edit),
                            label: Text(l10n.editPreset),
                          ),
                        ),
                      const SizedBox(width: 6),
                      if (selectedPreset != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onDeletePreset,
                            icon: const Icon(Icons.delete),
                            label: Text(l10n.deleteSelected),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}