import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_formatter.dart';
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
      if (mounted) context.read<AdminLiteController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminLiteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Lite'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.loadDashboard,
        child: _buildBody(context, controller),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminLiteController controller) {
    if (controller.isLoading && controller.dashboard.totalUsers == 0) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: const [
          LoadingSkeleton(height: 170, borderRadius: AppSizes.radiusXl),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 120, borderRadius: AppSizes.radiusXl),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 120, borderRadius: AppSizes.radiusXl),
        ],
      );
    }

    if (controller.error != null && controller.dashboard.totalUsers == 0) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.loadDashboard,
      );
    }

    final dashboard = controller.dashboard;
    final pendingPayments = controller.pendingTransactions.length;
    final pendingFeedbacks = controller.pendingFeedbacks.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        132,
      ),
      children: [
        _AdminHero(controller: controller),
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Users',
                value: dashboard.totalUsers.toString(),
                subtitle: '${dashboard.activeUsers} active',
                icon: Icons.people_alt_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _MetricCard(
                title: 'Scans',
                value: dashboard.totalScans.toString(),
                subtitle: '${dashboard.completedScans} completed',
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
                value: pendingPayments.toString(),
                subtitle: 'real API list',
                icon: Icons.pending_actions_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: _MetricCard(
                title: 'Feedback',
                value: pendingFeedbacks.toString(),
                subtitle: 'unresolved',
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
          count: pendingPayments,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminPendingTransactionsScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _AdminActionTile(
          title: 'Pending Feedback',
          subtitle: 'Review user reports, suggestions, and support requests.',
          icon: Icons.feedback_outlined,
          color: AppColors.info,
          count: pendingFeedbacks,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminPendingFeedbackScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _AdminActionTile(
          title: 'System Health',
          subtitle: 'Check backend, database, and AI pipeline status.',
          icon: Icons.monitor_heart_outlined,
          color: AppColors.success,
          count: null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminSystemHealthScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminHero extends StatelessWidget {
  final AdminLiteController controller;

  const _AdminHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    final dashboard = controller.dashboard;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'System Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Live admin dashboard from BanknoteAI backend APIs.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WhiteStatusChip(text: dashboard.systemStatus),
              if (controller.lastLoadedAt != null)
                _WhiteStatusChip(
                  text:
                  'Updated ${DateFormatter.formatDateTime(controller.lastLoadedAt!.toIso8601String())}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteStatusChip extends StatelessWidget {
  final String text;

  const _WhiteStatusChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final label = text.trim().isEmpty ? 'unknown' : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  MoneyFormatter.formatVnd(amount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
          const AppBadge(
            text: 'API',
            status: BadgeStatus.success,
            uppercase: false,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (count != null) ...[
            AppBadge(
              text: count.toString(),
              status: count! > 0 ? BadgeStatus.warning : BadgeStatus.success,
            ),
            const SizedBox(width: AppSizes.sm),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ],
      ),
    );
  }
}