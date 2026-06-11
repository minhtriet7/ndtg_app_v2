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
    if (agent != null && agent!.agentName.trim().isNotEmpty) {
      return agent!.agentName;
    }

    return 'AI Agent';
  }

  String get _status {
    final direct = _statusToText(status);
    if (direct.trim().isNotEmpty) return _normalizeStatus(direct);

    if (agent != null) {
      final value = _statusToText(agent!.status);
      if (value.trim().isNotEmpty) return _normalizeStatus(value);
    }

    return 'waiting';
  }

  String get _description {
    if (desc != null && desc!.trim().isNotEmpty) return desc!;
    if (description != null && description!.trim().isNotEmpty) {
      return description!;
    }
    if (agent != null && agent!.summary.trim().isNotEmpty) {
      return agent!.summary;
    }

    return 'Waiting for analysis result.';
  }

  String _normalizeStatus(String value) {
    final text = value.toLowerCase().trim();

    if (text.contains('completed') ||
        text.contains('success') ||
        text.contains('done') ||
        text.contains('consensus')) {
      return 'completed';
    }

    if (text.contains('running') ||
        text.contains('processing') ||
        text.contains('analyzing')) {
      return 'running';
    }

    if (text.contains('pending') || text.contains('queued')) {
      return 'pending';
    }

    if (text.contains('failed') || text.contains('error')) {
      return 'failed';
    }

    if (text.contains('waiting')) {
      return 'waiting';
    }

    return text.isEmpty ? 'waiting' : text;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = _status.toLowerCase();
    final agentName = _name.toLowerCase();

    final Color color = switch (normalized) {
      'completed' => AppColors.success,
      'running' => AppColors.primaryTeal,
      'pending' => AppColors.secondaryBlue,
      'waiting' => AppColors.warning,
      'failed' => AppColors.danger,
      _ when agentName.contains('llm') => AppColors.agentPurple,
      _ when agentName.contains('visual') || agentName.contains('lens') => AppColors.secondaryBlue,
      _ => AppColors.primaryTeal,
    };

    final IconData displayIcon = icon ??
        switch (normalized) {
          'completed' => Icons.check_circle_rounded,
          'running' => Icons.sync_rounded,
          'failed' => Icons.error_outline_rounded,
          'pending' => Icons.pending_actions_rounded,
          'waiting' => Icons.schedule_rounded,
          _ when agentName.contains('llm') => Icons.psychology_alt_rounded,
          _ when agentName.contains('visual') || agentName.contains('lens') => Icons.travel_explore_rounded,
          _ => Icons.memory_rounded,
        };

    final progress = switch (normalized) {
      'waiting' => 0.10,
      'pending' => 0.35,
      'running' => 0.68,
      'failed' => 1.0,
      'completed' => 1.0,
      _ => 0.25,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AppCard(
        padding: const EdgeInsets.all(AppSizes.md),
        backgroundColor: isDark ? AppColors.cardDark : color.withOpacity(0.045),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: color.withOpacity(0.20)),
              ),
              child: Icon(displayIcon, color: color, size: 23),
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
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _StatusPill(
                        label: normalized,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: progress,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
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

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}