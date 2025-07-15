import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../core/architecture/clean_architecture_provider.dart';
import '../widgets/exchange_rate_card.dart';
import '../widgets/pricing_input_card.dart';
import '../widgets/discount_config_card.dart';
import '../widgets/calculation_results_card.dart';
import '../screens/calculation_records_screen.dart';
import '../screens/update_pin_page.dart';
import '../models/discount_preset.dart';

class PriceCalculatorScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChange;
  
  const PriceCalculatorScreen({super.key, this.onLanguageChange});

  @override
  State<PriceCalculatorScreen> createState() => _PriceCalculatorScreenState();
}

class _PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CleanArchitectureProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<CleanArchitectureProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _navigateToRecords,
                tooltip: l10n.calculationRecordsTooltip,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'update_pin':
                      if (provider.hasPinCode) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpdatePinPage(),
                          ),
                        );
                      }
                      break;
                    case 'language':
                      _showLanguageDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (provider.hasPinCode)
                    PopupMenuItem(
                      value: 'update_pin',
                      child: Row(
                        children: [
                          const Icon(Icons.lock),
                          const SizedBox(width: 8),
                          Text(l10n.updatePin),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'language',
                    child: Row(
                      children: [
                        const Icon(Icons.language),
                        const SizedBox(width: 8),
                        Text(l10n.language),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Exchange Rate Card
                ExchangeRateCard(
                  exchangeRates: provider.exchangeRates,
                  isLoading: provider.isLoading,
                  onRefresh: () => provider.fetchExchangeRates(),
                ),
                const SizedBox(height: 10),
                
                // Pricing Input Card
                PricingInputCard(
                  priceController: provider.priceController,
                  selectedCurrency: provider.selectedCurrency,
                  presets: provider.presets,
                  selectedPreset: provider.selectedPreset,
                  onCurrencyChanged: provider.selectCurrency,
                  onPresetChanged: provider.selectPreset,
                  usdRateController: provider.usdRateController,
                  eurRateController: provider.eurRateController,
                  tlRateController: provider.tlRateController,
                ),
                const SizedBox(height: 10),
                
                // Discount Configuration Card
                DiscountConfigCard(
                  discount1Controller: provider.discount1Controller,
                  discount2Controller: provider.discount2Controller,
                  discount3Controller: provider.discount3Controller,
                  profitController: provider.profitController,
                  isExpanded: provider.isAdvancedExpanded,
                  onToggleExpanded: provider.toggleAdvancedExpanded,
                  onSavePreset: _showSavePresetDialog,
                  onDeletePreset: () => provider.deletePreset(context),
                  onEditPreset: _showEditPresetDialog,
                  presets: provider.presets,
                  selectedPreset: provider.selectedPreset,
                  showProfitMargin: provider.showProfitMargin,
                  onToggleProfitVisibility: provider.toggleProfitMarginVisibility,
                ),
                const SizedBox(height: 10),
                
                // Calculate Button
                FilledButton(
                  onPressed: () => provider.calculatePrice(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    l10n.calculatePrice,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Calculation Results Card
                CalculationResultsCard(
                  result: provider.calculationResult,
                  pinCode: provider.hasPinCode ? 'exists' : null,
                  showPrices: provider.showPrices,
                  onTogglePriceVisibility: () => provider.promptPinAndToggleVisibility(context),
                  onSaveRecord: _showSaveRecordDialog,
                  onShowRecords: _navigateToRecords,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.turkish),
              onTap: () {
                widget.onLanguageChange?.call(const Locale('tr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.english),
              onTap: () {
                widget.onLanguageChange?.call(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSavePresetDialog() {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<CleanArchitectureProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveCurrentSettings),
        content: TextField(
          controller: provider.presetLabelController,
          decoration: InputDecoration(
            labelText: l10n.presetName,
            hintText: l10n.presetNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.savePreset(context);
              Navigator.pop(context);
            },
            child: Text(l10n.saveCurrentValues),
          ),
        ],
      ),
    );
  }

  void _showSaveRecordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<CleanArchitectureProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveCalculationTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: provider.productNameController,
              decoration: InputDecoration(
                labelText: l10n.productNameLabel,
                hintText: l10n.productNameHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: provider.notesController,
              decoration: InputDecoration(
                labelText: l10n.notesLabel,
                hintText: l10n.notesHint,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.saveCalculationRecord(context);
              Navigator.pop(context);
            },
            child: Text(l10n.saveCalculationButton),
          ),
        ],
      ),
    );
  }

  void _navigateToRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalculationRecordsScreen(),
      ),
    );
  }

  void _showEditPresetDialog(DiscountPreset preset) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<CleanArchitectureProvider>();
    
    // Mevcut preset değerlerini controller'lara yükle
    provider.presetLabelController.text = preset.label;
    provider.discount1Controller.text = preset.discounts.isNotEmpty ? preset.discounts[0].toString() : '0';
    provider.discount2Controller.text = preset.discounts.length > 1 ? preset.discounts[1].toString() : '0';
    provider.discount3Controller.text = preset.discounts.length > 2 ? preset.discounts[2].toString() : '0';
    provider.profitController.text = preset.profitMargin.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editPreset),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: provider.presetLabelController,
              decoration: InputDecoration(
                labelText: l10n.presetName,
                hintText: l10n.presetNameHint,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: provider.discount1Controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.discount1Percent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: provider.discount2Controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.discount2Percent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: provider.discount3Controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.discount3Percent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: provider.profitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.profitMarginPercent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Preset güncelle
              provider.updatePreset(context, preset);
              Navigator.pop(context);
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }
}