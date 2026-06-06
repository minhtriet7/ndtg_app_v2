import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../models/payment_model.dart';

class QrPaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final bool isPolling;
  final VoidCallback onCancel;

  const QrPaymentCard({
    super.key,
    required this.payment,
    required this.isPolling,
    required this.onCancel,
  });

  void _copy(BuildContext context, String value, String label) {
    if (value.isEmpty) return;

    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied.'),
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
                  color: AppColors.primaryTeal.withOpacity(isDark ? 0.08 : 0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 38),
                SizedBox(height: AppSizes.md),
                Text(
                  'Complete secure bank transfer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: AppSizes.sm),
                Text(
                  'Scan the VietQR code and keep the transfer content unchanged for automatic confirmation.',
                  style: TextStyle(
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
                label: 'Amount',
                value: MoneyFormatter.formatVnd(payment.amount),
                important: true,
                onTap: () => _copy(context, payment.amount.toStringAsFixed(0), 'Amount'),
              ),
              _InfoRow(
                label: 'Transfer content',
                value: payment.transferContent,
                important: true,
                onTap: () => _copy(context, payment.transferContent, 'Transfer content'),
              ),
              if (payment.accountNumber.isNotEmpty)
                _InfoRow(
                  label: 'Account number',
                  value: payment.accountNumber,
                  onTap: () => _copy(context, payment.accountNumber, 'Account number'),
                ),
              if (payment.bankName.isNotEmpty)
                _InfoRow(label: 'Bank', value: payment.bankName),
              if (payment.accountName.isNotEmpty)
                _InfoRow(label: 'Account name', value: payment.accountName),
              const SizedBox(height: AppSizes.lg),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.warning.withOpacity(0.24)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: isPolling
                          ? const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.warning,
                      )
                          : const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    const Expanded(
                      child: Text(
                        'Waiting for bank confirmation. This page updates automatically.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppButton(
                text: 'Cancel checkout',
                type: ButtonType.outline,
                onPressed: onCancel,
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

    return const SizedBox(
      width: 220,
      height: 220,
      child: Center(
        child: Icon(
          Icons.qr_code_2_rounded,
          size: 96,
          color: AppColors.textMutedLight,
        ),
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
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
