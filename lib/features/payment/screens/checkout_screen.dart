import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/payment_controller.dart';
import '../widgets/qr_payment_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPolling());
  }

  void _startPolling() {
    final controller = context.read<PaymentController>();
    final payment = controller.currentPayment;
    if (payment == null || payment.id.isEmpty) return;

    controller.startPollingPaymentStatus(
      paymentId: payment.id,
      onSuccess: _handleSuccess,
      onFailed: _handleFailure,
    );
  }

  void _handleFailure() {
    if (!mounted) return;
    final error =
        context.read<PaymentController>().error ?? 'paymentFailedOrExpired';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(error)),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  Future<void> _checkStatusNow() async {
    final controller = context.read<PaymentController>();
    await controller.checkPaymentStatusNow(
      onSuccess: _handleSuccess,
      onFailed: _handleFailure,
    );

    if (!mounted || controller.error != 'paymentStatusCheckError') return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('paymentStatusCheckError')),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _handleSuccess() async {
    if (!mounted) return;
    final authController = context.read<AuthController>();
    final paymentController = context.read<PaymentController>();

    await authController.checkAuthStatus();
    await paymentController.fetchTransactions();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: AppCard(
          hasBorder: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                context.tr('paymentCompleted'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('paymentCompletedDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                text: context.tr('backToDashboard'),
                onPressed: () async {
                  await paymentController.clearCheckout();
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    // Keep controller state safe, but stop periodic polling when leaving checkout.
    try {
      context.read<PaymentController>().stopPolling();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();
    final payment = controller.currentPayment;

    if (payment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('payment'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.textMutedLight,
                    size: 56,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    context.tr('noActiveCheckout'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('choosePackageFirst'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  AppButton(
                    text: context.tr('back'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        controller.stopPolling();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.tr('payment'))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: QrPaymentCard(
            payment: payment,
            isPolling: controller.isPolling,
            isCheckingStatus: controller.isCheckingStatus,
            status: controller.latestPaymentStatus,
            onCheckStatus: _checkStatusNow,
            onBack: () {
              controller.stopPolling();
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
