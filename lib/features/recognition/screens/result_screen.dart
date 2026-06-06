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
import '../widgets/agent_status_card.dart';
import '../widgets/result_summary_card.dart';
import 'result_detail_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final result = controller.finalResult;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recognition Result')),
        body: ErrorState(message: controller.error ?? 'No recognition result is available.', onRetry: () => Navigator.of(context).pop()),
      );
    }

    final output = const JsonEncoder.withIndent('  ').convert(result.rawJson);

    return Scaffold(
      appBar: AppBar(title: const Text('Recognition Result'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (result.imageUrl.isNotEmpty)
                AppCard(
                  padding: EdgeInsets.zero,
                  child: NetworkImageView(imageUrl: result.imageUrl, height: 220, fit: BoxFit.contain, borderRadius: AppSizes.radiusLg),
                ),
              if (result.imageUrl.isNotEmpty) const SizedBox(height: AppSizes.lg),
              ResultSummaryCard(result: result),
              const SizedBox(height: AppSizes.lg),
              AppCard(
                backgroundColor: AppColors.codeBg,
                hasBorder: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Structured Output', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: AppSizes.md),
                    Text(output, style: const TextStyle(color: AppColors.codeText, fontSize: 12, height: 1.45, fontFamily: 'JetBrains Mono')),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Agent Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: AppSizes.sm),
              ...result.agentResults.map((agent) => Padding(padding: const EdgeInsets.only(bottom: AppSizes.sm), child: AgentStatusCard(agent: agent))),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                text: 'View Full Details',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultDetailScreen(result: result))),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(child: AppButton(text: 'Export PDF', type: AppButtonType.secondary, onPressed: () {})),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppButton(
                      text: 'Scan Another',
                      type: AppButtonType.outline,
                      onPressed: () {
                        controller.clearState();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
