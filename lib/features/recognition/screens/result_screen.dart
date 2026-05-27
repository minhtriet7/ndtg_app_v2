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

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recognition Result')),
        body: ErrorState(
          message: controller.error ?? 'No recognition result is available.',
          onRetry: () {
            Navigator.of(context).pop();
          },
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
          padding: const EdgeInsets.all(AppSizes.lg),
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
              Text(
                'Agent Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
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
