import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/network_image_view.dart';
import '../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool? isAccountActive;

  const ProfileHeader({super.key, required this.user, this.isAccountActive});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      hasBorder: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.12 : 0.24),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(user: user),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('banknoteAiAccount'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                _HeaderChip(
                  text: user.role.toUpperCase(),
                  strong: user.isAdmin,
                ),
                _HeaderChip(text: user.provider.toUpperCase()),
                if (isAccountActive != null)
                  _HeaderChip(
                    text: context.tr(
                      isAccountActive! ? 'accountActive' : 'accountInactive',
                    ),
                    color: isAccountActive!
                        ? AppColors.success
                        : AppColors.danger,
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.17),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: Colors.white.withOpacity(0.28)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: context.tr('tokens'),
                      value: MoneyFormatter.formatToken(user.tokenBalance),
                      icon: Icons.generating_tokens_rounded,
                    ),
                  ),
                  Container(width: 1, height: 44, color: Colors.white30),
                  Expanded(
                    child: _Metric(
                      label: context.tr('scansLabel'),
                      value: MoneyFormatter.formatToken(user.totalScans),
                      icon: Icons.document_scanner_rounded,
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

class _Avatar extends StatelessWidget {
  final UserModel user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl.isNotEmpty) {
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.95), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: NetworkImageView(
            imageUrl: user.avatarUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            borderRadius: 100,
          ),
        ),
      );
    }

    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        user.initials,
        style: const TextStyle(
          color: AppColors.primaryTeal,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String text;
  final bool strong;
  final Color? color;

  const _HeaderChip({required this.text, this.strong = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color:
            color?.withOpacity(0.24) ??
            (strong
                ? Colors.white.withOpacity(0.24)
                : Colors.white.withOpacity(0.16)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              color?.withOpacity(0.55) ??
              Colors.white.withOpacity(strong ? 0.45 : 0.25),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
