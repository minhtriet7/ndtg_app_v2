import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
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
      builder: (_) => CurrencyPickerSheet(currencies: currencies, selectedCurrency: selectedCurrency),
    );
    if (selected != null) onCurrencyChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: readOnly
                    ? Text(
                  valueText ?? '0',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 28, fontWeight: FontWeight.w900),
                )
                    : TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: onAmountChanged,
                  style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 28, fontWeight: FontWeight.w900),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '0', isDense: true),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              InkWell(
                onTap: () => _openPicker(context),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                  decoration: BoxDecoration(color: AppColors.primaryTeal.withOpacity(0.10), borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(selectedCurrency?.targetCurrency ?? '---', style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryTeal),
                    ],
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
