import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/recognition_controller.dart';
import '../widgets/image_picker_card.dart';
import 'image_preview_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  Future<void> _handlePickImage(BuildContext context, bool fromCamera) async {
    final controller = context.read<RecognitionController>();
    final success = await controller.pickImage(fromCamera);

    if (success && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ImagePreviewScreen()),
      );
      return;
    }

    final error = controller.error;
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Banknote')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload a clear banknote image',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Our multi-agent pipeline will identify denomination, country, currency, and consensus confidence.',
                style: TextStyle(
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              AppCard(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.warning),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Text(
                        'Best results: flat note, high contrast background, no shadows, JPG/PNG/WEBP up to 5MB.',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Expanded(
                child: ImagePickerCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take a Photo',
                  subtitle: 'Use the device camera',
                  color: AppColors.primaryTeal,
                  onTap: () => _handlePickImage(context, true),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Expanded(
                child: ImagePickerCard(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Upload an existing image',
                  color: AppColors.info,
                  onTap: () => _handlePickImage(context, false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
