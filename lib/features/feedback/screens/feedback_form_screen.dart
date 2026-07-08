import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/feedback_controller.dart';
import '../widgets/rating_selector.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 5;
  String _type = 'general';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = context.read<FeedbackController>();
    final success = await controller.submitFeedback(
      message: _messageController.text.trim(),
      rating: _rating,
      type: _type,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('feedbackSubmitted')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else if (controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(controller.error!)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FeedbackController>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('sendFeedback'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
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
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.forum_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        context.tr('shareProductFeedback'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        context.tr('shareProductFeedbackDesc'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr('experienceQuestion'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('rateLatestSession'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      RatingSelector(
                        rating: _rating,
                        onRatingChanged: (value) =>
                            setState(() => _rating = value),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppDropdown<String>(
                        label: context.tr('feedbackType'),
                        value: _type,
                        prefixIcon: Icons.tune_rounded,
                        items: [
                          DropdownMenuItem(
                            value: 'general',
                            child: Text(context.tr('feedbackGeneral')),
                          ),
                          DropdownMenuItem(
                            value: 'bug',
                            child: Text(context.tr('feedbackBug')),
                          ),
                          DropdownMenuItem(
                            value: 'recognition',
                            child: Text(context.tr('feedbackRecognition')),
                          ),
                          DropdownMenuItem(
                            value: 'suggestion',
                            child: Text(context.tr('feedbackSuggestion')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _type = value);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: context.tr('message'),
                        hint: context.tr('feedbackMessageHint'),
                        controller: _messageController,
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr('messageRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AppButton(
                        text: context.tr('submitFeedback'),
                        icon: Icons.send_rounded,
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
