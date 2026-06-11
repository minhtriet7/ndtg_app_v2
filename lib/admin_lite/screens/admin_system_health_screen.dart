import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/json_helper.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../controllers/admin_lite_controller.dart';

class AdminSystemHealthScreen extends StatefulWidget {
  const AdminSystemHealthScreen({super.key});

  @override
  State<AdminSystemHealthScreen> createState() =>
      _AdminSystemHealthScreenState();
}

class _AdminSystemHealthScreenState extends State<AdminSystemHealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLiteController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminLiteController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.loadDashboard,
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(AdminLiteController controller) {
    if (controller.isLoading && controller.systemHealth.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: const [
          LoadingSkeleton(height: 150, borderRadius: AppSizes.radiusXl),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 96, borderRadius: AppSizes.radiusXl),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 96, borderRadius: AppSizes.radiusXl),
        ],
      );
    }

    if (controller.error != null && controller.systemHealth.isEmpty) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.loadDashboard,
      );
    }

    final health = controller.systemHealth;
    final status = _readStatus(health, [
      'status',
      'system_status',
      'health.status',
    ], fallback: controller.dashboard.systemStatus);

    final database = _readStatus(health, [
      'database',
      'database.status',
      'db',
      'db.status',
      'mongodb',
      'mongodb.status',
    ]);

    final api = _readStatus(health, [
      'api',
      'api.status',
      'backend',
      'backend.status',
      'server',
      'server.status',
    ], fallback: status);

    final ai = _readStatus(health, [
      'ai',
      'ai.status',
      'agents',
      'agents.status',
      'recognition',
      'recognition.status',
    ]);

    final rawJson = const JsonEncoder.withIndent('  ').convert(health);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          hasBorder: false,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.monitor_heart_outlined,
                  color: Colors.white,
                  size: 38,
                ),
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Backend health overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Live status summary from the real admin system endpoint.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                AppBadge(
                  text: status,
                  status: _statusBadge(status),
                  uppercase: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _HealthTile(title: 'API Service', value: api, icon: Icons.api_outlined),
        const SizedBox(height: AppSizes.md),
        _HealthTile(title: 'Database', value: database, icon: Icons.storage_outlined),
        const SizedBox(height: AppSizes.md),
        _HealthTile(title: 'AI Pipeline', value: ai, icon: Icons.smart_toy_outlined),
        const SizedBox(height: AppSizes.xl),
        AppCard(
          backgroundColor: const Color(0xFF020617),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Raw Health Payload',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                health.isEmpty ? 'No health payload returned.' : rawJson,
                style: const TextStyle(
                  color: Color(0xFFD1FAE5),
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _readStatus(
      Map<String, dynamic> json,
      List<String> paths, {
        String fallback = 'unknown',
      }) {
    for (final path in paths) {
      final value = JsonHelper.getValue(json, [path]);
      final text = value?.toString().trim();

      if (text != null && text.isNotEmpty) return text;
    }

    return fallback.trim().isEmpty ? 'unknown' : fallback;
  }

  static BadgeStatus _statusBadge(String status) {
    final value = status.toLowerCase();

    if (['ok', 'healthy', 'success', 'online', 'running', 'up']
        .contains(value)) {
      return BadgeStatus.success;
    }

    if (['warning', 'degraded', 'partial', 'slow'].contains(value)) {
      return BadgeStatus.warning;
    }

    if (['failed', 'error', 'offline', 'down', 'unhealthy'].contains(value)) {
      return BadgeStatus.error;
    }

    return BadgeStatus.neutral;
  }
}

class _HealthTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HealthTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final status = AdminSystemHealthScreenStateHelper.statusBadge(value);
    final color = status == BadgeStatus.success
        ? AppColors.success
        : status == BadgeStatus.warning
        ? AppColors.warning
        : status == BadgeStatus.error
        ? AppColors.danger
        : AppColors.primaryTeal;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AppBadge(
            text: value,
            status: status,
            uppercase: false,
          ),
        ],
      ),
    );
  }
}

class AdminSystemHealthScreenStateHelper {
  static BadgeStatus statusBadge(String status) {
    final value = status.toLowerCase();

    if (['ok', 'healthy', 'success', 'online', 'running', 'up']
        .contains(value)) {
      return BadgeStatus.success;
    }

    if (['warning', 'degraded', 'partial', 'slow'].contains(value)) {
      return BadgeStatus.warning;
    }

    if (['failed', 'error', 'offline', 'down', 'unhealthy'].contains(value)) {
      return BadgeStatus.error;
    }

    return BadgeStatus.neutral;
  }
}