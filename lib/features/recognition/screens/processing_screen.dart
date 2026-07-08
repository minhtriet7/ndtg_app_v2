import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_names.dart';
import '../controllers/recognition_controller.dart';

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
      Navigator.of(context).pushReplacementNamed(RouteNames.result);
    }
  }

  Future<void> _retry() async {
    final controller = context.read<RecognitionController>();
    await controller.startAnalysis();

    if (!mounted || _navigated) return;

    if (controller.finalResult != null) {
      _navigated = true;
      Navigator.of(context).pushReplacementNamed(RouteNames.result);
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
        Navigator.of(context).pushReplacementNamed(RouteNames.result);
      });
    }

    return PopScope(
      canPop: controller.error != null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('processing')),
          automaticallyImplyLeading: controller.error != null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WorkspaceHero(
                  progress: controller.progress,
                  hasError: controller.error != null,
                ),
                const SizedBox(height: AppSizes.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('agentPipeline'),
                        style: TextStyle(
                          fontSize: 17,
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
                  child: ListView.builder(
                    itemCount: controller.agentStatuses.length,
                    itemBuilder: (context, index) {
                      final item = controller.agentStatuses[index];
                      return _PipelineStep(
                        icon: item.icon,
                        name: _agentName(context, item.key),
                        status: item.status,
                        description: _agentDescription(context, item.key),
                        isFirst: index == 0,
                        isLast: index == controller.agentStatuses.length - 1,
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
                            context.tr(controller.error!),
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
                          text: context.tr('backToScan'),
                          type: AppButtonType.outline,
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: AppButton(
                          text: context.tr('tryAgain'),
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
  final double progress;
  final bool hasError;

  const _WorkspaceHero({required this.progress, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = hasError ? AppColors.danger : AppColors.primaryTeal;
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        border: Border.all(
          color: isDark
              ? (hasError
                    ? AppColors.danger.withOpacity(0.5)
                    : const Color(0xFF27272A))
              : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 36,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('aiWorkspace'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            hasError
                ? context.tr('analysisInterrupted')
                : context.tr('multiAgentFlow'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 23,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            context.tr('processingDescription'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: hasError ? 1.0 : (safeProgress <= 0 ? null : safeProgress),
              backgroundColor: isDark ? AppColors.bgDark : AppColors.slate200,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            hasError
                ? context.tr('stopped')
                : '${(safeProgress * 100).clamp(0, 100).round()}% ${context.tr('analysisComplete')}',
            style: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 11.5,
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

  const _LiveBadge({required this.isLoading, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final color = hasError
        ? AppColors.danger
        : isLoading
        ? AppColors.primaryTeal
        : AppColors.success;

    final text = hasError
        ? context.trStatus('technical_error')
        : isLoading
        ? context.tr('live')
        : context.tr('done');

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

class _PipelineStep extends StatelessWidget {
  final IconData icon;
  final String name;
  final String status;
  final String description;
  final bool isFirst;
  final bool isLast;

  const _PipelineStep({
    required this.icon,
    required this.name,
    required this.status,
    required this.description,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = status.toLowerCase();

    final Color color = switch (normalized) {
      'completed' || 'success' || 'done' => AppColors.success,
      'running' || 'processing' => AppColors.primaryTeal,
      'pending' => AppColors.secondaryBlue,
      'waiting' => isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      'failed' || 'error' => AppColors.danger,
      _ => AppColors.primaryTeal,
    };

    final double progress = switch (normalized) {
      'waiting' => 0.0,
      'pending' => 0.25,
      'running' || 'processing' => 0.65,
      'completed' || 'success' || 'done' => 1.0,
      _ => 0.0,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left timeline column
        SizedBox(
          width: 32,
          child: CustomPaint(
            painter: _TimelinePainter(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              activeColor: AppColors.primaryTeal,
              isFirst: isFirst,
              isLast: isLast,
              isCompleted:
                  normalized == 'completed' ||
                  normalized == 'success' ||
                  normalized == 'done',
              isRunning: normalized == 'running' || normalized == 'processing',
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: normalized == 'running' || normalized == 'processing'
                        ? AppColors.primaryTeal
                        : (normalized == 'completed' ||
                                  normalized == 'success' ||
                                  normalized == 'done'
                              ? AppColors.success
                              : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.bgDark : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow:
                        normalized == 'running' || normalized == 'processing'
                        ? [
                            BoxShadow(
                              color: AppColors.primaryTeal.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child:
                      normalized == 'completed' ||
                          normalized == 'success' ||
                          normalized == 'done'
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),

        // Right Card Column
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
            child: AppCard(
              padding: const EdgeInsets.all(AppSizes.md),
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.18)),
                    ),
                    child: Icon(icon, color: color, size: 18),
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
                                name,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _StatusChip(status: normalized, color: color),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            fontSize: 11.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (progress > 0 && progress < 1.0) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 3,
                              value: progress,
                              backgroundColor: color.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        context.trStatus(status).toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final Color color;
  final Color activeColor;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isRunning;

  _TimelinePainter({
    required this.color,
    required this.activeColor,
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    const double nodeCenterY = 20 + 7; // offset + radius

    // Draw top line
    if (!isFirst) {
      paint.color = (isCompleted || isRunning) ? activeColor : color;
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, nodeCenterY - 7),
        paint,
      );
    }

    // Draw bottom line
    if (!isLast) {
      paint.color = isCompleted ? activeColor : color;
      canvas.drawLine(
        Offset(centerX, nodeCenterY + 7),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isRunning != isRunning;
  }
}

String _agentName(BuildContext context, String key) {
  return switch (key) {
    'vision' => context.tr('mlAgent'),
    'llm' => context.tr('llmAgent'),
    'lens' => context.tr('visualSearch'),
    'aggregator' => context.tr('aggregatorDecision'),
    _ => key,
  };
}

String _agentDescription(BuildContext context, String key) {
  return switch (key) {
    'vision' => context.tr('visionProcessingDesc'),
    'llm' => context.tr('llmProcessingDesc'),
    'lens' => context.tr('lensProcessingDesc'),
    'aggregator' => context.tr('aggregatorProcessingDesc'),
    _ => context.tr('processingDescription'),
  };
}
