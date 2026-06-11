import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
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
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    final controller = context.read<RecognitionController>();
    await controller.startAnalysis();

    if (!mounted || _navigated) return;

    if (controller.finalResult != null) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  Future<void> _retry() async {
    final controller = context.read<RecognitionController>();
    await controller.startAnalysis();

    if (!mounted || _navigated) return;

    if (controller.finalResult != null) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (controller.finalResult != null && !_navigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _navigated) return;
        _navigated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      });
    }

    return PopScope(
      canPop: controller.error != null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Multi-Agent Analysis'),
          automaticallyImplyLeading: controller.error != null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WorkspaceHero(
                  message: controller.processingMessage,
                  progress: controller.progress,
                  hasError: controller.error != null,
                ),
                const SizedBox(height: AppSizes.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Agent Pipeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    _LiveBadge(
                      isLoading: controller.isLoading,
                      hasError: controller.error != null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.agentStatuses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final item = controller.agentStatuses[index];

                      return AgentStatusCard(
                        icon: item.icon,
                        name: item.name,
                        status: item.status,
                        description: item.description,
                      );
                    },
                  ),
                ),
                if (controller.error != null) ...[
                  const SizedBox(height: AppSizes.md),
                  AppCard(
                    backgroundColor: AppColors.danger.withOpacity(0.08),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Text(
                            controller.error!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Back to Scan',
                          type: AppButtonType.outline,
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: AppButton(
                          text: 'Try Again',
                          icon: Icons.refresh_rounded,
                          isLoading: controller.isLoading,
                          onPressed: _retry,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceHero extends StatelessWidget {
  final String message;
  final double progress;
  final bool hasError;

  const _WorkspaceHero({
    required this.message,
    required this.progress,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: hasError
            ? const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: (hasError ? AppColors.danger : AppColors.primaryTeal)
                .withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI WORKSPACE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            hasError ? 'Analysis Interrupted' : 'Multi-Agent Analysis',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: hasError ? 1.0 : (safeProgress <= 0 ? null : safeProgress),
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            hasError
                ? 'Stopped'
                : '${(safeProgress * 100).clamp(0, 100).round()}% complete',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isLoading;
  final bool hasError;

  const _LiveBadge({
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasError
        ? AppColors.danger
        : isLoading
        ? AppColors.primaryTeal
        : AppColors.success;

    final text = hasError
        ? 'ERROR'
        : isLoading
        ? 'LIVE'
        : 'DONE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}