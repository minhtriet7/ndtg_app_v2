import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_names.dart';
import '../controllers/recognition_controller.dart';
import '../widgets/selected_image_preview.dart';

class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final image = controller.selectedImage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('confirmImage'))),
      body: image == null
          ? const _NoImageState()
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        AppSizes.lg,
                        AppSizes.lg,
                        AppSizes.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PreviewHero(isDark: isDark),
                          const SizedBox(height: AppSizes.lg),
                          SelectedImagePreview(image: image),
                          const SizedBox(height: AppSizes.lg),
                          const _ScanNoticeCard(),
                        ],
                      ),
                    ),
                  ),
                  _BottomActionBar(isDark: isDark),
                ],
              ),
            ),
    );
  }
}

class _PreviewHero extends StatelessWidget {
  final bool isDark;

  const _PreviewHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      hasBorder: false,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.10 : 0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 42,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('readyForAnalysis'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('previewDescription'),
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
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

class _ScanNoticeCard extends StatelessWidget {
  const _ScanNoticeCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              context.tr('scanTokenNotice'),
              style: const TextStyle(height: 1.45, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final bool isDark;

  const _BottomActionBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: context.tr('changeImage'),
              type: AppButtonType.outline,
              icon: Icons.refresh_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            flex: 2,
            child: AppButton(
              text: context.tr('analyzeBanknote'),
              icon: Icons.image_search_rounded,
              onPressed: () {
                Navigator.of(context).pushNamed(RouteNames.processing);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoImageState extends StatelessWidget {
  const _NoImageState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.warning,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                context.tr('noSelectedImage'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                context.tr('chooseImageAgain'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                text: context.tr('backToUpload'),
                isFullWidth: false,
                type: AppButtonType.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
