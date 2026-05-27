import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentController>().fetchPackages();
    });
  }

  Future<void> _buy(String packageId) async {
    final controller = context.read<PaymentController>();
    final success = await controller.initiatePayment(packageId);

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
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(PaymentController controller) {
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
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
              SizedBox(height: AppSizes.md),
              Text(
                'Power your AI scans',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
              ),
              SizedBox(height: 6),
              Text(
                'Each recognition uses system tokens for the multi-agent AI pipeline.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
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
