import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/network_image_view.dart';
import '../controllers/recognition_controller.dart';
import '../models/banknote_result_model.dart';
import '../widgets/agent_status_card.dart';
import '../widgets/result_summary_card.dart';
import 'result_detail_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final result = controller.finalResult;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recognition Result')),
        body: ErrorState(
          message: controller.error ?? 'No recognition result is available.',
          onRetry: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognition Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.imageUrl.isNotEmpty)
                AppCard(
                  padding: EdgeInsets.zero,
                  child: NetworkImageView(
                    imageUrl: result.imageUrl,
                    height: 220,
                    fit: BoxFit.contain,
                    borderRadius: AppSizes.radiusLg,
                  ),
                ),
              if (result.imageUrl.isNotEmpty) const SizedBox(height: AppSizes.lg),

              ResultSummaryCard(result: result),
              const SizedBox(height: AppSizes.lg),

              _FinalDecisionGrid(result: result),
              const SizedBox(height: AppSizes.lg),

              if (result.finalResult.summary.isNotEmpty) ...[
                _DetectedObjectsCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],

              Text(
                'Agent Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              if (result.agentResults.isEmpty)
                const AppCard(
                  child: Text('No agent output returned.'),
                )
              else
                ...result.agentResults.map(
                      (agent) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: AgentStatusCard(agent: agent),
                  ),
                ),

              const SizedBox(height: AppSizes.lg),

              _StructuredOutputPreview(result: result),
              const SizedBox(height: AppSizes.lg),

              AppButton(
                text: 'View Full Details',
                icon: Icons.open_in_new_rounded,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResultDetailScreen(result: result),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),
              AppButton(
                text: 'Scan Another Banknote',
                type: AppButtonType.outline,
                icon: Icons.document_scanner_rounded,
                onPressed: () {
                  controller.clearState();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalDecisionGrid extends StatelessWidget {
  final BanknoteResultModel result;

  const _FinalDecisionGrid({required this.result});

  @override
  Widget build(BuildContext context) {
    final finalResult = result.finalResult;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final Decision',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'Country',
                  value: finalResult.country,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MetricBox(
                  label: 'Denomination',
                  value: finalResult.denomination,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'Currency',
                  value: finalResult.currency,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MetricBox(
                  label: 'Consensus',
                  value: finalResult.matchedAgents,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetectedObjectsCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _DetectedObjectsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final summary = result.finalResult.summary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.length} banknote${summary.length > 1 ? 's' : ''} detected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Each object was analyzed separately by the multi-agent pipeline.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.md),
          for (final item in summary) ...[
            _DetectedObjectTile(item: item),
            if (item != summary.last) const SizedBox(height: AppSizes.sm),
          ],
        ],
      ),
    );
  }
}

class _DetectedObjectTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _DetectedObjectTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final denomination = (item['denomination'] ?? item['menh_gia'] ?? 'Unknown').toString();
    final country = (item['country'] ?? item['quoc_gia'] ?? 'Unknown').toString();
    final currency = (item['currency'] ?? '').toString();
    final matched = (item['matched_agents'] ?? item['so_luong_dong_thuan'] ?? 0).toString();
    final objectIndex = (item['object_index'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.bgDark
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              objectIndex.isEmpty ? '#' : objectIndex,
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$denomination ${currency.isEmpty ? '' : currency}'.trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$country · $matched/3 agents',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StructuredOutputPreview extends StatelessWidget {
  final BanknoteResultModel result;

  const _StructuredOutputPreview({required this.result});

  @override
  Widget build(BuildContext context) {
    final jsonText = const JsonEncoder.withIndent('  ').convert({
      'country': result.finalResult.country,
      'denomination': result.finalResult.denomination,
      'currency': result.finalResult.currency,
      'status': result.status,
      'consensus': result.finalResult.matchedAgents,
      'detected_objects': result.finalResult.summary,
    });

    return AppCard(
      backgroundColor: const Color(0xFF020617),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Structured Output',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            jsonText,
            maxLines: 18,
            overflow: TextOverflow.fade,
            style: const TextStyle(
              color: Color(0xFF5EEAD4),
              fontSize: 12,
              height: 1.45,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? 'N/A' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}