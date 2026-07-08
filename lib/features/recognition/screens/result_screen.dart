import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../../routes/route_names.dart';
import '../../currency/data/currency_service.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/recognition_controller.dart';
import '../models/banknote_result_model.dart';
import '../widgets/agent_status_card.dart';
import '../widgets/result_summary_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecognitionController>();
    final result = controller.finalResult;

    if (result == null) {
      if (controller.isLoading) {
        return Scaffold(
          appBar: AppBar(title: Text(context.tr('result'))),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('result'))),
        body: ErrorState(
          message: controller.error ?? context.tr('noResultAvailable'),
          onRetry: () => Navigator.of(context).pop(),
        ),
      );
    }

    if (result.isNoBanknote) {
      return _NoBanknoteResult(result: result);
    }

    if (result.isTechnicalFailure || result.needsUserReview) {
      return _NonSuccessResult(result: result);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('result')),
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
              if (result.isPartial) ...[
                _BusinessStatusBanner(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.warning,
                  title: context.tr('partialResultTitle'),
                  message: context.tr('partialResultMessage'),
                ),
                const SizedBox(height: AppSizes.lg),
              ],
              if (result.isCompletedWithLimit) ...[
                _BusinessStatusBanner(
                  icon: Icons.filter_3_rounded,
                  color: AppColors.warning,
                  title: context.tr('limitResultTitle'),
                  message: context.trArgs('limitResultMessage', {
                    'count': result.overflowObjects.length,
                  }),
                ),
                const SizedBox(height: AppSizes.lg),
              ],
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
              if (result.imageUrl.isNotEmpty)
                const SizedBox(height: AppSizes.lg),
              ResultSummaryCard(
                result: result,
                title: _formatMoneyLabel(
                  result.finalResult.denomination,
                  result.finalResult.currency,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              if (result.hasTokenUsage) ...[
                _TokenUsageCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              _FinalDecisionGrid(result: result),
              const SizedBox(height: AppSizes.lg),
              _VndConversionCard(result: result),
              const SizedBox(height: AppSizes.lg),
              if (result.finalResult.summary.isNotEmpty) ...[
                _DetectedObjectsCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (result.unresolvedObjects.isNotEmpty) ...[
                _ObjectIssuesCard(
                  title: context.tr('unresolvedRegions'),
                  objects: result.unresolvedObjects,
                ),
                const SizedBox(height: AppSizes.lg),
              ],
              Text(
                context.tr('agentPipeline'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              if (result.agentResults.isEmpty)
                AppCard(child: Text(context.tr('noAgentOutput')))
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
              _ResultActionPanel(result: result),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenUsageCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _TokenUsageCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(
                  Icons.generating_tokens_rounded,
                  color: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('tokenUsage'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr('actualTokenCharged'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Text(
                  '${result.tokensCharged}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _TinyBox(
                  label: context.tr('before'),
                  value: result.balanceBefore == 0
                      ? 'N/A'
                      : '${result.balanceBefore}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _TinyBox(
                  label: context.tr('after'),
                  value: result.balanceAfter == 0
                      ? 'N/A'
                      : '${result.balanceAfter}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _TinyBox(
                  label: context.tr('aiTokens'),
                  value: result.aiTokens == 0 ? 'N/A' : '${result.aiTokens}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VndConversionCard extends StatefulWidget {
  final BanknoteResultModel result;

  const _VndConversionCard({required this.result});

  @override
  State<_VndConversionCard> createState() => _VndConversionCardState();
}

class _VndConversionCardState extends State<_VndConversionCard> {
  final CurrencyService _currencyService = CurrencyService();

  bool _loading = true;
  String? _error;
  double? _convertedVnd;

  @override
  void initState() {
    super.initState();
    _loadConversion();
  }

  Future<void> _loadConversion() async {
    final amount = _extractAmount(widget.result.finalResult.denomination);
    final currency = _normalizeCurrency(
      widget.result.finalResult.currency,
      widget.result.finalResult.denomination,
    );

    if (amount <= 0 || currency.isEmpty || currency == 'UNKNOWN') {
      setState(() {
        _loading = false;
        _error = context.tr('exchangeUnavailable');
      });
      return;
    }

    if (currency == 'VND') {
      setState(() {
        _loading = false;
        _convertedVnd = amount;
      });
      return;
    }

    final converted = await _currencyService.convertToVnd(
      amount: amount,
      fromCurrency: currency,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _convertedVnd = converted;
      _error = converted == null ? context.tr('exchangeUnavailable') : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final amount = _extractAmount(widget.result.finalResult.denomination);
    final currency = _normalizeCurrency(
      widget.result.finalResult.currency,
      widget.result.finalResult.denomination,
    );

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('vndConversion'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                if (_loading)
                  Text(
                    context.tr('checkingRate'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )
                else if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    currency == 'VND'
                        ? '${_formatNumber(amount)} VND'
                        : '${_formatNumber(amount)} $currency ≈ ${_formatNumber(_convertedVnd ?? 0)} VND',
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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

class _FinalDecisionGrid extends StatelessWidget {
  final BanknoteResultModel result;

  const _FinalDecisionGrid({required this.result});

  @override
  Widget build(BuildContext context) {
    final finalResult = result.finalResult;

    return AppCard(
      glowColor:
          AppColors.success, // Beautiful premium jade consensus glow border
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('finalDecision'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('consensusMatch'),
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: context.tr('country'),
                  value: finalResult.country,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MetricBox(
                  label: context.tr('denomination'),
                  value: _formatMoneyLabel(
                    finalResult.denomination,
                    finalResult.currency,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: context.tr('currencyLabel'),
                  value: _normalizeCurrency(
                    finalResult.currency,
                    finalResult.denomination,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MetricBox(
                  label: context.tr('consensus'),
                  value: finalResult.matchedAgents,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: context.tr('confidence'),
                  value: _formatConfidence(
                    finalResult.confidence > 0
                        ? finalResult.confidence
                        : result.confidence,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _MetricBox(
                  label: context.tr('processingTime'),
                  value: result.processingTimeMs > 0
                      ? '${(result.processingTimeMs / 1000).toStringAsFixed(1)}s'
                      : context.tr('noDataYet'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoBanknoteResult extends StatelessWidget {
  final BanknoteResultModel result;

  const _NoBanknoteResult({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('result')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.xxl,
          ),
          children: [
            _BusinessStatusBanner(
              icon: Icons.search_off_rounded,
              color: AppColors.warning,
              title: context.tr('noValidBanknoteTitle'),
              message:
                  _isVietnamese(context) && result.message.trim().isNotEmpty
                  ? result.message
                  : context.tr('noBanknoteMessage'),
            ),
            if (result.imageUrl.isNotEmpty) ...[
              const SizedBox(height: AppSizes.lg),
              AppCard(
                padding: EdgeInsets.zero,
                child: NetworkImageView(
                  imageUrl: result.imageUrl,
                  height: 220,
                  fit: BoxFit.contain,
                  borderRadius: AppSizes.radiusLg,
                ),
              ),
            ],
            if (result.rejectedObjects.isNotEmpty) ...[
              const SizedBox(height: AppSizes.lg),
              _RejectedEvidenceCard(objects: result.rejectedObjects),
            ],
            const SizedBox(height: AppSizes.lg),
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.generating_tokens_outlined,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      context.trArgs('agentsSkippedTokens', {
                        'tokens': result.tokensCharged,
                      }),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _BackToScannerButton(),
          ],
        ),
      ),
    );
  }
}

class _NonSuccessResult extends StatelessWidget {
  final BanknoteResultModel result;

  const _NonSuccessResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final isReview = result.needsUserReview;
    final color = isReview ? AppColors.warning : AppColors.danger;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('result')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.lg,
            AppSizes.xxl,
          ),
          children: [
            _BusinessStatusBanner(
              icon: isReview
                  ? Icons.photo_camera_back_outlined
                  : Icons.error_outline_rounded,
              color: color,
              title: isReview
                  ? context.tr('betterImageTitle')
                  : context.tr('technicalFailureTitle'),
              message: result.message.trim().isNotEmpty
                  ? result.message
                  : result.finalResult.decisionReason.trim().isNotEmpty
                  ? result.finalResult.decisionReason
                  : context.tr('resultFailureMessage'),
            ),
            if (result.imageUrl.isNotEmpty) ...[
              const SizedBox(height: AppSizes.lg),
              AppCard(
                padding: EdgeInsets.zero,
                child: NetworkImageView(
                  imageUrl: result.imageUrl,
                  height: 220,
                  fit: BoxFit.contain,
                  borderRadius: AppSizes.radiusLg,
                ),
              ),
            ],
            if (result.unresolvedObjects.isNotEmpty) ...[
              const SizedBox(height: AppSizes.lg),
              _ObjectIssuesCard(
                title: context.tr('unresolvedRegionDetails'),
                objects: result.unresolvedObjects,
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            _BackToScannerButton(),
          ],
        ),
      ),
    );
  }
}

class _BusinessStatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _BusinessStatusBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: color.withOpacity(0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
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

class _RejectedEvidenceCard extends StatelessWidget {
  final List<Map<String, dynamic>> objects;

  const _RejectedEvidenceCard({required this.objects});

  @override
  Widget build(BuildContext context) {
    return _ObjectIssuesCard(
      title: context.tr('rejectedReasonTitle'),
      objects: objects,
      showScores: true,
    );
  }
}

class _ObjectIssuesCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> objects;
  final bool showScores;

  const _ObjectIssuesCard({
    required this.title,
    required this.objects,
    this.showScores = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSizes.md),
          for (int index = 0; index < objects.length; index++) ...[
            _ObjectIssueTile(
              item: objects[index],
              index: index,
              showScores: showScores,
            ),
            if (index != objects.length - 1)
              const SizedBox(height: AppSizes.sm),
          ],
        ],
      ),
    );
  }
}

class _ObjectIssueTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final bool showScores;

  const _ObjectIssueTile({
    required this.item,
    required this.index,
    required this.showScores,
  });

  @override
  Widget build(BuildContext context) {
    final reason =
        (item['decision_reason'] ??
                item['reason'] ??
                item['message'] ??
                item['status'] ??
                '')
            .toString();
    final negatives = item['negative_evidence'];
    final evidence = negatives is List
        ? negatives.map((value) => value.toString()).where((e) => e.isNotEmpty)
        : const <String>[];

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.tr('suspiciousRegion')} #${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(reason, style: const TextStyle(height: 1.4)),
          ],
          if (showScores) ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('banknoteScore')}: ${_scoreText(item['banknote_score'])}  •  '
              '${context.tr('documentScore')}: ${_scoreText(item['document_score'])}',
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final line in evidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• $line'),
              ),
          ],
        ],
      ),
    );
  }
}

class _BackToScannerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: context.tr('scanAnother'),
      icon: Icons.document_scanner_rounded,
      onPressed: () {
        context.read<RecognitionController>().clearState();
        Navigator.of(context).popUntil((route) => route.isFirst);
        try {
          context.read<MainTabController>().goScan();
        } catch (_) {}
      },
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
            '${summary.length} ${context.tr('detectedBanknotes')}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            context.tr('eachObjectAnalyzed'),
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
    final denomination = (item['denomination'] ?? item['menh_gia'] ?? 'Unknown')
        .toString();
    final country = (item['country'] ?? item['quoc_gia'] ?? 'Unknown')
        .toString();
    final currency = _normalizeCurrency(
      (item['currency'] ?? '').toString(),
      denomination,
    );
    final matched = (item['matched_agents'] ?? item['so_luong_dong_thuan'] ?? 0)
        .toString();
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
                  _formatMoneyLabel(denomination, currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$country · $matched/3 ${context.tr('agentsLabel')}',
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

  List<TextSpan> _tokenizeJsonLine(String line) {
    final spans = <TextSpan>[];

    // Pattern to split JSON tokens sequentially
    final tokenPattern = RegExp(
      r'("[^"\\]*(?:\\.[^"\\]*)*")|(\b(?:true|false|null)\b)|(\b-?\d+(?:\.\d+)?\b)|([\{\}\[\]:,])|(\s+)|([^\s"\{\}\[\]:,]+)',
    );

    final matches = tokenPattern.allMatches(line);
    bool isKey = true; // First string in line is the JSON key

    for (final match in matches) {
      if (match.group(1) != null) {
        final text = match.group(1)!;
        // Check if colon immediately follows this string to identify it as key
        final remaining = line.substring(match.end).trim();
        if (isKey && remaining.startsWith(':')) {
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Color(0xFFA78BFA),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          isKey = false;
        } else {
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(color: Color(0xFF34D399)),
            ),
          );
        }
      } else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2)!,
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (match.group(3) != null) {
        spans.add(
          TextSpan(
            text: match.group(3)!,
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (match.group(4) != null) {
        final text = match.group(4)!;
        spans.add(
          TextSpan(
            text: text,
            style: const TextStyle(color: Colors.white60),
          ),
        );
        if (text == ':') {
          isKey = false;
        }
      } else if (match.group(5) != null) {
        spans.add(TextSpan(text: match.group(5)!));
      } else if (match.group(6) != null) {
        spans.add(
          TextSpan(
            text: match.group(6)!,
            style: const TextStyle(color: Colors.white70),
          ),
        );
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: line));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final currency = _normalizeCurrency(
      result.finalResult.currency,
      result.finalResult.denomination,
    );

    final jsonText = const JsonEncoder.withIndent('  ').convert({
      'country': result.finalResult.country,
      'denomination': _formatMoneyLabel(
        result.finalResult.denomination,
        currency,
      ),
      'currency': currency,
      'status': result.status,
      'consensus': result.finalResult.matchedAgents,
      'detected_objects': result.finalResult.summary,
    });

    final lines = jsonText.split('\n');

    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.codeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar (macOS style window controls)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              color: Color(0xFF1B1B1E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusXl),
                topRight: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5F56),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFBD2E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF27C93F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.code_rounded,
                          size: 13,
                          color: Color(0xFF34D399),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'payload.json',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: jsonText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('jsonCopied'))),
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 15,
                  ),
                ),
              ],
            ),
          ),

          // Code area with line numbers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line numbers
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lines.length,
                    (index) => Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 0.8,
                  height: lines.length * 16.5,
                  color: Colors.white.withOpacity(0.06),
                ),
                const SizedBox(width: 12),
                // Code RichText
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: lines.map((line) {
                      return RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                          children: _tokenizeJsonLine(line),
                        ),
                      );
                    }).toList(),
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

