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
        const SnackBar(content: Text('Feedback submitted. Thank you!'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else if (controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error!), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FeedbackController>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'How was your experience?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your feedback helps us improve the AI recognition workflow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondaryLight),
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
                  hint: 'Tell us what happened or what we should improve...',
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
      ),
    );
  }
}
