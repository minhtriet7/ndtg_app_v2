import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../controllers/payment_controller.dart';
import '../widgets/transaction_item_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentController>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: () => controller.fetchTransactions(),
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(PaymentController controller) {
    if (controller.isLoading && controller.transactions.isEmpty) {
      return const LoadingSkeletonList(itemCount: 6, itemHeight: 94);
    }

    if (controller.error != null && controller.transactions.isEmpty) {
      return ErrorState(message: controller.error!, onRetry: () => controller.fetchTransactions());
    }

    if (controller.transactions.isEmpty) {
      return const EmptyState(
        title: 'No transactions yet',
        message: 'Your top-up and payment history will appear here.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.lg),
      itemCount: controller.transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) => TransactionItemCard(transaction: controller.transactions[index]),
    );
  }
}
