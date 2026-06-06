import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../models/agent_result_model.dart';

class AgentStatusCard extends StatelessWidget {
  final AgentResultModel? agent;
  final IconData? icon;
  final String? name;
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
    final text = value.toString();
    return text.contains('.') ? text.split('.').last : text;
  }

  String get _name {
    if (name != null && name!.trim().isNotEmpty) return name!;
    if (agent != null && agent!.agentName.trim().isNotEmpty) return agent!.agentName;
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
    if (agent != null && agent!.summary.trim().isNotEmpty) return agent!.summary;
    return 'Waiting for analysis result.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = _status.toLowerCase();
    final agentName = _name.toLowerCase();

    final Color color = switch (normalized) {
      'success' || 'completed' || 'done' || 'consensus' => AppColors.success,
      'processing' || 'running' || 'analyzing' => AppColors.primaryTeal,
      'pending' || 'waiting' => AppColors.warning,
      'failed' || 'error' => AppColors.danger,
      'warning' || 'needs_review' => AppColors.warning,
      _ when agentName.contains('llm') => AppColors.agentPurple,
      _ when agentName.contains('visual') || agentName.contains('lens') => AppColors.secondaryBlue,
      _ => AppColors.textMutedLight,
    };

    final IconData displayIcon = icon ??
        switch (normalized) {
          'success' || 'completed' || 'done' || 'consensus' => Icons.check_circle_rounded,
          'processing' || 'running' || 'analyzing' => Icons.sync_rounded,
          'failed' || 'error' => Icons.error_outline_rounded,
          'pending' || 'waiting' => Icons.schedule_rounded,
          _ when agentName.contains('llm') => Icons.psychology_alt_rounded,
          _ when agentName.contains('visual') || agentName.contains('lens') => Icons.travel_explore_rounded,
          _ => Icons.memory_rounded,
        };

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: isDark ? AppColors.cardDark : color.withOpacity(0.045),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: color.withOpacity(0.18)),
            ),
            child: Icon(displayIcon, color: color, size: 22),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(_status.toUpperCase(), style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.4)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, height: 1.35, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: normalized.contains('pending') || normalized.contains('waiting') ? 0.35 : 1,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
