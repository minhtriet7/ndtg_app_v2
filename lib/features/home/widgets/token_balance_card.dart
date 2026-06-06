import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../routes/route_names.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/home_controller.dart';

class TokenBalanceCard extends StatelessWidget {
  const TokenBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final balance = controller.userInfo?.tokenBalance ?? controller.stats.tokenBalance;
    final totalScans = controller.stats.totalScans;
    final successRate = controller.stats.successRate;

    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        boxShadow: [
          BoxShadow(color: AppColors.primaryTeal.withOpacity(0.26), blurRadius: 28, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Token Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: const Text('Multi-Agent AI', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormatter.formatToken(balance),
                style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900, height: 0.95, letterSpacing: -1.4),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('tokens', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              _MiniMetric(label: 'Scans', value: MoneyFormatter.formatToken(totalScans)),
              const SizedBox(width: 10),
              _MiniMetric(label: 'Success', value: '${successRate.toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  text: 'Top Up',
                  foreground: AppColors.primaryDarkTeal,
                  background: Colors.white,
                  onTap: () => Navigator.of(context).pushNamed(RouteNames.pricing),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _GlassButton(
                  text: 'History',
                  foreground: Colors.white,
                  background: Colors.white.withOpacity(0.08),
                  borderColor: Colors.white.withOpacity(0.46),
                  onTap: () => context.read<MainTabController>().goHistory(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String text;
  final Color foreground;
  final Color background;
  final Color? borderColor;
  final VoidCallback onTap;

  const _GlassButton({required this.text, required this.foreground, required this.background, this.borderColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: Text(text, style: TextStyle(color: foreground, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
