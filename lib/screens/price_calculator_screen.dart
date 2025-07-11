import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controllers/price_calculator_controller.dart';
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
  late PriceCalculatorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PriceCalculatorController();
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              if (_controller.pinCode != null)
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
              exchangeRates: _controller.exchangeRates,
              isLoading: _controller.isLoadingRates,
              onRefresh: () => _controller.fetchExchangeRates(),
            ),
            const SizedBox(height: 16),
            
            // Pricing Input Card
            PricingInputCard(
              priceController: _controller.priceController,
              selectedCurrency: _controller.selectedCurrency,
              presets: _controller.presets,
              selectedPreset: _controller.selectedPreset,
              onCurrencyChanged: _controller.selectCurrency,
              onPresetChanged: _controller.selectPreset,
            ),
            const SizedBox(height: 16),
            
            // Discount Configuration Card
            DiscountConfigCard(
              discount1Controller: _controller.discount1Controller,
              discount2Controller: _controller.discount2Controller,
              discount3Controller: _controller.discount3Controller,
              profitController: _controller.profitController,
              isExpanded: _controller.isAdvancedExpanded,
              onToggleExpanded: _controller.toggleAdvancedExpanded,
              onSavePreset: _showSavePresetDialog,
              onDeletePreset: _controller.deletePreset,
              presets: _controller.presets,
              selectedPreset: _controller.selectedPreset,
            ),
            const SizedBox(height: 16),
            
            // Calculate Button
            FilledButton(
              onPressed: _controller.calculatePrice,
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
              result: _controller.calculationResult,
              pinCode: _controller.pinCode,
              showPrices: _controller.showPrices,
              onTogglePriceVisibility: _controller.togglePriceVisibility,
              onSaveRecord: _showSaveRecordDialog,
              onShowRecords: _navigateToRecords,
            ),
          ],
        ),
      ),
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveCurrentSettings),
        content: TextField(
          controller: _controller.presetLabelController,
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
              _controller.savePreset();
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveCalculationTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller.productNameController,
              decoration: InputDecoration(
                labelText: l10n.productNameLabel,
                hintText: l10n.productNameHint,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.notesController,
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
              _controller.saveCalculationRecord();
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