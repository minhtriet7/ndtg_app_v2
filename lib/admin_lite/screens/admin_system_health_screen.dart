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
  State<AdminSystemHealthScreen> createState() => _AdminSystemHealthScreenState();
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
            icon: const Icon(Icons.refresh),
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
    if (controller.isLoading) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: const [
          LoadingSkeleton(height: 130, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 90, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.md),
          LoadingSkeleton(height: 90, borderRadius: AppSizes.radiusLg),
        ],
      );
    }

    if (controller.error != null) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.loadDashboard,
      );
    }

    final health = controller.systemHealth;

    final status = JsonHelper.safeString(
      JsonHelper.getValue(health, ['status', 'system_status']),
      defaultValue: 'unknown',
    );

    final database = JsonHelper.safeString(
      JsonHelper.getValue(health, ['database', 'db.status', 'mongodb.status']),
      defaultValue: 'unknown',
    );

    final api = JsonHelper.safeString(
      JsonHelper.getValue(health, ['api', 'backend.status']),
      defaultValue: status,
    );

    final ai = JsonHelper.safeString(
      JsonHelper.getValue(health, ['ai', 'agents.status', 'recognition.status']),
      defaultValue: 'unknown',
    );

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.monitor_heart_outlined, color: AppColors.success, size: 40),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Backend Health Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSizes.xs),
              const Text(
                'Live status summary from the admin system health endpoint.',
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: AppSizes.md),
              AppBadge(
                text: status,
                status: _statusBadge(status),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _HealthTile(
          title: 'API Service',
          value: api,
          icon: Icons.api_outlined,
        ),
        const SizedBox(height: AppSizes.md),
        _HealthTile(
          title: 'Database',
          value: database,
          icon: Icons.storage_outlined,
        ),
        const SizedBox(height: AppSizes.md),
        _HealthTile(
          title: 'AI Pipeline',
          value: ai,
          icon: Icons.smart_toy_outlined,
        ),
        const SizedBox(height: AppSizes.xl),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Raw Health Payload', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSizes.md),
              Text(
                health.isEmpty ? 'No health payload returned.' : health.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BadgeStatus _statusBadge(String status) {
    final normalized = status.toLowerCase();

    if (['ok', 'healthy', 'success', 'online', 'running'].contains(normalized)) {
      return BadgeStatus.success;
    }

    if (['warning', 'degraded', 'partial'].contains(normalized)) {
      return BadgeStatus.warning;
    }

    if (['failed', 'error', 'offline', 'down'].contains(normalized)) {
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
    final normalized = value.toLowerCase();

    final status = ['ok', 'healthy', 'success', 'online', 'running'].contains(normalized)
        ? BadgeStatus.success
        : ['warning', 'degraded', 'partial'].contains(normalized)
        ? BadgeStatus.warning
        : ['failed', 'error', 'offline', 'down'].contains(normalized)
        ? BadgeStatus.error
        : BadgeStatus.neutral;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Icon(icon, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          AppBadge(text: value, status: status),
        ],
      ),
    );
  }
}