import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/exchange_rate_service.dart';

class ExchangeRateCard extends StatelessWidget {
  final ExchangeRates? exchangeRates;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ExchangeRateCard({
    super.key,
    this.exchangeRates,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat('#,##0.00', 'tr_TR');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.exchangeRates,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: isLoading ? null : onRefresh,
                  tooltip: l10n.refreshRates,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(l10n.loading),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildRateColumn(
                      context,
                      l10n.usdRate,
                      exchangeRates?.usdRate,
                      numberFormat,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRateColumn(
                      context,
                      l10n.eurRate,
                      exchangeRates?.eurRate,
                      numberFormat,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (exchangeRates != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bankSellingRate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.dataSource} ${exchangeRates!.dataSource}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateColumn(
    BuildContext context,
    String title,
    double? rate,
    NumberFormat numberFormat,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rate != null ? numberFormat.format(rate) : l10n.dataUnavailable,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: rate != null 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}