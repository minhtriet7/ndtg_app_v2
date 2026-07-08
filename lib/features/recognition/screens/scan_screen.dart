import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
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
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ImagePreviewScreen()));
      return;
    }

    if (controller.error != null && context.mounted) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final mutedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('banknoteScanner'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          116,
        ),
        children: [
          // Recognition workspace header.
          Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(
                    isDark ? 0.08 : 0.22,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('consensusScanner'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('uploadBanknote'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  context.tr('uploadDesc'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Upload zone with custom Viewfinder HUD
          AppCard(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('uploadZone'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  context.tr('uploadZoneDesc'),
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // Viewfinder Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121214) : AppColors.slate50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: CustomPaint(
                    painter: ViewfinderPainter(
                      color: AppColors.primaryTeal.withOpacity(
                        isDark ? 0.65 : 0.45,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withOpacity(
                                isDark ? 0.16 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryTeal.withOpacity(0.24),
                                width: 1.2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_enhance_rounded,
                              color: AppColors.primaryTeal,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            context.tr('scanNow'),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('uploadZoneDesc').split('.').first,
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: context.tr('camera'),
                                  icon: Icons.camera_alt_rounded,
                                  onPressed: () =>
                                      _handlePickImage(context, true),
                                ),
                              ),
                              const SizedBox(width: AppSizes.md),
                              Expanded(
                                child: AppButton(
                                  text: context.tr('gallery'),
                                  type: AppButtonType.secondary,
                                  icon: Icons.photo_library_rounded,
                                  onPressed: () =>
                                      _handlePickImage(context, false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Multi-Agent Flow Diagram
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('multiAgentFlow'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                _FlowStep(
                  number: '01',
                  title: context.tr('mlAgent'),
                  description: context.tr('mlAgentDesc'),
                  icon: Icons.memory_rounded,
                ),
                _FlowStep(
                  number: '02',
                  title: context.tr('llmAgent'),
                  description: context.tr('llmAgentDesc'),
                  icon: Icons.analytics_outlined,
                ),
                _FlowStep(
                  number: '03',
                  title: context.tr('visualSearch'),
                  description: context.tr('visualSearchDesc'),
                  icon: Icons.travel_explore_rounded,
                ),
                _FlowStep(
                  number: '04',
                  title: context.tr('aggregatorDecision'),
                  description: context.tr('aggregatorDecisionDesc'),
                  icon: Icons.gavel_rounded,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  final Color color;

  ViewfinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 22.0;
    const radius = 8.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(
          Offset(size.width, radius),
          radius: Radius.circular(radius),
        )
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..arcToPoint(
          Offset(radius, size.height),
          radius: Radius.circular(radius),
        )
        ..lineTo(cornerLength, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width - radius, size.height)
        ..arcToPoint(
          Offset(size.width, size.height - radius),
          radius: Radius.circular(radius),
        )
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlowStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final bool isLast;

  const _FlowStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    this.isLast = false,
  });

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
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(
                    isDark ? 0.16 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.primaryTeal.withOpacity(0.18),
                  ),
                ),
                child: Icon(icon, color: AppColors.primaryTeal, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#$number',
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
