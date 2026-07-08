import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../localization/app_localizations.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorState({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.danger.withOpacity(0.18)),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title ?? context.tr('somethingWentWrong'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 22),
              AppButton(
                text: retryText ?? context.tr('retry'),
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
