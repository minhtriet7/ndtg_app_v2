import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../models/currency_rate_model.dart';
import 'currency_picker_sheet.dart';

class CurrencyInputBox extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String? valueText;
  final CurrencyRateModel? selectedCurrency;
  final List<CurrencyRateModel> currencies;
  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<CurrencyRateModel> onCurrencyChanged;
  final bool readOnly;

  const CurrencyInputBox({
    super.key,
    required this.title,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
    this.controller,
    this.valueText,
    this.onAmountChanged,
    this.readOnly = false,
  });

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<CurrencyRateModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CurrencyPickerSheet(
        currencies: currencies,
        selectedCurrency: selectedCurrency,
      ),
    );

    if (selected != null) onCurrencyChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: readOnly
                    ? Text(
                  valueText ?? '0',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                )
                    : TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: onAmountChanged,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '0',
                    hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openPicker(context),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withOpacity(isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.primaryTeal.withOpacity(0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            (selectedCurrency?.targetCurrency ?? '-').substring(0, 1),
                            style: const TextStyle(
                              color: AppColors.primaryTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          selectedCurrency?.targetCurrency ?? '---',
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
