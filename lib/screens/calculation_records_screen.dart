import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

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
      final records = await DatabaseHelper().getCalculationRecords();
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
      await DatabaseHelper().deleteCalculationRecord(id);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculationRecordsTitle),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Kayıtlar listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? l10n.noRecordsYet
                              : l10n.noSearchResults,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = _filteredRecords[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                record.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.monetization_on, size: 16, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text('${numberFormat.format(record.originalPrice)} \$ → ${numberFormat.format(record.finalPrice)} ₺'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.percent, size: 16, color: Theme.of(context).colorScheme.secondary),
                                      const SizedBox(width: 4),
                                      Text('%${numberFormat.format(record.discountRate)} ${l10n.discount1}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.outline),
                                      const SizedBox(width: 4),
                                      Text(dateFormat.format(record.createdAt)),
                                    ],
                                  ),
                                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.note, size: 16, color: Theme.of(context).colorScheme.outline),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            record.notes!,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.outline,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Row(
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
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showSimpleDetailDialog(CalculationRecord record) {
    showDialog(
      context: context,
      builder: (context) => DetailedCalculationDialog(record: record),
    ).then((result) {
      if (result == 'updated') {
        _loadRecords(); // Kayıtları yeniden yükle
      }
    });
  }

}

// Detaylı hesaplama dialog'u
class DetailedCalculationDialog extends StatefulWidget {
  final CalculationRecord record;

  const DetailedCalculationDialog({super.key, required this.record});

  @override
  State<DetailedCalculationDialog> createState() => _DetailedCalculationDialogState();
}

class _DetailedCalculationDialogState extends State<DetailedCalculationDialog> {
  bool _showBasicView = true;
  bool _isLoadingRates = false;
  double? _currentUsdRate;
  double? _currentEurRate;

  @override
  void initState() {
    super.initState();
    _loadCurrentRates();
  }

  Future<void> _loadCurrentRates() async {
    setState(() {
      _isLoadingRates = true;
    });

    try {
      await _fetchCurrentRates();
    } catch (e) {
      // Hata durumunda sessizce devam et
    }

    setState(() {
      _isLoadingRates = false;
    });
  }

  Future<void> _fetchCurrentRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.isbank.com.tr/doviz-kurlari'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final rows = document.querySelectorAll('tr');
        
