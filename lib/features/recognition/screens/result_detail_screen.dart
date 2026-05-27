import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/network_image_view.dart';
import '../models/banknote_result_model.dart';
import '../widgets/agent_status_card.dart';
import '../widgets/result_summary_card.dart';

class ResultDetailScreen extends StatelessWidget {
  final BanknoteResultModel result;

  const ResultDetailScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Result Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.imageUrl.isNotEmpty)
                AppCard(
                  padding: EdgeInsets.zero,
                  child: NetworkImageView(
                    imageUrl: result.imageUrl,
                    height: 260,
                    fit: BoxFit.contain,
                    borderRadius: AppSizes.radiusLg,
                  ),
                ),
              if (result.imageUrl.isNotEmpty) const SizedBox(height: AppSizes.lg),
              ResultSummaryCard(result: result),
              const SizedBox(height: AppSizes.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metadata',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: AppSizes.md),
                    _DetailRow(label: 'Result ID', value: result.id.isEmpty ? 'N/A' : result.id),
                    _DetailRow(label: 'Status', value: result.status),
                    _DetailRow(
                      label: 'Created At',
                      value: DateFormatter.formatDateTime(result.createdAt),
                    ),
                    _DetailRow(label: 'Decision Reason', value: result.finalResult.decisionReason),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Agent Outputs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              ...result.agentResults.map(
                    (agent) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: AgentStatusCard(agent: agent),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              AppCard(
                backgroundColor: isDark ? AppColors.bgDark : const Color(0xFF0F172A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Raw JSON',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: const JsonEncoder.withIndent('  ').convert(result.rawJson)),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Raw JSON copied.')),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      const JsonEncoder.withIndent('  ').convert(result.rawJson),
                      style: const TextStyle(
                        color: Color(0xFF5EEAD4),
                        fontSize: 12,
                        height: 1.4,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                text: 'Close',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
