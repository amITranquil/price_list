import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart';
import '/utils/database_helper.dart';
import 'create_pin_page.dart';
import 'update_pin_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Currency { usd, eur, tl }

class PriceCalculatorScreen extends StatefulWidget {
  final Function(Locale)? onLanguageChange;
  
  const PriceCalculatorScreen({super.key, this.onLanguageChange});

  @override
  PriceCalculatorScreenState createState() => PriceCalculatorScreenState();
}

class PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController1 = TextEditingController();
  final TextEditingController _discountController2 = TextEditingController();
  final TextEditingController _discountController3 = TextEditingController();
  final TextEditingController _profitMarginController = TextEditingController();
  final TextEditingController _usdExchangeRateController = TextEditingController();
  final TextEditingController _eurExchangeRateController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _presetLabelController = TextEditingController();

  List<DiscountPreset> _savedPresets = [];
  DiscountPreset? _selectedPreset;
  Currency _selectedCurrency = Currency.usd;

  String _priceConvert = '';
  String _priceBought = '';
  String _kdvPrice = '';
  String _priceWithProfit = '';
  String _priceBoughtTax = '';
  String _usdRate = '';
  String _eurRate = '';
  String _usedExchangeRate = '';

  bool _isPriceBoughtVisible = false;
  bool _isProfitMarginVisible = false;
  bool _isLoadingRates = false;
  bool _isCalculating = false;
  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _fetchRates();
    _loadPresets();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _discountController1.text = '45';
    _discountController2.text = '10';
    _discountController3.text = '0';
    _profitMarginController.text = '40';
  }

  Future<void> _loadPresets() async {
    final presets = await DatabaseHelper().getDiscountPresets();
    setState(() {
      _savedPresets = presets;
    });
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoadingRates = true;
    });

    const url = 'https://urlateknik.com/kresmak/isbank.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Document document = parse(response.body);

        String usdRate = '';
        String eurRate = '';

        var textContent = document.body?.text;
        if (textContent != null) {
          var usdIndex = textContent.indexOf('USD Satış Kuru:');
          if (usdIndex != -1) {
            var usdStart = textContent.substring(usdIndex);
            var usdEndIndex = usdStart.indexOf('EUR Satış Kuru:');
            if (usdEndIndex != -1) {
              usdRate = usdStart.substring(0, usdEndIndex).split(': ')[1].trim();
            } else {
              usdRate = usdStart.split(': ')[1].split('<br>')[0].trim();
            }
          }

          var eurIndex = textContent.indexOf('EUR Satış Kuru:');
          if (eurIndex != -1) {
            var eurStart = textContent.substring(eurIndex);
            eurRate = eurStart.split(': ')[1].trim();
          }
        }

        setState(() {
          final l10n = AppLocalizations.of(context)!;
          _usdRate = usdRate.isNotEmpty ? usdRate : l10n.dataUnavailable;
          _eurRate = eurRate.isNotEmpty ? eurRate : l10n.dataUnavailable;
          _usdExchangeRateController.text = _usdRate.replaceAll(',', '.');
          _eurExchangeRateController.text = _eurRate.replaceAll(',', '.');
          _isLoadingRates = false;
        });
      } else {
        setState(() {
          final l10n = AppLocalizations.of(context)!;
          _usdRate = l10n.dataUnavailable;
          _eurRate = l10n.dataUnavailable;
          _isLoadingRates = false;
        });
      }
    } catch (e) {
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _usdRate = l10n.dataUnavailable;
        _eurRate = l10n.dataUnavailable;
        _isLoadingRates = false;
      });
    }
  }

  Future<void> _togglePriceBoughtVisibility() async {
    final inputPin = _pinController.text;
    final storedPin = await DatabaseHelper().getPinCode();

    if (inputPin == storedPin) {
      setState(() {
        _isPriceBoughtVisible = !_isPriceBoughtVisible;
      });
    } else if (storedPin == null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePinPage(onLanguageChange: widget.onLanguageChange)),
      );
    } else {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.incorrectPin, isError: true);
    }
  }

  Future<void> _navigateToUpdatePinPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdatePinPage()),
    );
  }

  void _toggleProfitMarginVisibility() {
    setState(() {
      _isProfitMarginVisible = !_isProfitMarginVisible;
    });
  }

  Future<void> _saveCurrentAsPreset() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_presetLabelController.text.isEmpty) {
      _showSnackBar(l10n.presetLabelEmpty, isError: true);
      return;
    }

    try {
      final discounts = [
        double.parse(_discountController1.text.replaceAll(',', '.')),
        double.parse(_discountController2.text.replaceAll(',', '.')),
        double.parse(_discountController3.text.replaceAll(',', '.')),
      ];

      final profitMargin = double.parse(_profitMarginController.text.replaceAll(',', '.'));

      final preset = DiscountPreset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: _presetLabelController.text,
        discounts: discounts,
        profitMargin: profitMargin,
      );

      await DatabaseHelper().saveDiscountPreset(preset);
      await _loadPresets();
      _presetLabelController.clear();
      
      if (mounted) {
        _showSnackBar(l10n.presetSaved);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.errorSavingPreset, isError: true);
      }
    }
  }

  void _applyPreset(DiscountPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _discountController1.text = preset.discounts.isNotEmpty ? preset.discounts[0].toString() : '0';
      _discountController2.text = preset.discounts.length > 1 ? preset.discounts[1].toString() : '0';
      _discountController3.text = preset.discounts.length > 2 ? preset.discounts[2].toString() : '0';
      _profitMarginController.text = preset.profitMargin.toString();
    });
  }

  Future<void> _deletePreset(DiscountPreset preset) async {
    await DatabaseHelper().deleteDiscountPreset(preset.id);
    await _loadPresets();
    
    if (_selectedPreset?.id == preset.id) {
      setState(() {
        _selectedPreset = null;
      });
    }
    
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      _showSnackBar(l10n.presetDeleted);
    }
  }

  Future<void> _calculateFinalPrice() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_priceController.text.isEmpty) {
      _showSnackBar(l10n.originalPriceEmpty, isError: true);
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      final double originalPrice = double.parse(_priceController.text.replaceAll(',', '.'));
      final double exchangeRate = _selectedCurrency == Currency.usd 
          ? double.parse(_usdExchangeRateController.text.replaceAll(',', '.'))
          : _selectedCurrency == Currency.eur
          ? double.parse(_eurExchangeRateController.text.replaceAll(',', '.'))
          : 1.0;

      final double priceConvert = originalPrice * exchangeRate;

      final double discount1 = double.parse(_discountController1.text.replaceAll(',', '.')) / 100;
      final double discount2 = double.parse(_discountController2.text.replaceAll(',', '.')) / 100;
      final double discount3 = double.parse(_discountController3.text.replaceAll(',', '.')) / 100;
      final double profitMargin = double.parse(_profitMarginController.text.replaceAll(',', '.')) / 100;

      final double discountedPrice1 = originalPrice * (1 - discount1);
      final double discountedPrice2 = discountedPrice1 * (1 - discount2);
      final double discountedPrice3 = discountedPrice2 * (1 - discount3);
      final double priceBought = discountedPrice3 * exchangeRate;

      final double priceBoughtTax = priceBought * 1.2;
      final double priceWithProfit = priceBought * (1 + profitMargin);
      final double kdvPrice = priceWithProfit * 1.2;

      setState(() {
        _priceConvert = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(priceConvert);
        _priceBought = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(priceBought);
        _priceBoughtTax = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(priceBoughtTax);
        _priceWithProfit = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(priceWithProfit);
        _kdvPrice = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(kdvPrice);
        _usedExchangeRate = _selectedCurrency == Currency.usd ? 'USD \$' 
            : _selectedCurrency == Currency.eur ? 'EUR €' : 'TL ₺';
        _isCalculating = false;
      });

      // Hide keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      if (mounted) {
        _showSnackBar(l10n.errorCalculation, isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onSelected: (String value) {
              if (widget.onLanguageChange != null) {
                widget.onLanguageChange!(Locale(value));
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'tr',
                child: Row(
                  children: [
                    const Icon(Icons.flag),
                    const SizedBox(width: 8),
                    Text(l10n.turkish),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    const Icon(Icons.flag),
                    const SizedBox(width: 8),
                    Text(l10n.english),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToUpdatePinPage,
            tooltip: l10n.updatePin,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildExchangeRatesCard(),
            const SizedBox(height: 16),
            _buildPricingInputCard(),
            const SizedBox(height: 16),
            _buildAdvancedOptionsCard(),
            const SizedBox(height: 16),
            _buildCalculateButton(),
            const SizedBox(height: 16),
            if (_kdvPrice.isNotEmpty) _buildResultsCard(),
            const SizedBox(height: 16),
            _buildPresetManagementCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRatesCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.currency_exchange, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.exchangeRates,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_isLoadingRates) 
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchRates,
                    tooltip: l10n.refreshRates,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _usdExchangeRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.usdRate,
                      prefixIcon: const Icon(Icons.attach_money),
                      border: const OutlineInputBorder(),
                      helperText: _isLoadingRates ? l10n.loading : l10n.bankSellingRate,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _eurExchangeRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.eurRate,
                      prefixIcon: const Icon(Icons.euro),
                      border: const OutlineInputBorder(),
                      helperText: _isLoadingRates ? l10n.loading : l10n.bankSellingRate,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingInputCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.productPricing,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.originalPrice,
                prefixIcon: Icon(_selectedCurrency == Currency.usd 
                    ? Icons.attach_money 
                    : _selectedCurrency == Currency.eur 
                    ? Icons.euro 
                    : Icons.currency_lira),
                border: const OutlineInputBorder(),
                helperText: l10n.enterPriceHelp,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  l10n.currency,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<Currency>(
                    segments: const [
                      ButtonSegment(
                        value: Currency.usd,
                        label: Text('USD'),
                        icon: Icon(Icons.attach_money),
                      ),
                      ButtonSegment(
                        value: Currency.eur,
                        label: Text('EUR'),
                        icon: Icon(Icons.euro),
                      ),
                      ButtonSegment(
                        value: Currency.tl,
                        label: Text('TL'),
                        icon: Icon(Icons.currency_lira),
                      ),
                    ],
                    selected: {_selectedCurrency},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedCurrency = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_savedPresets.isNotEmpty) ...[
              DropdownButtonFormField<DiscountPreset>(
                value: _selectedPreset,
                decoration: InputDecoration(
                  labelText: l10n.savedPresets,
                  prefixIcon: const Icon(Icons.bookmark),
                  border: const OutlineInputBorder(),
                ),
                hint: Text(l10n.selectPreset),
                isExpanded: true,
                items: [
                  DropdownMenuItem<DiscountPreset>(
                    value: null,
                    child: Text(l10n.manualInput),
                  ),
                  ..._savedPresets.map((preset) => DropdownMenuItem<DiscountPreset>(
                    value: preset,
                    child: Text('${preset.label} (${preset.discounts.join('-')}%)'),
                  )),
                ],
                onChanged: (preset) {
                  if (preset != null) {
                    _applyPreset(preset);
                  } else {
                    setState(() {
                      _selectedPreset = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptionsCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.discountsAndProfit,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_showAdvancedOptions ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _showAdvancedOptions = !_showAdvancedOptions;
                    });
                  },
                ),
              ],
            ),
            if (_showAdvancedOptions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountController1,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.discount1,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_offer),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController2,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.discount2,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_offer),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController3,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.discount3,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_offer),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _profitMarginController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      obscureText: !_isProfitMarginVisible,
                      decoration: InputDecoration(
                        labelText: l10n.profitMargin,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.trending_up),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isProfitMarginVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _toggleProfitMarginVisibility,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                l10n.tapToConfigureDiscounts,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    final l10n = AppLocalizations.of(context)!;
    
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isCalculating ? null : _calculateFinalPrice,
        icon: _isCalculating 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.calculate),
        label: Text(_isCalculating ? l10n.calculating : l10n.calculatePrice),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.calculationResults,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_priceController.text.isNotEmpty) ...[
              _buildResultRow(
                l10n.convertedPrice, 
                '$_usedExchangeRate → $_priceConvert',
                icon: Icons.currency_exchange,
              ),
              const Divider(),
            ],
            if (_isPriceBoughtVisible && _priceBought.isNotEmpty) ...[
              _buildResultRow(
                l10n.purchasePrice, 
                _priceBought,
                icon: Icons.shopping_cart,
                isConfidential: true,
              ),
              _buildResultRow(
                l10n.purchaseTax, 
                _priceBoughtTax,
                icon: Icons.receipt,
                isConfidential: true,
              ),
              const Divider(),
            ],
            _buildResultRow(
              l10n.salePrice, 
              _priceWithProfit,
              icon: Icons.sell,
              isHighlight: true,
            ),
            _buildResultRow(
              l10n.finalPriceVat, 
              _kdvPrice,
              icon: Icons.price_check,
              isHighlight: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.pinCode,
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      helperText: l10n.enterPinHelp,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _togglePriceBoughtVisibility,
                  child: Text(_isPriceBoughtVisible ? l10n.hide : l10n.show),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {
    required IconData icon,
    bool isHighlight = false,
    bool isConfidential = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlight 
                ? Theme.of(context).colorScheme.primary
                : isConfidential
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isHighlight ? FontWeight.w600 : null,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight 
                  ? Theme.of(context).colorScheme.primary
                  : isConfidential
                      ? Theme.of(context).colorScheme.error
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetManagementCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark_add, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.saveCurrentSettings,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _presetLabelController,
              decoration: InputDecoration(
                labelText: l10n.presetName,
                hintText: l10n.presetNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _saveCurrentAsPreset,
                    child: Text(l10n.saveCurrentValues),
                  ),
                ),
                if (_selectedPreset != null) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _deletePreset(_selectedPreset!),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    child: Text(l10n.deleteSelected),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}