class _ResultActionPanel extends StatelessWidget {
  final BanknoteResultModel result;

  const _ResultActionPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final jsonText = const JsonEncoder.withIndent('  ').convert(result.rawJson);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      backgroundColor: isDark ? const Color(0xFF121214) : Colors.white,
      hasBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('continueScanning'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('savedToHistoryDesc'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppButton(
            text: context.tr('viewFullDetails'),
            icon: Icons.open_in_new_rounded,
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamed(RouteNames.resultDetail, arguments: result);
            },
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: context.tr('recognitionHistory'),
            type: AppButtonType.outline,
            icon: Icons.history_rounded,
            onPressed: () => _goHistory(context),
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: context.tr('copyJson'),
            type: AppButtonType.outline,
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonText));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(context.tr('jsonCopied'))));
            },
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: context.tr('scanAnother'),
            type: AppButtonType.outline,
            icon: Icons.document_scanner_rounded,
            onPressed: () {
              context.read<RecognitionController>().clearState();
              Navigator.of(context).popUntil((route) => route.isFirst);
              try {
                context.read<MainTabController>().goScan();
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }

  void _goHistory(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    try {
      context.read<MainTabController>().goHistory();
    } catch (_) {}
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({required this.label, required this.value});

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
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
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
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyBox extends StatelessWidget {
  final String label;
  final String value;

  const _TinyBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
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
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoneyLabel(String denomination, String currency) {
  final cleanDenomination = denomination.trim();
  final cleanCurrency = _normalizeCurrency(currency, denomination);

  if (cleanDenomination.isEmpty) return 'Unknown';
  if (cleanCurrency.isEmpty || cleanCurrency == 'UNKNOWN') {
    return cleanDenomination;
  }

  final upperDenomination = cleanDenomination.toUpperCase();
  if (RegExp('\\b$cleanCurrency\\b').hasMatch(upperDenomination)) {
    return cleanDenomination;
  }

  return '$cleanDenomination $cleanCurrency';
}

String _normalizeCurrency(String currency, String denomination) {
  final direct = currency.trim().toUpperCase();

  if (direct.isNotEmpty && direct != 'UNKNOWN') return direct;

  final text = denomination.toUpperCase();
  const codes = [
    'VND',
    'IDR',
    'THB',
    'MYR',
    'SGD',
    'PHP',
    'KHR',
    'LAK',
    'MMK',
    'BND',
    'USD',
  ];

  for (final code in codes) {
    if (RegExp('\\b$code\\b').hasMatch(text)) return code;
  }

  return direct.isEmpty ? 'UNKNOWN' : direct;
}

double _extractAmount(String value) {
  final match = RegExp(r'[\d,.]+').firstMatch(value);
  if (match == null) return 0;

  final raw = match.group(0) ?? '';
  final normalized = raw.replaceAll(',', '');
  return double.tryParse(normalized) ?? 0;
}

String _formatNumber(double value) {
  final rounded = value.round();
  final text = rounded.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}

bool _isVietnamese(BuildContext context) {
  return Localizations.localeOf(context).languageCode.toLowerCase() == 'vi';
}

String _formatConfidence(double value) {
  if (value <= 0) return 'N/A';
  final percent = value <= 1 ? value * 100 : value;
  return '${percent.clamp(0, 100).toStringAsFixed(1)}%';
}

String _scoreText(dynamic value) {
  if (value == null) return 'N/A';
  if (value is num) return value.toDouble().toStringAsFixed(2);
  final parsed = double.tryParse(value.toString());
  return parsed == null ? value.toString() : parsed.toStringAsFixed(2);
}
