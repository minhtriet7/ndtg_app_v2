import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class SelectedImagePreview extends StatelessWidget {
  final File image;
  final double height;

  const SelectedImagePreview({
    super.key,
    required this.image,
    this.height = 420,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.07),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.7,
              maxScale: 4,
              child: Container(
                color: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
                alignment: Alignment.center,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSizes.md,
            top: AppSizes.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withOpacity(0.88)
                    : Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.zoom_in_rounded,
                    color: AppColors.primaryTeal,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pinch to zoom',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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