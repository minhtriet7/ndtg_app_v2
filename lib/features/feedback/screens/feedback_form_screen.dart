import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
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
        const SnackBar(
          content: Text('Feedback submitted. Thank you for helping improve BanknoteAI.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else if (controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error!),
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
      appBar: AppBar(title: const Text('Send Feedback')),
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
                        color: AppColors.primaryTeal.withOpacity(isDark ? 0.08 : 0.20),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.forum_rounded, color: Colors.white, size: 36),
                      SizedBox(height: AppSizes.md),
                      Text(
                        'Share product feedback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: AppSizes.sm),
                      Text(
                        'Report recognition issues, suggest features, or tell us how the workflow feels.',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'How was your experience?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rate your latest BanknoteAI session.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      RatingSelector(
                        rating: _rating,
                        onRatingChanged: (value) => setState(() => _rating = value),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppDropdown<String>(
                        label: 'Feedback type',
                        value: _type,
                        prefixIcon: Icons.tune_rounded,
                        items: const [
                          DropdownMenuItem(value: 'general', child: Text('General feedback')),
                          DropdownMenuItem(value: 'bug', child: Text('Bug report')),
                          DropdownMenuItem(value: 'recognition', child: Text('Recognition issue')),
                          DropdownMenuItem(value: 'suggestion', child: Text('Feature suggestion')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _type = value);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: 'Message',
                        hint: 'Describe what happened or what we should improve...',
                        controller: _messageController,
                        maxLines: 6,
                        validator: (value) => Validators.validateRequired(value, fieldName: 'Message'),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AppButton(
                        text: 'Submit feedback',
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
