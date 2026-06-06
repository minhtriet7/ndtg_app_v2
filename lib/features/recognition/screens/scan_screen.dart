import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/recognition_controller.dart';
import 'image_preview_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  Future<void> _handlePickImage(BuildContext context, bool fromCamera) async {
    final controller = context.read<RecognitionController>();
    final success = await controller.pickImage(fromCamera);

    if (success && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImagePreviewScreen()));
      return;
    }

    if (controller.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error!), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Banknote')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, 116),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
              boxShadow: [BoxShadow(color: AppColors.primaryTeal.withOpacity(0.24), blurRadius: 28, offset: const Offset(0, 14))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BanknoteAI Scanner', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                SizedBox(height: AppSizes.sm),
                Text('Upload Banknote Image', style: TextStyle(color: Colors.white, fontSize: 28, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                SizedBox(height: AppSizes.sm),
                Text('Analyze Southeast Asian banknotes with ML/DL, LLM reasoning, visual search, and aggregator voting.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          AppCard(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload zone', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSizes.xs),
                Text('Supports JPG, PNG, WEBP. Keep the full banknote visible and sharp.', style: TextStyle(color: mutedColor, fontSize: 13, height: 1.45)),
                const SizedBox(height: AppSizes.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgDark : AppColors.slate50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.slate300, width: 1.6, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(gradient: AppColors.tealGradient, borderRadius: BorderRadius.circular(22)),
                        child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text('Upload Banknote Image', style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Camera scan or gallery upload', style: TextStyle(color: mutedColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        children: [
                          Expanded(child: AppButton(text: 'Camera', icon: Icons.camera_alt_rounded, onPressed: () => _handlePickImage(context, true))),
                          const SizedBox(width: AppSizes.md),
                          Expanded(child: AppButton(text: 'Gallery', type: AppButtonType.secondary, icon: Icons.photo_library_rounded, onPressed: () => _handlePickImage(context, false))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Multi-Agent Flow', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSizes.md),
                const _FlowStep(number: '01', title: 'ML/DL Agent', description: 'Detects visual features and predicts denomination.'),
                const _FlowStep(number: '02', title: 'LLM Agent', description: 'Reads visible text and reasons over context.'),
                const _FlowStep(number: '03', title: 'Visual Search', description: 'Compares against external visual references.'),
                const _FlowStep(number: '04', title: 'Aggregator Decision', description: 'Uses majority vote to generate final result.', isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool isLast;

  const _FlowStep({required this.number, required this.title, required this.description, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.12), borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                child: Text(number, style: const TextStyle(color: AppColors.primaryTeal, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              if (!isLast)
                Expanded(child: Container(width: 1, margin: const EdgeInsets.symmetric(vertical: 6), color: isDark ? AppColors.borderDark : AppColors.borderLight)),
            ],
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(description, style: TextStyle(fontSize: 12.5, height: 1.35, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
