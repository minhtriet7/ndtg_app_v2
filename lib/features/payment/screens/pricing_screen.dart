import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
  String _selectedGateway = 'sepay';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentController>().fetchPackages();
    });
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
        SnackBar(content: Text(controller.error!), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Tokens'),
        actions: [
          IconButton(
            tooltip: 'Transactions',
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.transactions),
            icon: const Icon(Icons.receipt_long_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: () => controller.fetchPackages(),
        child: _buildBody(context, controller),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PaymentController controller) {
    if (controller.isLoading && controller.packages.isEmpty) {
      return const LoadingSkeletonList(itemCount: 4, itemHeight: 170);
    }

    if (controller.error != null && controller.packages.isEmpty) {
      return ErrorState(message: controller.error!, onRetry: () => controller.fetchPackages());
    }

    if (controller.packages.isEmpty) {
      return const EmptyState(
        title: 'No packages available',
        message: 'Token packages are not available right now. Please try again later.',
        icon: Icons.generating_tokens_outlined,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        const _PricingHero(),
        const SizedBox(height: AppSizes.lg),
        _PaymentMethodCard(
          selectedGateway: _selectedGateway,
          onChanged: (value) => setState(() => _selectedGateway = value),
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          'Choose a token package',
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
              onBuy: () => _buy(pkg.id),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroIcon(),
          SizedBox(height: AppSizes.md),
          Text(
            'Power your AI scans',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              height: 1.12,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Buy tokens to run the multi-agent recognition pipeline, save results, and review scan history.',
            style: TextStyle(
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
      child: const Icon(Icons.generating_tokens_rounded, color: Colors.white, size: 26),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String selectedGateway;
  final ValueChanged<String> onChanged;

  const _PaymentMethodCard({
    required this.selectedGateway,
    required this.onChanged,
  });

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
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
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
                        'Payment method',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Choose the checkout method that matches your backend gateway.',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
            _GatewayTile(
              value: 'sepay',
              selectedGateway: selectedGateway,
              title: 'VietQR / SePay',
              subtitle: 'Scan dynamic bank QR. Best for automatic confirmation.',
              badge: 'Recommended',
              icon: Icons.qr_code_2_rounded,
              accent: AppColors.primaryTeal,
              onChanged: onChanged,
            ),
            const SizedBox(height: AppSizes.md),
            _GatewayTile(
              value: 'bank_transfer',
              selectedGateway: selectedGateway,
              title: 'Bank Transfer',
              subtitle: 'Transfer by account number and exact invoice content.',
              badge: 'Manual',
              icon: Icons.account_balance_rounded,
              accent: AppColors.info,
              onChanged: onChanged,
            ),
            const SizedBox(height: AppSizes.md),
            _GatewayTile(
              value: 'mock',
              selectedGateway: selectedGateway,
              title: 'Sandbox / Mock',
              subtitle: 'For demo and testing when sandbox gateway is enabled.',
              badge: 'Test mode',
              icon: Icons.terminal_rounded,
              accent: AppColors.warning,
              onChanged: onChanged,
            ),
          ],
        ),
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
    final borderColor = selected ? accent : (isDark ? AppColors.borderDark : AppColors.borderLight);
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
                    border: Border.all(color: accent.withOpacity(selected ? 0.22 : 0.10)),
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
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                    border: Border.all(color: selected ? accent : (isDark ? AppColors.borderDark : AppColors.slate300), width: 1.4),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
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
