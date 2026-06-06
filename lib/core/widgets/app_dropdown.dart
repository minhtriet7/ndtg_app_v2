import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final String? helperText;
  final String? errorText;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = errorText != null
        ? AppColors.danger
        : isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: AppSizes.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: enabled
                ? isDark
                ? AppColors.cardDark
                : Colors.white
                : isDark
                ? AppColors.bgDark
                : AppColors.slate100,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: borderColor),
            boxShadow: !isDark && enabled
                ? [BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 12, offset: const Offset(0, 6))]
                : null,
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 19, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    items: items,
                    onChanged: enabled ? onChanged : null,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    hint: hint == null
                        ? null
                        : Text(
                      hint!,
                      style: TextStyle(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null || helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText ?? helperText!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: errorText != null
                  ? AppColors.danger
                  : isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ],
    );
  }
}
