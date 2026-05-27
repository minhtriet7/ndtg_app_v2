import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/recognition_controller.dart';
import '../widgets/selected_image_preview.dart';
import 'processing_screen.dart';

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final image = controller.selectedImage;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Image')),
      body: image == null
          ? const Center(child: Text('No selected image found.'))
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    SelectedImagePreview(image: image),
                    const SizedBox(height: AppSizes.lg),
                    const AppCard(
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.info),
                          SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Text(
                              'Starting a scan consumes 1 system token. Make sure the image is sharp and the banknote is fully visible.',
                              style: TextStyle(height: 1.45, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Change',
                      type: AppButtonType.outline,
                      icon: Icons.refresh_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Analyze Now',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProcessingScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
