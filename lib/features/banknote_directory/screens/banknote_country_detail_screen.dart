import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../currency/data/currency_service.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../models/banknote_directory_model.dart';
import '../models/supported_country_model.dart';
import '../widgets/banknote_directory_card.dart';

class BanknoteCountryDetailScreen extends StatelessWidget {
  final SupportedCountryModel country;

  const BanknoteCountryDetailScreen({
    super.key,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(country.country),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.xxl,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(isDark ? 0.12 : 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public_rounded, color: Colors.white, size: 38),
                const SizedBox(height: AppSizes.md),
                Text(
                  country.country,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${country.noteCount} supported banknotes · ${country.currencyCode}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(text: country.currencyCode),
                    _HeroPill(text: '${country.noteCount} notes'),
                    _HeroPill(text: 'AI reference ready'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            'Supported Banknotes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap a banknote to view reference images, features, and estimated VND value.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.md),
          ...country.banknotes.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: BanknoteDirectoryCard(
                banknote: item,
                onTap: () => _showBanknoteDetail(context, item),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                context.read<MainTabController>().goScan();
              },
              icon: const Icon(Icons.document_scanner_rounded),
              label: const Text('Scan Similar Banknote'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBanknoteDetail(BuildContext context, BanknoteDirectoryModel banknote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BanknoteDetailSheet(banknote: banknote),
    );
  }
}

class _BanknoteDetailSheet extends StatelessWidget {
  final BanknoteDirectoryModel banknote;

  const _BanknoteDetailSheet({
    required this.banknote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.48,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : const Color(0xFFF8FBFF),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.md,
              AppSizes.lg,
              AppSizes.xl,
            ),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      banknote.displayName,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '${banknote.country} · ${banknote.currencyCode}',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              if (banknote.hasAnyImage)
                _BanknoteImages(banknote: banknote)
              else
                const _NoImagePanel(),
              const SizedBox(height: AppSizes.lg),
              _VndEstimateCard(banknote: banknote),
              const SizedBox(height: AppSizes.lg),
              _BanknoteMetadata(banknote: banknote),
              if (banknote.description.trim().isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        banknote.description,
                        style: const TextStyle(
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (banknote.features.isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security / Recognition Features',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      ...banknote.features.map(
                            (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primaryTeal,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BanknoteImages extends StatelessWidget {
  final BanknoteDirectoryModel banknote;

  const _BanknoteImages({required this.banknote});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (banknote.frontImageUrl.isNotEmpty)
          _ImagePanel(
            label: 'Front side',
            imageUrl: banknote.frontImageUrl,
          ),
        if (banknote.frontImageUrl.isNotEmpty && banknote.backImageUrl.isNotEmpty)
          const SizedBox(height: AppSizes.md),
        if (banknote.backImageUrl.isNotEmpty)
          _ImagePanel(
            label: 'Back side',
            imageUrl: banknote.backImageUrl,
          ),
      ],
    );
  }
}

class _ImagePanel extends StatelessWidget {
  final String label;
  final String imageUrl;

  const _ImagePanel({
    required this.label,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          NetworkImageView(
            imageUrl: imageUrl,
            height: 210,
            fit: BoxFit.contain,
            borderRadius: AppSizes.radiusLg,
          ),
        ],
      ),
    );
  }
}

class _NoImagePanel extends StatelessWidget {
  const _NoImagePanel();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 44,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMutedDark
                : AppColors.textMutedLight,
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Reference image not available',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VndEstimateCard extends StatefulWidget {
  final BanknoteDirectoryModel banknote;

  const _VndEstimateCard({required this.banknote});

  @override
  State<_VndEstimateCard> createState() => _VndEstimateCardState();
}

class _VndEstimateCardState extends State<_VndEstimateCard> {
  final CurrencyService _currencyService = CurrencyService();

  bool _loading = true;
  double? _converted;
  String? _error;

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Future<void> _convert() async {
    final amount = widget.banknote.numericDenomination;
    final currency = widget.banknote.currencyCode.toUpperCase();

    if (amount <= 0 || currency.isEmpty || currency == 'N/A' || currency == 'UNKNOWN') {
      setState(() {
        _loading = false;
        _error = 'Exchange estimate unavailable.';
      });
      return;
    }

    if (currency == 'VND') {
      setState(() {
        _loading = false;
        _converted = amount;
      });
      return;
    }

    final converted = await _currencyService.convertToVnd(
      amount: amount,
      fromCurrency: currency,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _converted = converted;
      _error = converted == null ? 'Exchange rate unavailable.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.banknote.numericDenomination;
    final currency = widget.banknote.currencyCode.toUpperCase();

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated VND Value',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                if (_loading)
                  const Text(
                    'Checking exchange rate...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )
                else if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Text(
                    currency == 'VND'
                        ? '${_formatNumber(amount)} VND'
                        : '${_formatNumber(amount)} $currency ≈ ${_formatNumber(_converted ?? 0)} VND',
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BanknoteMetadata extends StatelessWidget {
  final BanknoteDirectoryModel banknote;

  const _BanknoteMetadata({required this.banknote});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banknote Metadata',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(child: _MetaBox(label: 'Country', value: banknote.country)),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: _MetaBox(label: 'Currency', value: banknote.currencyCode)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(child: _MetaBox(label: 'Material', value: banknote.material)),
              const SizedBox(width: AppSizes.sm),
              Expanded(child: _MetaBox(label: 'Series', value: banknote.seriesYear)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _MetaBox(label: 'Origin', value: banknote.origin),
        ],
      ),
    );
  }
}

class _MetaBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetaBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.trim().isEmpty ? 'Unknown' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String text;

  const _HeroPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _formatNumber(double value) {
  final rounded = value.round();
  final text = rounded.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}