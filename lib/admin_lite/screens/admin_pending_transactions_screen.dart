import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../controllers/admin_lite_controller.dart';
import '../models/admin_transaction_model.dart';

class AdminPendingTransactionsScreen extends StatefulWidget {
  const AdminPendingTransactionsScreen({super.key});

  @override
  State<AdminPendingTransactionsScreen> createState() =>
      _AdminPendingTransactionsScreenState();
}

class _AdminPendingTransactionsScreenState
    extends State<AdminPendingTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLiteController>().loadPendingTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminLiteController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('pendingTransactions')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadPendingTransactions,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.loadPendingTransactions,
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(AdminLiteController controller) {
    if (controller.isLoading && controller.pendingTransactions.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.md),
          child: LoadingSkeleton(height: 180, borderRadius: AppSizes.radiusXl),
        ),
      );
    }

    if (controller.error != null && controller.pendingTransactions.isEmpty) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.loadPendingTransactions,
      );
    }

    if (controller.pendingTransactions.isEmpty) {
      return EmptyState(
        title: context.tr('noPendingPayments'),
        message: context.tr('noPendingPaymentsDesc'),
        icon: Icons.verified_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.xxl,
      ),
      itemCount: controller.pendingTransactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        return _TransactionCard(
          transaction: controller.pendingTransactions[index],
          controller: controller,
        );
      },
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final AdminTransactionModel transaction;
  final AdminLiteController controller;

  const _TransactionCard({required this.transaction, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.transactionCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: transaction.status,
                status: BadgeStatus.warning,
                uppercase: false,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _InfoRow(
            label: context.tr('package'),
            value: transaction.packageName,
          ),
          _InfoRow(
            label: context.tr('amount'),
            value: MoneyFormatter.formatVnd(transaction.amount),
            highlight: true,
          ),
          _InfoRow(
            label: context.tr('tokens'),
            value:
                '+${transaction.tokensAdded} ${context.tr('tokens').toLowerCase()}',
          ),
          _InfoRow(
            label: context.tr('gateway'),
            value: transaction.gateway.toUpperCase(),
          ),
          _InfoRow(
            label: context.tr('created'),
            value: DateFormatter.formatDateTime(transaction.createdAt),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isActionLoading
                      ? null
                      : () => _confirmCancel(context),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.tr('cancel')),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isActionLoading
                      ? null
                      : () => _confirmPaid(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    controller.isActionLoading
                        ? context.tr('saving')
                        : context.tr('markPaid'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPaid(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: context.tr('markPaymentPaidTitle'),
      message: context.tr('markPaymentPaidDesc'),
      confirmText: context.tr('markPaid'),
    );

    if (ok != true || !context.mounted) return;

    final success = await controller.markTransactionPaid(transaction.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.tr('transactionMarkedPaid')
              : controller.error ?? context.tr('actionFailed'),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: context.tr('cancelTransactionTitle'),
      message: context.tr('cancelTransactionDesc'),
      confirmText: context.tr('cancelTransaction'),
    );

    if (ok != true || !context.mounted) return;

    final success = await controller.cancelTransaction(transaction.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.tr('transactionCancelled')
              : controller.error ?? context.tr('actionFailed'),
        ),
      ),
    );
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('back')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: highlight
                    ? AppColors.primaryTeal
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
