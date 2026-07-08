import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../controllers/banknote_directory_controller.dart';
import '../widgets/country_banknote_card.dart';
import '../widgets/country_filter_chip.dart';
import 'banknote_country_detail_screen.dart';

class SupportedBanknotesScreen extends StatelessWidget {
  const SupportedBanknotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BanknoteDirectoryController()..loadBanknotes(),
      child: const _SupportedBanknotesView(),
    );
  }
}

class _SupportedBanknotesView extends StatefulWidget {
  const _SupportedBanknotesView();

  @override
  State<_SupportedBanknotesView> createState() =>
      _SupportedBanknotesViewState();
}

class _SupportedBanknotesViewState extends State<_SupportedBanknotesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch(BanknoteDirectoryController controller) {
    _searchController.clear();
    controller.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BanknoteDirectoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.md,
                  ),
                  child: _DirectoryHeader(
                    controller: controller,
                    searchController: _searchController,
                    isDark: isDark,
                    onClearSearch: () => _clearSearch(controller),
                  ),
                ),
              ),
              if (controller.isLoading && controller.banknotes.isEmpty)
                const SliverToBoxAdapter(child: _DirectoryLoading())
              else if (controller.error != null && controller.banknotes.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    message: controller.error!,
                    onRetry: controller.refresh,
                  ),
                )
              else if (controller.countries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmptyState(
                          title: context.tr('noSupportedBanknotes'),
                          message: context.tr('directoryEmptyDesc'),
                          icon: Icons.public_off_rounded,
                        ),
                        if (controller.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.md),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _clearSearch(controller),
                              icon: const Icon(Icons.close_rounded),
                              label: Text(context.tr('clearSearch')),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    0,
                    AppSizes.lg,
                    116,
                  ),
                  sliver: SliverList.separated(
                    itemCount: controller.countries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final country = controller.countries[index];

                      return CountryBanknoteCard(
                        country: country,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  BanknoteCountryDetailScreen(country: country),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectoryHeader extends StatelessWidget {
  final BanknoteDirectoryController controller;
  final TextEditingController searchController;
  final bool isDark;
  final VoidCallback onClearSearch;

  const _DirectoryHeader({
    required this.controller,
    required this.searchController,
    required this.isDark,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final chips = controller.availableCountries.isEmpty
        ? [
            'Vietnam',
            'Thailand',
            'Indonesia',
            'Malaysia',
            'Singapore',
            'Philippines',
            'Cambodia',
            'Laos',
            'Myanmar',
            'Brunei',
          ]
        : controller.availableCountries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('banknoteDict'),
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.tr('directoryExtendedDesc'),
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(isDark ? 0.10 : 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: context.tr('countries'),
                  value: controller.totalCountries.toString(),
                ),
              ),
              Container(width: 1, height: 46, color: Colors.white24),
              Expanded(
                child: _HeroMetric(
                  label: context.tr('banknotes'),
                  value: controller.totalNotes.toString(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        TextField(
          controller: searchController,
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: context.tr('directorySearchHint'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CountryFilterChip(
                label: context.tr('all'),
                selected: controller.searchQuery.isEmpty,
                onTap: onClearSearch,
              ),
              const SizedBox(width: AppSizes.sm),
              ...chips.map(
                (country) => Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: CountryFilterChip(
                    label: country,
                    selected:
                        controller.searchQuery.toLowerCase() ==
                        country.toLowerCase(),
                    onTap: () {
                      searchController.text = country;
                      controller.filterCountry(country);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                controller.searchQuery.isEmpty
                    ? context.tr('supportedCountries')
                    : context.tr('filteredCountries'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (controller.isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryTeal,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

class _DirectoryLoading extends StatelessWidget {
  const _DirectoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, 116),
      child: Column(
        children: [
          LoadingSkeleton(height: 92, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 92, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 92, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 92, borderRadius: AppSizes.radiusLg),
        ],
      ),
    );
  }
}
