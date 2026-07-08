import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/network/response_parser.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/home_controller.dart';

class RecentScansList extends StatelessWidget {
  const RecentScansList({super.key});

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<HomeController>().recentScans;

    if (scans.isEmpty) {
      return EmptyState(
        title: context.tr('noRecentScans'),
        message: context.tr('noRecentScansDesc'),
        icon: Icons.receipt_long_rounded,
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < scans.length; i++) ...[
            RecentScanCard(scan: scans[i]),
            if (i != scans.length - 1)
              Divider(
                height: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
          ],
        ],
      ),
    );
  }
}

class RecentScanCard extends StatelessWidget {
  final Map<String, dynamic> scan;

  const RecentScanCard({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageUrl = _asString(
      ResponseParser.getValue(scan, [
        'uploaded_image_url',
        'image_url',
        'thumbnail_url',
        'image',
      ], defaultValue: ''),
    );

    final denomination = ResponseParser.getValue(scan, [
      'final_result.final_denomination',
      'final_result.menh_gia',
      'final_result.denomination',
      'denomination',
    ], defaultValue: '').toString();

    final currency = ResponseParser.getValue(scan, [
      'final_result.currency',
      'final_result.loai_tien',
      'currency',
      'target_currency',
    ], defaultValue: '').toString();

    final country = ResponseParser.getValue(scan, [
      'final_result.country',
      'final_result.quoc_gia',
      'country',
    ], defaultValue: '').toString();

    final createdAt = ResponseParser.getValue(scan, [
      'created_at',
      'createdAt',
      'time',
      'updated_at',
    ], defaultValue: '').toString();

    final status = ResponseParser.getValue(scan, [
      'status',
      'state',
    ], defaultValue: 'completed').toString();

    final badgeStatus = _badgeStatus(status);
    final title = [
      denomination,
      currency,
    ].where((e) => e.trim().isNotEmpty).join(' ');
    final displayTitle = title.trim().isEmpty
        ? context.tr('unknownBanknote')
        : title;

    return InkWell(
      onTap: () => context.read<MainTabController>().goHistory(),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            NetworkImageView(
              imageUrl: imageUrl,
              width: 58,
              height: 58,
              borderRadius: AppSizes.radiusMd,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    country.isEmpty
                        ? context.tr('countryNotConfirmed')
                        : country,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormatter.formatTimeAgo(createdAt),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppBadge(text: context.trStatus(status), status: badgeStatus),
          ],
        ),
      ),
    );
  }

  String _asString(dynamic value) => value == null ? '' : value.toString();

  BadgeStatus _badgeStatus(String value) {
    final normalized = value.toLowerCase();
    if (['completed', 'done', 'success'].contains(normalized)) {
      return BadgeStatus.success;
    }
    if (['failed', 'error'].contains(normalized)) return BadgeStatus.error;
    if ([
      'needs_review',
      'review',
      'pending',
      'processing',
    ].contains(normalized)) {
      return BadgeStatus.warning;
    }
    return BadgeStatus.neutral;
  }
}