        for (final row in rows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 3) {
            final currency = cells[0].text.trim();
            final sellingRate = cells[2].text.trim().replaceAll(',', '.');
            
            if (currency.contains('USD') || currency.contains('Amerikan Doları')) {
              _currentUsdRate = double.tryParse(sellingRate);
            } else if (currency.contains('EUR') || currency.contains('Euro')) {
              _currentEurRate = double.tryParse(sellingRate);
            }
          }
        }
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  Future<void> _updateWithCurrentRate() async {
    if (_currentUsdRate == null) return;

    try {
      final l10n = AppLocalizations.of(context)!;
      
      // Güncel kurla yeni fiyat hesapla
      final originalPrice = widget.record.originalPrice;
      final discountRate = widget.record.discountRate / 100;
      final discountedPrice = originalPrice * (1 - discountRate);
      final convertedPrice = discountedPrice * _currentUsdRate!;
      final priceWithProfit = convertedPrice * 1.4;
      final finalPrice = priceWithProfit * 1.2;

      // Yeni kayıt oluştur
      final updatedRecord = widget.record.copyWith(
        finalPrice: finalPrice,
        exchangeRate: _currentUsdRate!,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper().saveCalculationRecord(updatedRecord);

      if (mounted) {
        Navigator.pop(context, 'updated');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.priceUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditOriginalPriceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final priceController = TextEditingController(
      text: widget.record.originalPrice.toString(),
    );

    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.editOriginalPrice),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.enterNewPrice,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.newOriginalPrice,
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price > 0) {
                Navigator.pop(context, price);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invalidPriceFormat),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.calculate),
            label: Text(l10n.recalculateWithNewPrice),
          ),
        ],
      ),
    );

    if (newPrice != null) {
      await _updateWithNewOriginalPrice(newPrice);
    }
  }

  Future<void> _updateWithNewOriginalPrice(double newOriginalPrice) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      
      // Yeni orijinal fiyat ile hesapla
      final discountRate = widget.record.discountRate / 100;
      final discountedPrice = newOriginalPrice * (1 - discountRate);
      final exchangeRate = _currentUsdRate ?? widget.record.exchangeRate;
      final convertedPrice = discountedPrice * exchangeRate;
      final priceWithProfit = convertedPrice * 1.4;
      final finalPrice = priceWithProfit * 1.2;

      // Yeni kayıt oluştur
      final updatedRecord = widget.record.copyWith(
        originalPrice: newOriginalPrice,
        finalPrice: finalPrice,
        exchangeRate: exchangeRate,
        createdAt: DateTime.now(),
      );

      await DatabaseHelper().saveCalculationRecord(updatedRecord);

      if (mounted) {
        Navigator.pop(context, 'updated');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.priceUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.updateError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.record.productName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  // Görünüm değiştirme butonu
                  IconButton(
                    icon: Icon(
                      _showBasicView ? Icons.expand_more : Icons.expand_less,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () {
                      setState(() {
                        _showBasicView = !_showBasicView;
                      });
                    },
                    tooltip: _showBasicView ? l10n.detailedView : l10n.basicView,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _showBasicView 
                    ? _buildBasicView(l10n, dateFormat, numberFormat)
                    : _buildDetailedView(l10n, dateFormat, numberFormat),
              ),
            ),

            // Alt butonlar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üst satır - Görünüm değiştirme
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showBasicView = !_showBasicView;
                          });
                        },
                        icon: Icon(_showBasicView ? Icons.visibility : Icons.visibility_off),
                        label: Text(_showBasicView ? l10n.showDetailed : l10n.showBasic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Alt satır - Aksiyon butonları
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showEditOriginalPriceDialog,
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(
                          l10n.editOriginalPrice,
                          style: const TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(100, 32),
                        ),
                      ),
                      if (_currentUsdRate != null)
                        ElevatedButton.icon(
                          onPressed: _updateWithCurrentRate,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(
                            l10n.updatePriceButton,
                            style: const TextStyle(fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(100, 32),
                          ),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: const Size(80, 32),
                        ),
                        child: Text(l10n.ok),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicView(AppLocalizations l10n, DateFormat dateFormat, NumberFormat numberFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailCard(
          l10n.calculationSummary,
          Icons.receipt_long,
          [
            _buildDetailRow(l10n.originalPrice, '${numberFormat.format(widget.record.originalPrice)} \$', Icons.attach_money),
            _buildDetailRow(l10n.usedRate, numberFormat.format(widget.record.exchangeRate), Icons.currency_exchange),
            _buildDetailRow(l10n.totalDiscount, '%${numberFormat.format(widget.record.discountRate)}', Icons.percent),
            _buildDetailRow(l10n.finalPriceVat, '${numberFormat.format(widget.record.finalPrice)} ₺', Icons.monetization_on, isHighlighted: true),
            _buildDetailRow(l10n.calculationDate, dateFormat.format(widget.record.createdAt), Icons.access_time),
            if (widget.record.notes != null && widget.record.notes!.isNotEmpty)
              _buildDetailRow(l10n.notes, widget.record.notes!, Icons.note),
          ],
        ),
        
        if (_currentUsdRate != null) ...[
          const SizedBox(height: 16),
          _buildCurrentRateCard(l10n, numberFormat),
        ],
      ],
    );
  }

  Widget _buildDetailedView(AppLocalizations l10n, DateFormat dateFormat, NumberFormat numberFormat) {
    final originalPrice = widget.record.originalPrice;
    final exchangeRate = widget.record.exchangeRate;
    final discountRate = widget.record.discountRate / 100;
    
    // Hesaplama adımları
    final convertedPrice = originalPrice * exchangeRate;
    final discountedPrice = originalPrice * (1 - discountRate);
    final purchasePrice = discountedPrice * exchangeRate;
    final purchasePriceWithTax = purchasePrice * 1.2;
    final salePriceWithProfit = purchasePrice * 1.4;
    final finalPrice = salePriceWithProfit * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailCard(
          l10n.originalCalculation,
          Icons.receipt_long,
          [
            _buildDetailRow(l10n.productName, widget.record.productName, Icons.shopping_cart),
            _buildDetailRow(l10n.calculationDate, dateFormat.format(widget.record.createdAt), Icons.access_time),
            if (widget.record.notes != null && widget.record.notes!.isNotEmpty)
              _buildDetailRow(l10n.notes, widget.record.notes!, Icons.note),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildDetailCard(
          l10n.calculationSteps,
          Icons.calculate,
          [
            _buildCalculationStep('1. ${l10n.currencyConversionStep}', '${numberFormat.format(originalPrice)} \$ × ${numberFormat.format(exchangeRate)} = ${numberFormat.format(convertedPrice)} ₺'),
            _buildCalculationStep('2. ${l10n.discountApplicationStep}', '${numberFormat.format(originalPrice)} \$ × %${numberFormat.format(widget.record.discountRate)} = ${numberFormat.format(discountedPrice)} \$'),
            _buildCalculationStep('3. ${l10n.purchasePriceStep}', '${numberFormat.format(discountedPrice)} \$ × ${numberFormat.format(exchangeRate)} = ${numberFormat.format(purchasePrice)} ₺'),
            _buildCalculationStep('4. ${l10n.purchaseVatStep}', '${numberFormat.format(purchasePrice)} ₺ × 1.2 = ${numberFormat.format(purchasePriceWithTax)} ₺'),
            _buildCalculationStep('5. ${l10n.salePriceStep}', '${numberFormat.format(purchasePrice)} ₺ × 1.4 = ${numberFormat.format(salePriceWithProfit)} ₺'),
            _buildCalculationStep('6. ${l10n.saleVatStep}', '${numberFormat.format(salePriceWithProfit)} ₺ × 1.2 = ${numberFormat.format(finalPrice)} ₺', isResult: true),
          ],
        ),
        
        if (_currentUsdRate != null) ...[
          const SizedBox(height: 16),
          _buildCurrentRateCard(l10n, numberFormat),
        ],
      ],
    );
  }

  Widget _buildCurrentRateCard(AppLocalizations l10n, NumberFormat numberFormat) {
    if (_isLoadingRates) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_currentUsdRate == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.exchangeRateLoadError,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    // Güncel kurla fiyat hesapla
    final originalPrice = widget.record.originalPrice;
    final discountRate = widget.record.discountRate / 100;
    final discountedPrice = originalPrice * (1 - discountRate);
    final purchasePrice = discountedPrice * _currentUsdRate!;
    final salePriceWithProfit = purchasePrice * 1.4;
    final newFinalPrice = salePriceWithProfit * 1.2;
    final priceDifference = newFinalPrice - widget.record.finalPrice;

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.update,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.currentRateCalculation,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(l10n.currentUsdRate, numberFormat.format(_currentUsdRate!), Icons.attach_money),
            if (_currentEurRate != null)
              _buildDetailRow(l10n.currentEurRate, numberFormat.format(_currentEurRate!), Icons.euro),
            const Divider(),
            _buildDetailRow(l10n.newPrice, '${numberFormat.format(newFinalPrice)} ₺', Icons.monetization_on, isHighlighted: true),
            _buildDetailRow(l10n.priceDifference, '${priceDifference >= 0 ? '+' : ''}${numberFormat.format(priceDifference)} ₺', 
                priceDifference >= 0 ? Icons.trending_up : Icons.trending_down, 
                isHighlighted: true, 
                color: priceDifference >= 0 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isHighlighted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? (isHighlighted 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                    color: color ?? (isHighlighted 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationStep(String step, String calculation, {bool isResult = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isResult 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isResult 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            calculation,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isResult ? FontWeight.bold : FontWeight.normal,
              color: isResult 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}