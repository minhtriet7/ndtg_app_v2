import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../controllers/admin_lite_controller.dart';
import '../models/admin_feedback_model.dart';

class AdminPendingFeedbackScreen extends StatefulWidget {
  const AdminPendingFeedbackScreen({super.key});

  @override
  State<AdminPendingFeedbackScreen> createState() =>
      _AdminPendingFeedbackScreenState();
}

class _AdminPendingFeedbackScreenState
    extends State<AdminPendingFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLiteController>().loadPendingFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminLiteController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('pendingFeedback')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadPendingFeedbacks,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.loadPendingFeedbacks,
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(AdminLiteController controller) {
    if (controller.isLoading && controller.pendingFeedbacks.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.md),
          child: LoadingSkeleton(height: 174, borderRadius: AppSizes.radiusXl),
        ),
      );
    }

    if (controller.error != null && controller.pendingFeedbacks.isEmpty) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.loadPendingFeedbacks,
      );
    }

    if (controller.pendingFeedbacks.isEmpty) {
      return EmptyState(
        title: context.tr('noPendingFeedback'),
        message: context.tr('noPendingFeedbackDesc'),
        icon: Icons.mark_chat_read_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.xxl,
      ),
      itemCount: controller.pendingFeedbacks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
      itemBuilder: (context, index) {
        return _FeedbackCard(
          feedback: controller.pendingFeedbacks[index],
          controller: controller,
        );
      },
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final AdminFeedbackModel feedback;
  final AdminLiteController controller;

  const _FeedbackCard({required this.feedback, required this.controller});

  @override
  Widget build(BuildContext context) {
    final priorityStatus = _priorityStatus(feedback.priority);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(
                  Icons.feedback_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormatter.formatDateTime(feedback.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                text: feedback.priority,
                status: priorityStatus,
                uppercase: false,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(
                text: feedback.type,
                status: BadgeStatus.info,
                uppercase: false,
              ),
              AppBadge(
                text: feedback.status,
                status: BadgeStatus.warning,
                uppercase: false,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < feedback.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            feedback.message.isEmpty
                ? context.tr('noMessageContent')
                : feedback.message,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isActionLoading
                      ? null
                      : () => _setHighPriority(context),
                  icon: const Icon(Icons.priority_high_rounded),
                  label: Text(context.tr('highPriority')),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isActionLoading
                      ? null
                      : () => _resolve(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    controller.isActionLoading
                        ? context.tr('saving')
                        : context.tr('resolve'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BadgeStatus _priorityStatus(String priority) {
    final value = priority.toLowerCase();

    if (value.contains('high') || value.contains('urgent')) {
      return BadgeStatus.error;
    }

    if (value.contains('low')) return BadgeStatus.neutral;

    return BadgeStatus.warning;
  }

  Future<void> _setHighPriority(BuildContext context) async {
    final success = await controller.updateFeedbackPriority(
      feedback.id,
      'high',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.tr('priorityUpdated')
              : controller.error ?? context.tr('actionFailed'),
        ),
      ),
    );
  }

  Future<void> _resolve(BuildContext context) async {
    final success = await controller.resolveFeedback(feedback.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.tr('feedbackResolved')
              : controller.error ?? context.tr('actionFailed'),
        ),
      ),
    );
  }
}
