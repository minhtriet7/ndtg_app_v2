import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../models/payment_model.dart';

class QrPaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final bool isPolling;
  final bool isCheckingStatus;
  final String status;
  final VoidCallback onCheckStatus;
  final VoidCallback onBack;

  const QrPaymentCard({
    super.key,
    required this.payment,
    required this.isPolling,
    required this.isCheckingStatus,
    required this.status,
    required this.onCheckStatus,
    required this.onBack,
  });

  void _copy(BuildContext context, String value, String label) {
    if (value.isEmpty) return;

    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.tr(label)} ${context.tr('copied')}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          hasBorder: false,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(
                    isDark ? 0.08 : 0.20,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.white,
                  size: 38,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  context.tr('completeBankTransfer'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  context.tr('scanVietQrDesc'),
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  context.tr('scanVietQr'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _VietQrView(payment: payment),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              _InfoRow(
                label: context.tr('amount'),
                value: MoneyFormatter.formatVnd(payment.amount),
                important: true,
                onTap: () =>
                    _copy(context, payment.amount.toStringAsFixed(0), 'amount'),
              ),
              _InfoRow(
                label: context.tr('transferContent'),
                value: payment.transferContent,
                important: true,
                onTap: () =>
                    _copy(context, payment.transferContent, 'transferContent'),
              ),
              if (payment.accountNumber.isNotEmpty)
                _InfoRow(
                  label: context.tr('accountNumber'),
                  value: payment.accountNumber,
                  onTap: () =>
                      _copy(context, payment.accountNumber, 'accountNumber'),
                ),
              if (payment.bankName.isNotEmpty)
                _InfoRow(
                  label: context.tr('bankName'),
                  value: payment.bankName,
                ),
              if (payment.accountName.isNotEmpty)
                _InfoRow(
                  label: context.tr('accountName'),
                  value: payment.accountName,
                ),
              const SizedBox(height: AppSizes.lg),
              _PaymentStatusCard(status: status, isPolling: isPolling),
              const SizedBox(height: AppSizes.md),
              AppButton(
                text: context.tr('checkPayment'),
                icon: Icons.refresh_rounded,
                isLoading: isCheckingStatus,
                onPressed: isCheckingStatus ? null : onCheckStatus,
              ),
              const SizedBox(height: AppSizes.sm),
              AppButton(
                text: context.tr('back'),
                type: ButtonType.outline,
                onPressed: onBack,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VietQrView extends StatelessWidget {
  final PaymentModel payment;

  const _VietQrView({required this.payment});

  @override
  Widget build(BuildContext context) {
    final imageUrl = payment.qrImageUrl;

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Image.network(
          imageUrl,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return const SizedBox(
              width: 220,
              height: 220,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: AppColors.primaryTeal,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _QrPayloadFallback(payment: payment);
          },
        ),
      );
    }

    return _QrPayloadFallback(payment: payment);
  }
}

class _QrPayloadFallback extends StatelessWidget {
  final PaymentModel payment;

  const _QrPayloadFallback({required this.payment});

  @override
  Widget build(BuildContext context) {
    final payload = payment.effectiveQrData;

    if (payload.isNotEmpty) {
      return QrImageView(
        data: payload,
        version: QrVersions.auto,
        size: 220,
        backgroundColor: Colors.white,
      );
    }

    return SizedBox(
      width: 220,
      height: 220,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 58,
                color: AppColors.textMutedLight,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                context.tr('qrUnavailable'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('qrUnavailableDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMutedLight,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentStatusCard extends StatelessWidget {
  final String status;
  final bool isPolling;

  const _PaymentStatusCard({required this.status, required this.isPolling});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final isSuccess =
        normalized == 'completed' ||
        normalized == 'success' ||
        normalized == 'paid';
    final isFailure =
        normalized == 'failed' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'expired';
    final color = isSuccess
        ? AppColors.success
        : (isFailure ? AppColors.danger : AppColors.warning);
    final icon = isSuccess
        ? Icons.check_circle_rounded
        : (isFailure ? Icons.error_rounded : Icons.schedule_rounded);
    final statusLabel = isSuccess
        ? context.tr('paymentSuccessful')
        : (isFailure
              ? context.tr('paymentFailed')
              : context.tr('paymentWaiting'));

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: isPolling && !isSuccess && !isFailure
                ? CircularProgressIndicator(strokeWidth: 2.4, color: color)
                : Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('paymentStatus'),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool important;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.label,
    required this.value,
    this.important = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: important
                ? AppColors.primaryTeal.withOpacity(0.08)
                : (isDark ? AppColors.bgDark : AppColors.bgLight),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: important
                  ? AppColors.primaryTeal.withOpacity(0.18)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: important ? FontWeight.w900 : FontWeight.w800,
                    color: important ? AppColors.primaryTeal : null,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppColors.textMutedLight,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
