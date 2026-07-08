import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../routes/route_names.dart';
import '../controllers/payment_controller.dart';
import '../widgets/token_package_card.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String _selectedGateway = 'bank_transfer';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPricing();
    });
  }

  Future<void> _loadPricing() async {
    final controller = context.read<PaymentController>();
    await controller.fetchPackages();
    if (!mounted) return;

    final gateways = controller.enabledGateways;
    if (!gateways.contains(_selectedGateway)) {
      setState(() => _selectedGateway = gateways.isEmpty ? '' : gateways.first);
    }
  }

  Future<void> _buy(String packageId) async {
    final controller = context.read<PaymentController>();
    final success = await controller.initiatePayment(
      packageId,
      gateway: _selectedGateway,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamed(RouteNames.checkout);
    } else if (controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(controller.error!)),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('topUpTokens')),
        actions: [
          IconButton(
            tooltip: context.tr('transactions'),
            onPressed: () =>
                Navigator.of(context).pushNamed(RouteNames.transactions),
            icon: const Icon(Icons.receipt_long_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: _loadPricing,
        child: _buildBody(context, controller),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PaymentController controller) {
    if (controller.isLoading && controller.packages.isEmpty) {
      return const LoadingSkeletonList(itemCount: 4, itemHeight: 170);
    }

    if (controller.error != null && controller.packages.isEmpty) {
      return ErrorState(
        message: context.tr(controller.error!),
        onRetry: () => controller.fetchPackages(),
      );
    }

    if (controller.packages.isEmpty) {
      return EmptyState(
        title: context.tr('noPackages'),
        message: context.tr('noPackagesDesc'),
        icon: Icons.generating_tokens_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        const _PricingHero(),
        const SizedBox(height: AppSizes.lg),
        if (controller.currentPayment != null) ...[
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primaryTeal,
              ),
              title: Text(
                context.tr('activePayment'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(context.tr('resumePaymentDesc')),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => Navigator.of(context).pushNamed(RouteNames.checkout),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
        if (controller.isUsingGatewayFallback) ...[
          _PaymentNotice(
            icon: Icons.info_outline_rounded,
            color: AppColors.info,
            title: context.tr('usingDefaultBankTransfer'),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
        _PaymentMethodCard(
          selectedGateway: _selectedGateway,
          gateways: controller.enabledGateways,
          onChanged: (value) => setState(() => _selectedGateway = value),
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          context.tr('choosePackage'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ...controller.packages.map(
          (pkg) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: TokenPackageCard(
              package: pkg,
              isLoading: controller.isLoading,
              isEnabled: controller.hasAvailablePaymentMethod,
              onBuy: controller.hasAvailablePaymentMethod
                  ? () => _buy(pkg.id)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _PricingHero extends StatelessWidget {
  const _PricingHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroIcon(),
          const SizedBox(height: AppSizes.md),
          Text(
            context.tr('powerAiScans'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              height: 1.12,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('pricingHeroDesc'),
            style: const TextStyle(
              color: Colors.white70,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: const Icon(
        Icons.receipt_long_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String selectedGateway;
  final List<String> gateways;
  final ValueChanged<String> onChanged;

  const _PaymentMethodCard({
    required this.selectedGateway,
    required this.gateways,
    required this.onChanged,
  });

  String _title(BuildContext context, String gateway) {
    return switch (gateway) {
      'bank_transfer' => context.tr('vietQrBankTransfer'),
      'vnpay' => context.tr('vnpay'),
      _ => context.tr('paymentMethod'),
    };
  }

  String _subtitle(BuildContext context, String gateway) {
    return switch (gateway) {
      'bank_transfer' => context.tr('vietQrBankTransferDesc'),
      'vnpay' => context.tr('vnpayDesc'),
      _ => context.tr('enabledPaymentMethodDesc'),
    };
  }

  IconData _icon(String gateway) {
    return switch (gateway) {
      'bank_transfer' => Icons.account_balance_rounded,
      'vnpay' => Icons.payments_outlined,
      _ => Icons.account_balance_wallet_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
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
                        context.tr('paymentMethod'),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.tr('paymentMethodDesc'),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            if (gateways.isEmpty)
              _PaymentNotice(
                icon: Icons.block_rounded,
                color: AppColors.danger,
                title: context.tr('noPaymentMethodAvailable'),
                message: context.tr('noPaymentMethodAvailableDesc'),
              )
            else
              ...gateways.asMap().entries.map((entry) {
                final gateway = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == gateways.length - 1 ? 0 : AppSizes.md,
                  ),
                  child: _GatewayTile(
                    value: gateway,
                    selectedGateway: selectedGateway,
                    title: _title(context, gateway),
                    subtitle: _subtitle(context, gateway),
                    badge: context.tr('available'),
                    icon: _icon(gateway),
                    accent: gateway == 'bank_transfer'
                        ? AppColors.info
                        : AppColors.primaryTeal,
                    onChanged: onChanged,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _PaymentNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? message;

  const _PaymentNotice({
    required this.icon,
    required this.color,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(message!, style: const TextStyle(height: 1.35)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GatewayTile extends StatelessWidget {
  final String value;
  final String selectedGateway;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color accent;
  final ValueChanged<String> onChanged;

  const _GatewayTile({
    required this.value,
    required this.selectedGateway,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedGateway == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? accent
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final background = selected
        ? accent.withOpacity(isDark ? 0.16 : 0.09)
        : (isDark ? AppColors.bgDark.withOpacity(0.42) : AppColors.bgLight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        boxShadow: selected && !isDark
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(selected ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: accent.withOpacity(selected ? 0.22 : 0.10),
                    ),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(selected ? 0.16 : 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? accent
                          : (isDark
                                ? AppColors.borderDark
                                : AppColors.slate300),
                      width: 1.4,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
