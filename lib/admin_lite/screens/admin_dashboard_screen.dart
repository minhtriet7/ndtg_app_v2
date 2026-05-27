import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../controllers/admin_lite_controller.dart';
import 'admin_pending_feedback_screen.dart';
import 'admin_pending_transactions_screen.dart';
import 'admin_system_health_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLiteController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminLiteController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Lite'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.loadDashboard,
        child: _buildBody(context, controller, isDark),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      AdminLiteController controller,
      bool isDark,
      ) {
    if (controller.isLoading) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: const [
          LoadingSkeleton(height: 140, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 110, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 110, borderRadius: AppSizes.radiusLg),
        ],
      );
    }

    if (controller.error != null) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.loadDashboard,
      );
    }

    final dashboard = controller.dashboard;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 42),
              SizedBox(height: AppSizes.md),
              Text(
                'System Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSizes.xs),
              Text(
                'Monitor payments, feedback, health, and AI recognition activity.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),

        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Users',
                value: dashboard.totalUsers.toString(),
                icon: Icons.people_alt_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _MetricCard(
                title: 'Scans',
                value: dashboard.totalScans.toString(),
                icon: Icons.document_scanner_outlined,
                color: AppColors.primaryTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Pending Pay',
                value: dashboard.pendingTransactions.toString(),
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _MetricCard(
                title: 'Feedback',
                value: dashboard.pendingFeedbacks.toString(),
                icon: Icons.forum_outlined,
                color: AppColors.danger,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),
        _RevenueCard(amount: dashboard.totalRevenue),

        const SizedBox(height: AppSizes.xl),
        _AdminActionTile(
          title: 'Pending Transactions',
          subtitle: 'Review manual payments and token top-up invoices.',
          icon: Icons.receipt_long_outlined,
          color: AppColors.warning,
          count: controller.pendingTransactions.length,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminPendingTransactionsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.md),
        _AdminActionTile(
          title: 'Pending Feedback',
          subtitle: 'Review user reports, suggestions, and support requests.',
          icon: Icons.feedback_outlined,
          color: AppColors.info,
          count: controller.pendingFeedbacks.length,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminPendingFeedbackScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.md),
        _AdminActionTile(
          title: 'System Health',
          subtitle: 'Check backend, database, and service status.',
          icon: Icons.monitor_heart_outlined,
          color: AppColors.success,
          count: null,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminSystemHealthScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSizes.md),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textMutedLight,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final double amount;

  const _RevenueCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  MoneyFormatter.formatVnd(amount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
          const AppBadge(text: 'success', status: BadgeStatus.success),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          if (count != null)
            AppBadge(
              text: count.toString(),
              status: count! > 0 ? BadgeStatus.warning : BadgeStatus.success,
            ),
          const SizedBox(width: AppSizes.sm),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}