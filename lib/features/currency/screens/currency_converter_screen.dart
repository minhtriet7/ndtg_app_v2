import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
        actions: [
          IconButton(
            tooltip: 'Refresh rates',
            onPressed: controller.fetchRates,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.fetchRates,
        child: controller.isLoading && controller.rates.isEmpty
            ? const _CurrencyLoading()
            : controller.error != null && controller.rates.isEmpty
            ? ErrorState(message: controller.error!, onRetry: controller.fetchRates)
            : controller.rates.isEmpty
            ? const EmptyState(
          title: 'No exchange rates',
          message: 'No active currency rates are available. Please try again later.',
          icon: Icons.currency_exchange_rounded,
        )
            : _CurrencyContent(
          controller: controller,
          amountController: _amountController,
        ),
      ),
    );
  }
}

class _CurrencyContent extends StatelessWidget {
  final CurrencyController controller;
  final TextEditingController amountController;

  const _CurrencyContent({
    required this.controller,
    required this.amountController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.xxl,
      ),
      children: [
        _CurrencyHero(controller: controller),
        const SizedBox(height: AppSizes.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withOpacity(isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: const Icon(
                      Icons.currency_exchange_rounded,
                      color: AppColors.primaryTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exchange calculator',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rates are maintained by the BanknoteAI backend.',
                          style: TextStyle(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              CurrencyInputBox(
                title: 'You send',
                controller: amountController,
                selectedCurrency: controller.fromCurrency,
                currencies: controller.rates,
                onAmountChanged: controller.setAmount,
                onCurrencyChanged: controller.setFromCurrency,
              ),
              const SizedBox(height: AppSizes.md),
              Center(
                child: GestureDetector(
                  onTap: controller.swapCurrencies,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.tealGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withOpacity(isDark ? 0.12 : 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.swap_vert_rounded, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              CurrencyInputBox(
                title: 'Recipient gets',
                valueText: MoneyFormatter.formatCurrencyAmount(
                  controller.convertedAmount,
                  controller.toCurrency?.targetCurrency ?? '',
                ),
                selectedCurrency: controller.toCurrency,
                currencies: controller.rates,
                onCurrencyChanged: controller.setToCurrency,
                readOnly: true,
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                text: controller.isConverting ? 'Converting...' : 'Convert with backend',
                icon: Icons.calculate_rounded,
                isLoading: controller.isConverting,
                onPressed: controller.convertWithBackend,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        _RateInfoPanel(controller: controller),
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                'Quick conversions to VND',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            AppBadge(
              text: '${controller.quickCurrencies.length} rates',
              status: BadgeStatus.info,
              uppercase: false,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.quickCurrencies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.md,
            crossAxisSpacing: AppSizes.md,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (context, index) => QuickConvertCard(
            rate: controller.quickCurrencies[index],
          ),
        ),
      ],
    );
  }
}

class _CurrencyHero extends StatelessWidget {
  final CurrencyController controller;

  const _CurrencyHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: Colors.white.withOpacity(0.24)),
                  ),
                  child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppSizes.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Southeast Asia FX Desk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Fast VND-based conversions for banknote workflows.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _HeroMetric(
                      label: 'Active rates',
                      value: controller.rates.length.toString(),
                    ),
                  ),
                  Container(width: 1, height: 38, color: Colors.white24),
                  Expanded(
                    child: _HeroMetric(
                      label: 'Base market',
                      value: 'VND',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rate intelligence',
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (from.isStale || to.isStale)
                const AppBadge(text: 'Stale', status: BadgeStatus.warning)
              else
                const AppBadge(text: 'Fresh', status: BadgeStatus.success),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              ExchangeRateChip(rate: from),
              ExchangeRateChip(rate: to),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, color: AppColors.primaryTeal, size: 20),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    '1 ${from.targetCurrency} = ${MoneyFormatter.formatCurrencyAmount(rate, to.targetCurrency)}',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (from.lastUpdated != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              'Last updated: ${DateFormatter.formatDateTime(from.lastUpdated!.toIso8601String())}',
              style: TextStyle(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        LoadingSkeleton(height: 168, borderRadius: AppSizes.radiusXxl),
        SizedBox(height: AppSizes.lg),
        LoadingSkeleton(height: 360, borderRadius: AppSizes.radiusXl),
        SizedBox(height: AppSizes.lg),
        LoadingSkeleton(height: 140, borderRadius: AppSizes.radiusXl),
      ],
    );
  }
}
