import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../main/controllers/main_tab_controller.dart';
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
          const SizedBox(height: AppSizes.md),
          ...country.banknotes.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: BanknoteDirectoryCard(banknote: item),
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
}