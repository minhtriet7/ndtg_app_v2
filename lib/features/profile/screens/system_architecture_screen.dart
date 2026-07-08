import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';

class SystemArchitectureScreen extends StatelessWidget {
  const SystemArchitectureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${context.tr('appName')} Core')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          132,
        ),
        children: [
          const _ArchitectureHero(),
          const SizedBox(height: AppSizes.xl),
          Text(
            context.tr('multiAgentFlow'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          const _ConsensusNetworkGraph(),
          const SizedBox(height: AppSizes.xl),
          Text(
            context.tr('agentPipelineDetails'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _AgentDetailTile(
            icon: Icons.memory_rounded,
            title: context.tr('agent1Name'),
            subtitle: context.tr('agent1Subtitle'),
            description: context.tr('mlAgentDesc'),
            badge: context.tr('openAiVisionBadge'),
            accent: AppColors.primaryTeal,
          ),
          const SizedBox(height: AppSizes.md),
          _AgentDetailTile(
            icon: Icons.analytics_outlined,
            title: context.tr('agent2Name'),
            subtitle: context.tr('agent2Subtitle'),
            description: context.tr('llmAgentDesc'),
            badge: context.tr('geminiLlmBadge'),
            accent: AppColors.secondaryBlue,
          ),
          const SizedBox(height: AppSizes.md),
          _AgentDetailTile(
            icon: Icons.travel_explore_rounded,
            title: context.tr('agent3Name'),
            subtitle: context.tr('agent3Subtitle'),
            description: context.tr('visualSearchDesc'),
            badge: context.tr('googleLensBadge'),
            accent: AppColors.agentPurple,
          ),
          const SizedBox(height: AppSizes.md),
          _AgentDetailTile(
            icon: Icons.gavel_rounded,
            title: context.tr('aggregatorName'),
            subtitle: context.tr('aggregatorSubtitle'),
            description: context.tr('aggregatorDecisionDesc'),
            badge: context.tr('aggregatorRuleBadge'),
            accent: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _ArchitectureHero extends StatelessWidget {
  const _ArchitectureHero();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      hasBorder: false,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.xl),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.08 : 0.22),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.network_ping_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              context.tr('consensusClusterVersion'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('multiAgentNeuralConsensus'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              context.tr('architectureHeroDesc'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsensusNetworkGraph extends StatelessWidget {
  const _ConsensusNetworkGraph();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nodeBorderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Row of 3 parallel agents
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _GraphNode(
                icon: Icons.memory_rounded,
                label: context.tr('openAiVisionBadge'),
                accentColor: AppColors.primaryTeal,
              ),
              _GraphNode(
                icon: Icons.analytics_outlined,
                label: context.tr('geminiLlmBadge'),
                accentColor: AppColors.secondaryBlue,
              ),
              _GraphNode(
                icon: Icons.travel_explore_rounded,
                label: context.tr('googleLensBadge'),
                accentColor: AppColors.agentPurple,
              ),
            ],
          ),

          // Connective lines leading to aggregator
          const SizedBox(height: 18),
          const _ConnectiveGraphLines(),
          const SizedBox(height: 18),

          // Aggregator node
          _GraphNode(
            icon: Icons.gavel_rounded,
            label: context.tr('consensusArbiter'),
            accentColor: AppColors.success,
            isLarge: true,
          ),

          // Output line
          const SizedBox(height: 12),
          Container(
            width: 2,
            height: 20,
            color: AppColors.success.withOpacity(0.4),
          ),
          const SizedBox(height: 6),

          // Final structured output
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDark : AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: nodeBorderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.code_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('structuredOutput'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
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

class _GraphNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool isLarge;

  const _GraphNode({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = isLarge ? 58.0 : 48.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(isDark ? 0.16 : 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withOpacity(isDark ? 0.40 : 0.30),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isDark ? 0.14 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: accentColor, size: isLarge ? 28 : 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 13 : 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _ConnectiveGraphLines extends StatelessWidget {
  const _ConnectiveGraphLines();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SizedBox(
      height: 24,
      width: double.infinity,
      child: CustomPaint(painter: _GraphLinesPainter(lineColor: lineColor)),
    );
  }
}

class _GraphLinesPainter extends CustomPainter {
  final Color lineColor;

  _GraphLinesPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // We draw lines from three nodes at top (left, center, right) to aggregator node at bottom center
    final startLeft = Offset(size.width * 0.22, 0);
    final startCenter = Offset(size.width * 0.5, 0);
    final startRight = Offset(size.width * 0.78, 0);
    final endNode = Offset(size.width * 0.5, size.height);

    // Draw lines
    canvas.drawLine(startLeft, endNode, paint);
    canvas.drawLine(startCenter, endNode, paint);
    canvas.drawLine(startRight, endNode, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AgentDetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String badge;
  final Color accent;

  const _AgentDetailTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: accent.withOpacity(isDark ? 0.22 : 0.12),
              ),
            ),
            child: Icon(icon, color: accent, size: 21),
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
                        title,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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
