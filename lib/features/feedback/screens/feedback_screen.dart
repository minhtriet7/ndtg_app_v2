import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../routes/route_names.dart';
import '../controllers/feedback_controller.dart';
import '../models/feedback_model.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackController>().fetchFeedbacks();
    });
  }

  BadgeStatus _status(String status) {
    if (status == 'resolved') return BadgeStatus.success;
    if (status == 'closed') return BadgeStatus.neutral;
    if (status == 'rejected') return BadgeStatus.error;
    return BadgeStatus.warning;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FeedbackController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New'),
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.feedbackForm),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: () => controller.fetchFeedbacks(),
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(FeedbackController controller) {
    if (controller.isLoading && controller.feedbacks.isEmpty) {
      return const LoadingSkeletonList(itemCount: 5, itemHeight: 126);
    }

    if (controller.error != null && controller.feedbacks.isEmpty) {
      return ErrorState(message: controller.error!, onRetry: () => controller.fetchFeedbacks());
    }

    if (controller.feedbacks.isEmpty) {
      return const EmptyState(
        title: 'No feedback yet',
        message: 'Share your experience, report issues, or suggest improvements.',
        icon: Icons.chat_bubble_outline_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, 96),
      itemCount: controller.feedbacks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) => _FeedbackCard(feedback: controller.feedbacks[index], status: _status),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final BadgeStatus Function(String status) status;

  const _FeedbackCard({required this.feedback, required this.status});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < feedback.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18,
                      color: AppColors.warning,
                    );
                  }),
                ),
              ),
              AppBadge(text: feedback.status, status: status(feedback.status)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(feedback.message, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
          if (feedback.adminReply.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_agent_rounded, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feedback.adminReply, style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Text(
                DateFormatter.formatDateTime(feedback.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
              ),
              const Spacer(),
              Text(
                feedback.type.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMutedLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
