import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/import_export_service.dart';
import '../repositories/calculation_record_repository.dart';
import '../di/injection.dart';
import '../services/exchange_rate_service.dart';
import '../services/price_calculation_service.dart';
import '../utils/calculation_helper.dart';

class CalculationRecordsScreen extends StatefulWidget {
  const CalculationRecordsScreen({super.key});

  @override
  State<CalculationRecordsScreen> createState() => _CalculationRecordsScreenState();
}

class _CalculationRecordsScreenState extends State<CalculationRecordsScreen> {
  List<CalculationRecord> _records = [];
  List<CalculationRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Dependency injection ile aynı repository'i kullan
      final repository = getIt<CalculationRecordRepository>();
      final records = await repository.getCalculationRecords();
      setState(() {
        _records = records;
        _filteredRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recordsLoadError(e.toString()))),
        );
      }
    }
  }

  void _filterRecords() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _records;
      } else {
        _filteredRecords = _records.where((record) {
          return record.productName.toLowerCase().contains(query.toLowerCase()) ||
                 (record.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _deleteRecord(String id) async {
    try {
      final repository = getIt<CalculationRecordRepository>();
      await repository.deleteCalculationRecord(id);
      await _loadRecords();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recordDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteError(e.toString()))),
        );
      }
    }
  }

  void _showDeleteConfirmation(CalculationRecord record) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(l10n.deleteConfirmation(record.productName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord(record.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_records.isEmpty) {
      _showSnackBar(l10n.noDataToExport);
      return;
    }

    setState(() => _isExporting = true);

    try {
      final importExportService = getIt<ImportExportService>();
      final filePath = await importExportService.saveExportToFile(
        includeCalculationRecords: true,
        includeDiscountPresets: false,
      );

      _showSnackBar(l10n.fileSavedAt(filePath));
    } catch (e) {
      _showSnackBar(l10n.exportError(e.toString()));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.confirmImport),
            const SizedBox(height: 8),
            Text(
              l10n.importWillOverwrite,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.importData),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);

    try {
      final importExportService = getIt<ImportExportService>();
      final success = await importExportService.importFromFile();
      
      if (success) {
        _showSnackBar(l10n.importSuccess);
        await _loadRecords();
      } else {
        _showSnackBar(l10n.noFileSelected);
      }
    } catch (e) {
      _showSnackBar(l10n.importError(e.toString()));
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showEditDialog(CalculationRecord record) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController productNameController = TextEditingController(
      text: record.productName
    );
    final TextEditingController priceController = TextEditingController(
      text: record.originalPrice.toString()
    );
    final TextEditingController exchangeRateController = TextEditingController(
      text: record.exchangeRate.toString()
    );
    final TextEditingController discount1Controller = TextEditingController(
      text: record.discount1.toString()
    );
    final TextEditingController discount2Controller = TextEditingController(
      text: record.discount2.toString()
    );
    final TextEditingController discount3Controller = TextEditingController(
      text: record.discount3.toString()
    );
    final TextEditingController profitMarginController = TextEditingController(
      text: record.profitMargin.toString()
    );
    final TextEditingController notesController = TextEditingController(
      text: record.notes ?? ''
    );

    String selectedCurrency = record.currency;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.editPreset),
          content: SizedBox(
            width: MediaQuery.of(context).size.width > 1200 
                ? 600 
                : MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: productNameController,
                    decoration: InputDecoration(
                      labelText: l10n.productNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: l10n.originalPrice,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(l10n.currency),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCurrency,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                            DropdownMenuItem(value: 'TRY', child: Text('TRY')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCurrency = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: exchangeRateController,
                    decoration: InputDecoration(
                      labelText: l10n.usedRateDetail,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discount1Controller,
                          decoration: InputDecoration(
                            labelText: l10n.discount1,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: discount2Controller,
                          decoration: InputDecoration(
                            labelText: l10n.discount2,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discount3Controller,
                          decoration: InputDecoration(
                            labelText: l10n.discount3,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: profitMarginController,
                          decoration: InputDecoration(
                            labelText: l10n.profitMargin,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: l10n.notesLabel,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentContext = context;
                try {
                  final newProductName = productNameController.text.trim();
                  final newPrice = double.parse(priceController.text);
                  final newExchangeRate = double.parse(exchangeRateController.text);
                  final newDiscount1 = double.parse(discount1Controller.text);
                  final newDiscount2 = double.parse(discount2Controller.text);
                  final newDiscount3 = double.parse(discount3Controller.text);
                  final newProfitMargin = double.parse(profitMarginController.text);
                  
                  if (newProductName.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(currentContext).showSnackBar(
                        SnackBar(content: Text(l10n.productNameRequired)),
                      );
                    }
                    return;
                  }
                  
                  // Use CalculationHelper to create updated record with proper calculation
                  final updatedRecord = CalculationHelper.createRecordFromCalculation(
                    productName: newProductName,
                    originalPrice: newPrice,
                    exchangeRate: newExchangeRate,
                    currency: selectedCurrency,
                    discount1: newDiscount1,
                    discount2: newDiscount2,
                    discount3: newDiscount3,
                    profitMargin: newProfitMargin,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );
                  
                  // Keep original ID and creation date
                  final finalRecord = updatedRecord.copyWith(
                    id: record.id,
                    createdAt: record.createdAt,
                  );
                  
                  final repository = getIt<CalculationRecordRepository>();
                  await repository.updateCalculationRecord(finalRecord);
                  await _loadRecords();
                  
                  if (mounted) {
                    Navigator.pop(currentContext);
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(content: Text(l10n.priceUpdated)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(content: Text(l10n.updateError(e.toString()))),
                    );
                  }
                }
              },
              child: Text(l10n.update),
            ),
          ],
        ),
      ),
    );
  }

  void _showSimpleDetailDialog(CalculationRecord record) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width > 1200 
              ? 700 
              : MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.assessment, color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.productName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Calculation Steps
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Orijinal hesaplama adımlarını PriceCalculationService ile yapalım
                      Builder(
                        builder: (context) {
                          final priceCalculationService = getIt<PriceCalculationService>();
                          final discountRates = record.discounts;
                          
                          final request = PriceCalculationRequest(
                            originalPrice: record.originalPrice,
                            exchangeRate: record.exchangeRate,
                            currency: record.currency,
                            discountRates: discountRates,
                            profitMargin: 40.0,
                            vatRate: 20.0,
                          );
                          
                          final result = priceCalculationService.calculatePrice(request);
                          final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.red];
                          final icons = [_getCurrencyIcon(record.currency), Icons.percent, Icons.shopping_cart, Icons.local_offer, Icons.sell, Icons.price_check];
                          
                          return Column(
                            children: [
                              for (int i = 0; i < result.steps.length; i++) ...[
                                _buildCalculationStep(
                                  '${i + 1}. ${_getLocalizedStepDescription(result.steps[i].description, l10n, 40.0)}',
                                  result.steps[i].formula,
                                  icons[i % icons.length],
                                  colors[i % colors.length],
                                  isResult: i == result.steps.length - 1,
                                ),
                                if (i < result.steps.length - 1) const SizedBox(height: 16),
                              ],
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Current Rate Calculation
                      FutureBuilder<Map<String, double>?>(
                        future: _getCurrentRates(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final currentRate = record.currency == 'USD' 
                              ? (snapshot.data!['USD'] ?? record.exchangeRate)
                              : record.currency == 'EUR'
                                ? (snapshot.data!['EUR'] ?? record.exchangeRate)
                                : 1.0;
                            
                            // Tam hesaplama yapalım
                            final priceCalculationService = getIt<PriceCalculationService>();
                            final discountRates = record.discounts;
                            
                            final request = PriceCalculationRequest(
                              originalPrice: record.originalPrice,
                              exchangeRate: currentRate,
                              currency: record.currency,
                              discountRates: discountRates,
                              profitMargin: 40.0,
                              vatRate: 20.0,
                            );
                            
                            final result = priceCalculationService.calculatePrice(request);
                            final newPrice = result.finalPriceWithVat;
                            final priceDifference = newPrice - record.finalPrice;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.currentRateCalculationTitle,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildCurrentRateRow(
                                  record.currency == 'USD' 
                                    ? AppLocalizations.of(context)!.currentUsdRate
                                    : record.currency == 'EUR'
                                      ? AppLocalizations.of(context)!.currentEurRate
                                      : AppLocalizations.of(context)!.currentTryRate,
                                  record.currency == 'TRY' 
                                    ? '1.00 ₺'
                                    : '${numberFormat.format(currentRate)} ₺'
                                ),
                                _buildCurrentRateRow(AppLocalizations.of(context)!.newPrice, '${numberFormat.format(newPrice)} ₺'),
                                _buildCurrentRateRow(
                                  AppLocalizations.of(context)!.priceDifference, 
                                  '${priceDifference >= 0 ? '+' : ''}${numberFormat.format(priceDifference)} ₺',
                                  color: priceDifference >= 0 ? Colors.green : Colors.red,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _updateWithCurrentRate(record, currentRate);
                                    },
                                    icon: const Icon(Icons.update),
                                    label: Text(AppLocalizations.of(context)!.updateWithCurrentRate),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Additional Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                                const SizedBox(width: 8),
                                Text('${AppLocalizations.of(context)!.calculationDate}: ${dateFormat.format(record.createdAt)}'),
                              ],
                            ),
                            if (record.notes != null && record.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.note, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('${AppLocalizations.of(context)!.notes}: ${record.notes!}')),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(record);
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)!.editPreset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationStep(String title, String calculation, IconData icon, Color color, {bool isResult = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isResult ? 16 : 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  calculation,
                  style: TextStyle(
                    fontSize: isResult ? 18 : 14,
                    fontWeight: isResult ? FontWeight.bold : FontWeight.normal,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRateRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, double>?> _getCurrentRates() async {
    try {
      final exchangeRateService = getIt<ExchangeRateService>();
      final exchangeRates = await exchangeRateService.fetchRates();
      return {
        'USD': exchangeRates.usdRate ?? 0.0,
        'EUR': exchangeRates.eurRate ?? 0.0,
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _bulkUpdateWithCurrentRates() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_records.isEmpty) {
      _showSnackBar(l10n.noRecordsYet);
      return;
    }

    // Onay dialogu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.update} - ${l10n.calculationRecordsTitle}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.confirmImport} ${l10n.calculationRecordsTitle}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.importWillOverwrite} ${l10n.calculationRecordsTitle}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.calculationRecordsTitle}: ${_records.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.update),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Güncel kurları al
    final currentRates = await _getCurrentRates();
    if (currentRates == null) {
      _showSnackBar('Network connection failed');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = getIt<CalculationRecordRepository>();
      final now = DateTime.now();
      
      List<CalculationRecord> updatedRecords = [];
      
      for (final record in _records) {
        // Güncel kurları al
        final currentRate = record.currency == 'USD' 
          ? (currentRates['USD'] ?? record.exchangeRate)
          : record.currency == 'EUR'
            ? (currentRates['EUR'] ?? record.exchangeRate)
            : 1.0;
        
        // Use CalculationHelper for consistent calculation
        final updatedRecord = CalculationHelper.createRecordFromCalculation(
          productName: record.productName,
          originalPrice: record.originalPrice,
          exchangeRate: currentRate,
          currency: record.currency,
          discount1: record.discount1,
          discount2: record.discount2,
          discount3: record.discount3,
          profitMargin: record.profitMargin,
          notes: record.notes,
        );
        
        // Keep original ID and update creation date
        final finalRecord = updatedRecord.copyWith(
          id: record.id,
          createdAt: now,
        );
        
        updatedRecords.add(finalRecord);
      }
      
      // Tüm kayıtları güncelle
      for (final record in updatedRecords) {
        await repository.updateCalculationRecord(record);
      }
      
      await _loadRecords();
      
      if (mounted) {
        _showSnackBar('${updatedRecords.length} records updated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Update failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateWithCurrentRate(CalculationRecord record, double newRate) async {
    try {
      // PriceCalculationService kullanarak tam hesaplama yapalım
      // Use individual discount rates from record
      
      // Use CalculationHelper for consistent calculation
      final updatedRecord = CalculationHelper.createRecordFromCalculation(
        productName: record.productName,
        originalPrice: record.originalPrice,
        exchangeRate: newRate,
        currency: record.currency,
        discount1: record.discount1,
        discount2: record.discount2,
        discount3: record.discount3,
        profitMargin: record.profitMargin,
        notes: record.notes,
      );
      
      // Keep original ID 
      final finalRecord = updatedRecord.copyWith(
        id: record.id,
      );
      
      final repository = getIt<CalculationRecordRepository>();
      await repository.updateCalculationRecord(finalRecord);
      await _loadRecords();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recordUpdatedWithCurrentRate)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.updateErrorMessage}: ${e.toString()}')),
        );
      }
    }
  }

  IconData _getCurrencyIcon(String currency) {
    switch (currency) {
      case 'USD':
        return Icons.attach_money;
      case 'EUR':
        return Icons.euro;
      case 'TRY':
        return Icons.currency_lira;
      default:
        return Icons.monetization_on;
    }
  }

  String _getLocalizedStepDescription(String originalDescription, AppLocalizations l10n, double? profitMargin) {
    switch (originalDescription) {
      case 'Döviz Çevirimi':
        return l10n.currencyConversion;
      case 'Kümülatif İndirim':
        return l10n.cumulativeDiscount;
      case 'Alış Fiyatı':
        return l10n.purchasePriceCalc;
      case 'Alış + KDV':
        return l10n.purchasePriceWithTax;
      case 'Final Fiyat (KDV Dahil)':
        return l10n.finalPriceVat;
      default:
        // Satış Fiyatı için profit margin ile dinamik string
        if (originalDescription.contains('Satış Fiyatı')) {
          return '${l10n.salePrice} (+%${profitMargin?.toStringAsFixed(0) ?? '40'} kar)';
        }
        return originalDescription;
    }
  }

  Widget _buildDesktopRecordCard(CalculationRecord record, AppLocalizations l10n, 
      DateFormat dateFormat, NumberFormat numberFormat) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product name and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.productName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(record.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      onPressed: () => _showSimpleDetailDialog(record),
                      tooltip: l10n.show,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () => _showDeleteConfirmation(record),
                      tooltip: l10n.delete,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Price information in responsive grid layout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // For very wide cards (3-column grid), use a 2x2 grid
                  if (constraints.maxWidth > 300) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactInfoTile(
                                _getCurrencyIcon(record.currency),
                                l10n.originalPriceDetail,
                                '${numberFormat.format(record.originalPrice)} ${record.currency}',
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCompactInfoTile(
                                Icons.trending_up,
                                l10n.usedRateDetail,
                                numberFormat.format(record.exchangeRate),
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCompactInfoTile(
                                Icons.percent,
                                l10n.cumulativeDiscountDetail,
                                '%${numberFormat.format(CalculationHelper.getCumulativeDiscountRateFromRecord(record))}',
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCompactInfoTile(
                                Icons.price_change,
                                l10n.calculatedPriceDetail,
                                '${numberFormat.format(record.finalPrice)} ₺',
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // For narrower cards, use vertical layout
                    return Column(
                      children: [
                        _buildCompactInfoTile(
                          _getCurrencyIcon(record.currency),
                          l10n.originalPriceDetail,
                          '${numberFormat.format(record.originalPrice)} ${record.currency}',
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildCompactInfoTile(
                          Icons.price_change,
                          l10n.calculatedPriceDetail,
                          '${numberFormat.format(record.finalPrice)} ₺',
                          Colors.red,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            
            // Footer with notes if present
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.note, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileRecordCard(CalculationRecord record, AppLocalizations l10n,
      DateFormat dateFormat, NumberFormat numberFormat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showSimpleDetailDialog(record),
                      tooltip: l10n.show,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showDeleteConfirmation(record),
                      tooltip: l10n.delete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Price info
            Row(
              children: [
                Icon(_getCurrencyIcon(record.currency), size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${numberFormat.format(record.originalPrice)} ${record.currency} → ${numberFormat.format(record.finalPrice)} ₺',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.percent, size: 18, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text('${l10n.cumulativeDiscountDetail}: %${numberFormat.format(CalculationHelper.getCumulativeDiscountRateFromRecord(record))}'),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                const SizedBox(width: 8),
                Text(dateFormat.format(record.createdAt)),
              ],
            ),
            
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildCompactInfoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculationRecordsTitle),
        elevation: 0,
        actions: [
          if (_records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _bulkUpdateWithCurrentRates,
              tooltip: '${l10n.update} - ${l10n.refreshRates}',
            ),
          
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: _exportData,
              tooltip: l10n.exportData,
            ),
          
          if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _importData,
              tooltip: l10n.importData,
            ),
        ],
      ),
      body: Column(
        children: [
          // Arama kutusu
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          
          // Kayıtlar listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty 
                                  ? l10n.noRecordsYet 
                                  : l10n.noSearchResults,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive grid layout for different screen sizes
                          if (constraints.maxWidth > 1800) {
                            // Ultra-wide screens (>1800px) - 4 columns
                            return GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 1.6, // Optimized for 4-column layout
                              ),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return _buildDesktopRecordCard(record, l10n, dateFormat, numberFormat);
                              },
                            );
                          } else if (constraints.maxWidth > 1200) {
                            // Wide screens (Windows maximized 1920x1080) - 3 columns
                            return GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 1.8, // Optimized for Windows maximized screens
                              ),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return _buildDesktopRecordCard(record, l10n, dateFormat, numberFormat);
                              },
                            );
                          } else if (constraints.maxWidth > 800) {
                            // MacBook maximized and medium screens - 2 columns with optimal spacing
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.5, // Optimized for MacBook maximized screens
                              ),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return _buildDesktopRecordCard(record, l10n, dateFormat, numberFormat);
                              },
                            );
                          } else if (constraints.maxWidth > 600) {
                            // Tablet-sized screens - single column with card layout
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildDesktopRecordCard(record, l10n, dateFormat, numberFormat),
                                );
                              },
                            );
                          } else {
                            // Mobile screens - compact list layout
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return _buildMobileRecordCard(record, l10n, dateFormat, numberFormat);
                              },
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}