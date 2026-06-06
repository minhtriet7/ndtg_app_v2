import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../controllers/history_controller.dart';
import '../widgets/history_filter_bar.dart';
import '../widgets/history_item_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HistoryController>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: IconButton.filledTonal(
              tooltip: 'Filter',
              onPressed: () => setState(() => _showFilters = !_showFilters),
              icon: Icon(_showFilters ? Icons.tune_rounded : Icons.tune_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.fetchHistory,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryHero(
                      total: controller.historyList.length,
                      isDark: isDark,
                      onToggleFilter: () => setState(() => _showFilters = !_showFilters),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _showFilters
                          ? Padding(
                        key: const ValueKey('filters'),
                        padding: const EdgeInsets.only(top: AppSizes.lg),
                        child: HistoryFilterBar(
                          searchQuery: controller.searchQuery,
                          statusFilter: controller.statusFilter,
                          currencyFilter: controller.currencyFilter,
                          currencies: controller.availableCurrencies,
                          onSearchChanged: controller.updateSearch,
                          onStatusChanged: controller.updateStatusFilter,
                          onCurrencyChanged: controller.updateCurrencyFilter,
                          onApply: controller.applyFilters,
                          onReset: controller.clearFilters,
                        ),
                      )
                          : const SizedBox.shrink(key: ValueKey('emptyFilters')),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent recognition results',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        AppBadge(
                          text: '${controller.historyList.length} scans',
                          status: BadgeStatus.info,
                          uppercase: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],
                ),
              ),
            ),
            if (controller.isLoading && controller.historyList.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                sliver: SliverList.separated(
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
                  itemBuilder: (_, __) => const LoadingSkeleton(
                    height: 112,
                    borderRadius: AppSizes.radiusXl,
                  ),
                ),
              )
            else if (controller.error != null && controller.historyList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorState(message: controller.error!, onRetry: controller.fetchHistory),
              )
            else if (controller.historyList.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No scans yet',
                    message: 'Start a scan and BanknoteAI will save the final result here.',
                    icon: Icons.history_rounded,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, 112),
                  sliver: SliverList.separated(
                    itemCount: controller.historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) => HistoryItemCard(result: controller.historyList[index]),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHero extends StatelessWidget {
  final int total;
  final bool isDark;
  final VoidCallback onToggleFilter;

  const _HistoryHero({
    required this.total,
    required this.isDark,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      hasBorder: false,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.10 : 0.22),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onToggleFilter,
                  icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Filters',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Recognition History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Review saved outputs, confidence, status, and complete multi-agent details.',
              style: TextStyle(color: Colors.white70, height: 1.45, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.20)),
              ),
              child: Text(
                '$total total scans',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
