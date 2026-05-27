import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../controllers/currency_controller.dart';
import '../widgets/currency_input_box.dart';
import '../widgets/exchange_rate_chip.dart';
import '../widgets/quick_convert_card.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyController>().fetchRates();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurrencyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [IconButton(tooltip: 'Refresh rates', onPressed: controller.fetchRates, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.fetchRates,
        child: controller.isLoading && controller.rates.isEmpty
            ? const _CurrencyLoading()
            : controller.error != null && controller.rates.isEmpty
            ? ErrorState(message: controller.error!, onRetry: controller.fetchRates)
            : controller.rates.isEmpty
            ? const EmptyState(title: 'No exchange rates', message: 'No active currency rates are available. Please try again later.', icon: Icons.currency_exchange_rounded)
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text('Live exchange calculator', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('Convert Southeast Asian currencies using rates maintained by BanknoteAI.', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.4)),
            const SizedBox(height: AppSizes.lg),
            CurrencyInputBox(
              title: 'You send',
              controller: _amountController,
              selectedCurrency: controller.fromCurrency,
              currencies: controller.rates,
              onAmountChanged: controller.setAmount,
              onCurrencyChanged: controller.setFromCurrency,
            ),
            const SizedBox(height: AppSizes.md),
            Center(
              child: InkWell(
                onTap: controller.swapCurrencies,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: AppColors.primaryTeal.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.swap_vert_rounded, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            CurrencyInputBox(
              title: 'Recipient gets',
              valueText: MoneyFormatter.formatCurrencyAmount(controller.convertedAmount, controller.toCurrency?.targetCurrency ?? ''),
              selectedCurrency: controller.toCurrency,
              currencies: controller.rates,
              onCurrencyChanged: controller.setToCurrency,
              readOnly: true,
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(text: controller.isConverting ? 'Converting...' : 'Convert', icon: Icons.calculate_rounded, isLoading: controller.isConverting, onPressed: controller.convertWithBackend),
            const SizedBox(height: AppSizes.lg),
            _RateInfoPanel(controller: controller),
            const SizedBox(height: AppSizes.xl),
            Text('Quick conversions to VND', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: AppSizes.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.quickCurrencies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: AppSizes.md, crossAxisSpacing: AppSizes.md, childAspectRatio: 1.7),
              itemBuilder: (context, index) => QuickConvertCard(rate: controller.quickCurrencies[index]),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _RateInfoPanel extends StatelessWidget {
  final CurrencyController controller;
  const _RateInfoPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final from = controller.fromCurrency;
    final to = controller.toCurrency;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (from == null || to == null) return const SizedBox.shrink();
    final rate = from.effectiveRateToVnd / to.effectiveRateToVnd;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: [ExchangeRateChip(rate: from), ExchangeRateChip(rate: to)]),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('1 ${from.targetCurrency} = ${MoneyFormatter.formatCurrencyAmount(rate, to.targetCurrency)}', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w800))),
              if (from.isStale || to.isStale) const AppBadge(text: 'Stale', status: BadgeStatus.warning) else const AppBadge(text: 'Fresh', status: BadgeStatus.success),
            ],
          ),
          if (from.lastUpdated != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text('Last updated: ${DateFormatter.formatDateTime(from.lastUpdated!.toIso8601String())}', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _CurrencyLoading extends StatelessWidget {
  const _CurrencyLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: const [
        LoadingSkeleton(height: 32, width: 240),
        SizedBox(height: AppSizes.lg),
        LoadingSkeleton(height: 132, borderRadius: AppSizes.radiusLg),
        SizedBox(height: AppSizes.md),
        LoadingSkeleton(height: 132, borderRadius: AppSizes.radiusLg),
        SizedBox(height: AppSizes.md),
        LoadingSkeleton(height: 90, borderRadius: AppSizes.radiusLg),
      ],
    );
  }
}
