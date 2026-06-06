import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/recognition_controller.dart';
import '../widgets/agent_status_card.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final controller = context.read<RecognitionController>();
        await controller.startAnalysis();
        if (!mounted) return;
        if (controller.finalResult != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ResultScreen()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Multi-Agent Analysis'), automaticallyImplyLeading: false),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
                    boxShadow: [BoxShadow(color: AppColors.primaryTeal.withOpacity(0.22), blurRadius: 28, offset: const Offset(0, 14))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI WORKSPACE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: AppSizes.sm),
                      const Text('Multi-Agent Analysis', style: TextStyle(color: Colors.white, fontSize: 26, height: 1.08, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
                      const SizedBox(height: AppSizes.sm),
                      Text(controller.processingMessage, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.45, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: controller.progress <= 0 ? null : controller.progress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                Text('Agent Pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(height: AppSizes.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.agentStatuses.length,
                    separatorBuilder: (_, index) => const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) => AgentStatusCard(status: controller.agentStatuses[index]),
                  ),
                ),
                if (controller.error != null) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(controller.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSizes.md),
                  AppButton(text: 'Back to Scan', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
