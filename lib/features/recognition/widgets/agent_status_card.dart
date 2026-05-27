import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../models/agent_result_model.dart';

class AgentStatusCard extends StatelessWidget {
  final AgentResultModel? agent;
  final IconData? icon;
  final String? name;

  /// Accepts String, enum AgentStatus, enum AgentPipelineStatus, or any object with toString().
  final Object? status;

  final String? desc;
  final String? description;

  const AgentStatusCard({
    super.key,
    this.agent,
    this.icon,
    this.name,
    this.status,
    this.desc,
    this.description,
  });

  String _statusToText(Object? value) {
    if (value == null) return '';

    if (value is String) return value;

    // Dart enum values usually stringify as EnumType.value.
    final text = value.toString();
    if (text.contains('.')) {
      return text.split('.').last;
    }

    return text;
  }

  String get _name {
    if (name != null && name!.trim().isNotEmpty) return name!;

    if (agent != null) {
      final value = agent!.agentName;
      if (value.trim().isNotEmpty) return value;
    }

    return 'AI Agent';
  }

  String get _status {
    final direct = _statusToText(status);
    if (direct.trim().isNotEmpty) return direct;

    if (agent != null) {
      final value = _statusToText(agent!.status);
      if (value.trim().isNotEmpty) return value;
    }

    return 'waiting';
  }

  String get _description {
    if (desc != null && desc!.trim().isNotEmpty) return desc!;
    if (description != null && description!.trim().isNotEmpty) return description!;

    if (agent != null) {
      final value = agent!.summary;
      if (value.trim().isNotEmpty) return value;
    }

    return 'Waiting for analysis result.';
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _status.toLowerCase();

    final Color color = switch (normalized) {
      'success' || 'completed' || 'done' => AppColors.success,
      'processing' || 'running' || 'analyzing' => AppColors.primaryTeal,
      'failed' || 'error' => AppColors.danger,
      'warning' || 'needs_review' => AppColors.warning,
      _ => AppColors.textMutedLight,
    };

    final IconData displayIcon = icon ??
        switch (normalized) {
          'success' || 'completed' || 'done' => Icons.check_circle_outline,
          'processing' || 'running' || 'analyzing' => Icons.sync_rounded,
          'failed' || 'error' => Icons.error_outline,
          _ => Icons.radio_button_unchecked,
        };

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(displayIcon, color: color, size: 23),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            _status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
