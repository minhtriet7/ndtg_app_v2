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
    final normalized = status.toLowerCase();
    if (normalized == 'resolved') return BadgeStatus.success;
    if (normalized == 'closed') return BadgeStatus.neutral;
    if (normalized == 'rejected') return BadgeStatus.error;
    return BadgeStatus.warning;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FeedbackController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New feedback'),
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.feedbackForm),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: () => controller.fetchFeedbacks(),
        child: _buildBody(controller, isDark),
      ),
    );
  }

  Widget _buildBody(FeedbackController controller, bool isDark) {
    if (controller.isLoading && controller.feedbacks.isEmpty) {
      return const LoadingSkeletonList(itemCount: 5, itemHeight: 132);
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
      padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, 104),
      itemCount: controller.feedbacks.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        if (index == 0) {
          return AppCard(
            padding: EdgeInsets.zero,
            hasBorder: false,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                gradient: AppColors.tealGradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent_rounded, color: Colors.white, size: 34),
                  SizedBox(height: AppSizes.md),
                  Text(
                    'Feedback center',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Track your reports, suggestions, and admin responses in one place.',
                    style: TextStyle(color: Colors.white70, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }

        return _FeedbackCard(
          feedback: controller.feedbacks[index - 1],
          status: _status,
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final BadgeStatus Function(String status) status;

  const _FeedbackCard({required this.feedback, required this.status});

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
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return Icon(
                      i < feedback.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: AppColors.warning,
                    );
                  }),
                ),
              ),
              const Spacer(),
              AppBadge(text: feedback.status, status: status(feedback.status), uppercase: false),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            feedback.message,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          if (feedback.adminReply.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.primaryTeal.withOpacity(0.14)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_agent_rounded, color: AppColors.primaryTeal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feedback.adminReply,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Text(
                DateFormatter.formatDateTime(feedback.createdAt),
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              ),
              const Spacer(),
              Text(
                feedback.type.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primaryTeal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
