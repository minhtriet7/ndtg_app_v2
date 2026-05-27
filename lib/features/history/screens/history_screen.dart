import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
      context.read<HistoryController>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
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
              padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.sm),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your recognition activity',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Review previous AI banknote scans, confidence status, and detailed agent outputs.',
                      style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 14, height: 1.4),
                    ),
                    if (_showFilters) ...[
                      const SizedBox(height: AppSizes.lg),
                      HistoryFilterBar(
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
                    ],
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
                  itemBuilder: (_, __) => const LoadingSkeleton(height: 96, borderRadius: AppSizes.radiusLg),
                ),
              )
            else if (controller.error != null && controller.historyList.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: ErrorState(message: controller.error!, onRetry: controller.fetchHistory))
            else if (controller.historyList.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(title: 'No scans yet', message: 'Start by scanning a banknote. Your results will appear here.', icon: Icons.history_rounded),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.lg, 0, AppSizes.lg, AppSizes.xxl),
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
