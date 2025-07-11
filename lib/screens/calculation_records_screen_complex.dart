import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculationRecordsTitle),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportRecords();
                  break;
                case 'import':
                  _importRecords();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    const Icon(Icons.file_download),
                    const SizedBox(width: 8),
                    Text(l10n.exportRecords),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    const Icon(Icons.file_upload),
                    const SizedBox(width: 8),
                    Text(l10n.importRecords),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
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
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? l10n.noRecordsYet
                                  : l10n.noSearchResults,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRecords.length,
                        itemBuilder: (context, index) {
                          final record = _filteredRecords[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                record.productName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () => _showCalculationDetail(record),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(l10n.originalPriceLabel(numberFormat.format(record.originalPrice))),
                                  Text(l10n.exchangeRateLabel(numberFormat.format(record.exchangeRate))),
                                  Text(l10n.discountRateLabel(numberFormat.format(record.discountRate))),
                                  Text(
                                    l10n.finalPriceLabel(numberFormat.format(record.finalPrice)),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.notesLabelRecord(record.notes!),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(record.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _showDeleteConfirmation(record),
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

  void _showCalculationDetail(CalculationRecord record) {
    showDialog(
      context: context,
      builder: (context) => CalculationDetailDialog(record: record),
    ).then((updatedRecord) {
      if (updatedRecord != null) {
        _loadRecords();
      }
    });
  }

  Future<void> _exportRecords() async {
    try {
      final records = await DatabaseHelper().getCalculationRecords();
      
      if (records.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.noRecordsToExport)),
          );
        }
        return;
      }

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '2.0.0',
        'recordCount': records.length,
        'records': records.map((record) => {
          'id': record.id,
          'productName': record.productName,
          'originalPrice': record.originalPrice,
          'exchangeRate': record.exchangeRate,
          'discountRate': record.discountRate,
          'finalPrice': record.finalPrice,
          'createdAt': record.createdAt.toIso8601String(),
          'notes': record.notes,
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Dosya adı oluştur
      final now = DateTime.now();
      final fileName = 'hesap_kayitlari_${DateFormat('yyyyMMdd_HHmmss').format(now)}.json';
      
      // Mobil ve desktop için - file picker ile kaydet
      await _saveFileNative(jsonString, fileName);
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess(records.length.toString())),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportError(e.toString()))),
        );
      }
    }
  }

  Future<void> _saveFileNative(String content, String fileName) async {
    try {
      // Dosya kaydetme konumu seç
      final l10n = AppLocalizations.of(context)!;
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: l10n.saveRecordsDialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(content);
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.fileSaved(file.path)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileSaveError(e.toString()))),
        );
      }
    }
  }

  Future<void> _importRecords() async {
    try {
      // Mobil ve desktop için - file picker ile aç
      await _pickFileNative();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importError(e.toString()))),
        );
      }
    }
  }

  Future<void> _pickFileNative() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: l10n.selectRecordsDialogTitle,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();
        await _processImport(content);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fileReadError(e.toString()))),
        );
      }
    }
  }

  Future<void> _processImport(String jsonContent) async {
    try {
      if (jsonContent.trim().isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.jsonContentEmpty)),
          );
        }
        return;
      }

      final Map<String, dynamic> importData = jsonDecode(jsonContent);
      
      // Veri formatını kontrol et
      if (!importData.containsKey('records') || importData['records'] is! List) {
        throw Exception('Geçersiz JSON formatı');
      }

      final List<dynamic> recordsData = importData['records'];
      final List<CalculationRecord> newRecords = [];

      for (final recordData in recordsData) {
        final record = CalculationRecord(
          id: recordData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          productName: recordData['productName'] ?? '',
          originalPrice: (recordData['originalPrice'] ?? 0.0).toDouble(),
          exchangeRate: (recordData['exchangeRate'] ?? 0.0).toDouble(),
          discountRate: (recordData['discountRate'] ?? 0.0).toDouble(),
          finalPrice: (recordData['finalPrice'] ?? 0.0).toDouble(),
          createdAt: DateTime.parse(recordData['createdAt'] ?? DateTime.now().toIso8601String()),
          notes: recordData['notes'],
        );
        newRecords.add(record);
      }

      // Kayıtları veritabanına ekle
      for (final record in newRecords) {
        await DatabaseHelper().saveCalculationRecord(record);
      }

      // Listeyi yenile
      await _loadRecords();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importSuccess(newRecords.length.toString())),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importError(e.toString()))),
        );
      }
    }
  }
}

