import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/import_export_service.dart';
import '../repositories/calculation_record_repository.dart';
import '../di/injection.dart';
import '../services/exchange_rate_service.dart';
import '../services/price_calculation_service.dart';

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
    final TextEditingController priceController = TextEditingController(
      text: record.originalPrice.toString()
    );
    final TextEditingController notesController = TextEditingController(
      text: record.notes ?? ''
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editOriginalPrice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: l10n.originalPrice,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newPrice = double.parse(priceController.text);
                final updatedRecord = CalculationRecord(
                  id: record.id,
                  productName: record.productName,
                  originalPrice: newPrice,
                  exchangeRate: record.exchangeRate,
                  discountRate: record.discountRate,
                  finalPrice: record.finalPrice,
                  createdAt: record.createdAt,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                  currency: record.currency,
                );
                
                final repository = getIt<CalculationRecordRepository>();
                await repository.updateCalculationRecord(updatedRecord);
                await _loadRecords();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.priceUpdated)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.updateError(e.toString()))),
                  );
                }
              }
            },
            child: Text(l10n.update),
          ),
        ],
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
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 600,
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
                          final discountRates = record.discountRate > 0 ? [record.discountRate] : <double>[];
                          
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
                            final discountRates = record.discountRate > 0 ? [record.discountRate] : <double>[];
                            
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

  Future<void> _updateWithCurrentRate(CalculationRecord record, double newRate) async {
    try {
      // PriceCalculationService kullanarak tam hesaplama yapalım
      final priceCalculationService = getIt<PriceCalculationService>();
      
      // Eski hesaplamadan discount rates'i çıkarmaya çalışalım
      // record.discountRate toplam indirim, bunu individual rates'e çevirmemiz gerekiyor
      // Basit yaklaşım: tek bir indirim olarak kabul edelim
      final discountRates = record.discountRate > 0 ? [record.discountRate] : <double>[];
      
      final request = PriceCalculationRequest(
        originalPrice: record.originalPrice,
        exchangeRate: newRate,
        currency: record.currency,
        discountRates: discountRates,
        profitMargin: 40.0, // Default kar marjı
        vatRate: 20.0, // Default KDV
      );
      
      final result = priceCalculationService.calculatePrice(request);
      
      final updatedRecord = CalculationRecord(
        id: record.id,
        productName: record.productName,
        originalPrice: record.originalPrice,
        exchangeRate: newRate,
        discountRate: record.discountRate, // Aynı indirim oranını koru
        finalPrice: result.finalPriceWithVat, // Tam hesaplanmış final fiyat
        createdAt: DateTime.now(), // Güncelleme tarihi
        notes: record.notes,
        currency: record.currency,
      );
      
      final repository = getIt<CalculationRecordRepository>();
      await repository.updateCalculationRecord(updatedRecord);
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
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.productName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () => _showSimpleDetailDialog(record),
                      tooltip: l10n.show,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _showDeleteConfirmation(record),
                      tooltip: l10n.delete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Price information in grid layout
            Expanded(
              child: Row(
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoTile(
                          _getCurrencyIcon(record.currency),
                          l10n.originalPriceDetail,
                          '${numberFormat.format(record.originalPrice)} ${record.currency}',
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoTile(
                          Icons.percent,
                          l10n.cumulativeDiscountDetail,
                          '%${numberFormat.format(record.discountRate)}',
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoTile(
                          Icons.trending_up,
                          l10n.usedRateDetail,
                          numberFormat.format(record.exchangeRate),
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoTile(
                          Icons.price_change,
                          l10n.calculatedPriceDetail,
                          '${numberFormat.format(record.finalPrice)} ₺',
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 20),
            
            // Footer
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(record.createdAt),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                ),
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.note, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
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
                Text('${l10n.cumulativeDiscountDetail}: %${numberFormat.format(record.discountRate)}'),
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

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
                          // Desktop için geniş layout (1920x1080 optimize)
                          if (constraints.maxWidth > 1200) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.2, // Kartları daha geniş yap
                              ),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return _buildDesktopRecordCard(record, l10n, dateFormat, numberFormat);
                              },
                            );
                          } else {
                            // Mobil için liste layout
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