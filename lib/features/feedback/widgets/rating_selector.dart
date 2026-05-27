import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const RatingSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: List.generate(5, (index) {
        final value = index + 1;
        final active = value <= rating;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onRatingChanged(value),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              active ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: active ? AppColors.warning : AppColors.textMutedLight,
            ),
          ),
        );
      }),
    );
  }
}