class CalculationDetailDialog extends StatefulWidget {
  final CalculationRecord record;

  const CalculationDetailDialog({super.key, required this.record});

  @override
  State<CalculationDetailDialog> createState() => _CalculationDetailDialogState();
}

class _CalculationDetailDialogState extends State<CalculationDetailDialog> {
  double? _currentUsdRate;
  double? _currentEurRate;
  double? _updatedFinalPrice;
  bool _isLoadingRates = false;
  
  // Güncel hesaplama detayları
  double? _currentPriceConvert;
  double? _currentPriceAfterDiscount;
  double? _currentPriceBought;
  double? _currentPriceBoughtTax;
  double? _currentPriceWithProfit;
  double? _currentKdvPrice;

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
      await _fetchRatesDirectly();
    } catch (e) {
      // Kur yüklenirken hata
    }

    _calculateUpdatedPrice();
    
    setState(() {
      _isLoadingRates = false;
    });
  }

  Future<void> _fetchRatesDirectly() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.isbank.com.tr/doviz-kurlari'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'tr-TR,tr;q=0.9,en;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      if (response.statusCode == 200) {
        final document = parse(response.body);
        
        // USD için arama
        final usdRows = document.querySelectorAll('tr');
        for (final row in usdRows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 3) {
            final currency = cells[0].text.trim();
            if (currency.contains('USD') || currency.contains('Amerikan Doları')) {
              final sellingRate = cells[2].text.trim().replaceAll(',', '.');
              _currentUsdRate = double.tryParse(sellingRate);
              break;
            }
          }
        }

        // EUR için arama
        final eurRows = document.querySelectorAll('tr');
        for (final row in eurRows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 3) {
            final currency = cells[0].text.trim();
            if (currency.contains('EUR') || currency.contains('Euro')) {
              final sellingRate = cells[2].text.trim().replaceAll(',', '.');
              _currentEurRate = double.tryParse(sellingRate);
              break;
            }
          }
        }
      }
    } catch (e) {
      // Kur yüklenirken hata
    }
  }

  void _calculateUpdatedPrice() {
    if (_currentUsdRate == null) return;
    
    try {
      final double originalPrice = widget.record.originalPrice;
      final double currentRate = _currentUsdRate!;
      final double totalDiscountRate = widget.record.discountRate / 100;
      
      // Hesaplama sayfasındaki gibi adım adım hesaplama
      _currentPriceConvert = originalPrice * currentRate;
      _currentPriceAfterDiscount = originalPrice * (1 - totalDiscountRate);
      _currentPriceBought = _currentPriceAfterDiscount! * currentRate;
      _currentPriceBoughtTax = _currentPriceBought! * 1.2;
      
      // Kar marjı hesabı (%40 kar marjı)
      _currentPriceWithProfit = _currentPriceBought! * 1.4;
      _currentKdvPrice = _currentPriceWithProfit! * 1.2;
      
      _updatedFinalPrice = _currentKdvPrice;
    } catch (e) {
      // Fiyat hesaplama hatası
    }
  }

  Future<void> _updateRecordPrice() async {
    if (_updatedFinalPrice == null) return;
    
    try {
      final updatedRecord = widget.record.copyWith(
        finalPrice: _updatedFinalPrice!,
        exchangeRate: _currentUsdRate!,
        createdAt: DateTime.now(),
      );
      
      await DatabaseHelper().saveCalculationRecord(updatedRecord);
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context, updatedRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.priceUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateError(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints:  BoxConstraints(maxWidth: 500, maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.record.productName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      l10n.originalCalculationTitle,
                      [
                        _buildDetailRow(l10n.productNameDetail, widget.record.productName),
                        _buildDetailRow(l10n.originalPriceDetail, '${numberFormat.format(widget.record.originalPrice)} \$'),
                        _buildDetailRow(l10n.usedRateDetail, numberFormat.format(widget.record.exchangeRate)),
                        _buildDetailRow(l10n.cumulativeDiscountDetail, '%${numberFormat.format(widget.record.discountRate)}'),
                        _buildDetailRow(l10n.calculatedPriceDetail, '${numberFormat.format(widget.record.finalPrice)} ₺'),
                        _buildDetailRow(l10n.calculationDateDetail, dateFormat.format(widget.record.createdAt)),
                        if (widget.record.notes != null && widget.record.notes!.isNotEmpty)
                          _buildDetailRow(l10n.notesDetail, widget.record.notes!),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    _buildDetailSection(
                      l10n.currentRateCalculation,
                      [
                        if (_isLoadingRates)
                          const Center(child: CircularProgressIndicator())
                        else if (_currentUsdRate != null) ...[
                          _buildDetailRow(l10n.currentUsdRateDetail, numberFormat.format(_currentUsdRate!)),
                          _buildDetailRow(l10n.currentEurRateDetail, _currentEurRate != null ? numberFormat.format(_currentEurRate!) : l10n.couldNotLoad),
                          const SizedBox(height: 12),
                          const Divider(thickness: 1),
                          const SizedBox(height: 8),
                          Text(
                            l10n.calculationSteps,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_currentPriceConvert != null) ...[
                            _buildDetailRow(
                              l10n.currencyConversion,
                              '${numberFormat.format(widget.record.originalPrice)} \$ × ${numberFormat.format(_currentUsdRate!)} = ${numberFormat.format(_currentPriceConvert!)} ₺',
                            ),
                            _buildDetailRow(
                              l10n.cumulativeDiscountSteps,
                              l10n.multipleDiscountApplied,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            _buildDetailRow(
                              l10n.resultStep,
                              '${numberFormat.format(widget.record.originalPrice)} \$ × (1 - %${numberFormat.format(widget.record.discountRate)}) = ${numberFormat.format(_currentPriceAfterDiscount!)} \$',
                              isHighlighted: true,
                            ),
                            _buildDetailRow(
                              l10n.purchasePriceDetail,
                              '${numberFormat.format(_currentPriceAfterDiscount!)} \$ × ${numberFormat.format(_currentUsdRate!)} = ${numberFormat.format(_currentPriceBought!)} ₺',
                              isHighlighted: true,
                            ),
                            _buildDetailRow(
                              l10n.purchaseVatDetail,
                              '${numberFormat.format(_currentPriceBought!)} ₺ × 1.2 = ${numberFormat.format(_currentPriceBoughtTax!)} ₺',
                            ),
                            _buildDetailRow(
                              l10n.salePriceDetail,
                              '${numberFormat.format(_currentPriceBought!)} ₺ × 1.4 = ${numberFormat.format(_currentPriceWithProfit!)} ₺',
                              isHighlighted: true,
                            ),
                            _buildDetailRow(
                              l10n.saleVatDetail,
                              '${numberFormat.format(_currentPriceWithProfit!)} ₺ × 1.2 = ${numberFormat.format(_currentKdvPrice!)} ₺',
                              isHighlighted: true,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            const Divider(thickness: 1),
                            const SizedBox(height: 8),
                            if (_updatedFinalPrice! != widget.record.finalPrice) ...[
                              _buildDetailRow(
                                l10n.priceChangeDetail,
                                '${numberFormat.format(widget.record.finalPrice)} ₺ → ${numberFormat.format(_updatedFinalPrice!)} ₺',
                                isHighlighted: true,
                                color: (_updatedFinalPrice! - widget.record.finalPrice).isNegative 
                                    ? Colors.red 
                                    : Colors.green,
                              ),
                              _buildDetailRow(
                                l10n.changeAmountDetail,
                                '${(_updatedFinalPrice! - widget.record.finalPrice).isNegative ? '' : '+'}${numberFormat.format(_updatedFinalPrice! - widget.record.finalPrice)} ₺',
                                isHighlighted: true,
                                color: (_updatedFinalPrice! - widget.record.finalPrice).isNegative 
                                    ? Colors.red 
                                    : Colors.green,
                              ),
                            ],
                          ],
                        ] else
                          Text(l10n.exchangeRateInfoUnavailable),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            if (_updatedFinalPrice != null && _updatedFinalPrice! != widget.record.finalPrice)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _updateRecordPrice,
                    icon: const Icon(Icons.update),
                    label: Text(l10n.updatePriceButtonDetail),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: color ?? (isHighlighted ? Theme.of(context).colorScheme.primary : null),
              ),
            ),
          ),
        ],
      ),
    );
  }
}