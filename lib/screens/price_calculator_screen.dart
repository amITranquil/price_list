import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/price_calculator_provider.dart';
import '../widgets/exchange_rate_card.dart';
import '../widgets/pricing_input_card.dart';
import '../widgets/discount_config_card.dart';
import '../widgets/calculation_results_card.dart';
import '../screens/calculation_records_screen.dart';
import '../screens/update_pin_page.dart';

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
      context.read<PriceCalculatorProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<PriceCalculatorProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'update_pin':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdatePinPage(),
                        ),
                      );
                      break;
                    case 'language':
                      _showLanguageDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (provider.authState.hasPinCode)
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Exchange Rate Card
                ExchangeRateCard(
                  exchangeRates: provider.exchangeRateState.exchangeRates,
                  isLoading: provider.exchangeRateState.isLoading,
                  onRefresh: () => provider.fetchExchangeRates(),
                ),
                const SizedBox(height: 16),
                
                // Pricing Input Card
                PricingInputCard(
                  priceController: provider.priceController,
                  selectedCurrency: provider.uiState.selectedCurrency,
                  presets: provider.presetState.presets,
                  selectedPreset: provider.presetState.selectedPreset,
                  onCurrencyChanged: provider.selectCurrency,
                  onPresetChanged: provider.selectPreset,
                ),
                const SizedBox(height: 16),
                
                // Discount Configuration Card
                DiscountConfigCard(
                  discount1Controller: provider.discount1Controller,
                  discount2Controller: provider.discount2Controller,
                  discount3Controller: provider.discount3Controller,
                  profitController: provider.profitController,
                  isExpanded: provider.uiState.isAdvancedExpanded,
                  onToggleExpanded: provider.toggleAdvancedExpanded,
                  onSavePreset: _showSavePresetDialog,
                  onDeletePreset: () => provider.deletePreset(context),
                  presets: provider.presetState.presets,
                  selectedPreset: provider.presetState.selectedPreset,
                ),
                const SizedBox(height: 16),
                
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
                const SizedBox(height: 16),
                
                // Calculation Results Card
                CalculationResultsCard(
                  result: provider.calculationState.result,
                  pinCode: provider.authState.hasPinCode ? 'exists' : null,
                  showPrices: provider.uiState.showPrices,
                  onTogglePriceVisibility: provider.togglePriceVisibility,
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
    final provider = context.read<PriceCalculatorProvider>();
    
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
    final provider = context.read<PriceCalculatorProvider>();
    
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
}