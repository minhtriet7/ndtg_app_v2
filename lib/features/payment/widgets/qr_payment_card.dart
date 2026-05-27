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
      SnackBar(content: Text('$label copied.'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Scan QR to complete payment',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Open your banking app, scan the QR code, and keep the transfer content unchanged.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
          ),
          const SizedBox(height: AppSizes.lg),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: payment.effectiveQrData.isNotEmpty
                  ? QrImageView(
                data: payment.effectiveQrData,
                version: QrVersions.auto,
                size: 220,
              )
                  : const SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(Icons.qr_code_2_rounded, size: 96, color: AppColors.textMutedLight),
                ),
              ),
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
          if (payment.bankName.isNotEmpty) _InfoRow(label: 'Bank', value: payment.bankName),
          if (payment.accountName.isNotEmpty) _InfoRow(label: 'Account name', value: payment.accountName),
          const SizedBox(height: AppSizes.lg),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.warning.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: isPolling
                      ? const CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.warning)
                      : const Icon(Icons.schedule_rounded, color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Waiting for bank confirmation. This screen will update automatically.',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: important ? FontWeight.w900 : FontWeight.w700,
                    color: important ? AppColors.primaryTeal : null,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMutedLight),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
