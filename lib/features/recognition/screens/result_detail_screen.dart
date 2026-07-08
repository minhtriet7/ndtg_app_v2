import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../currency/data/currency_service.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/recognition_controller.dart';
import '../models/banknote_result_model.dart';
import '../models/final_result_model.dart';
import '../widgets/agent_status_card.dart';

class ResultDetailScreen extends StatelessWidget {
  final BanknoteResultModel result;

  const ResultDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final rawJson = const JsonEncoder.withIndent('  ').convert(result.rawJson);
    final showRecognizedMoney =
        !result.isNoBanknote &&
        !result.isTechnicalFailure &&
        !result.needsUserReview;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('resultDetails')),
        actions: [
          IconButton(
            tooltip: context.tr('copyJson'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawJson));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(context.tr('jsonCopied'))));
            },
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
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
              _ReportHeader(result: result),
              const SizedBox(height: AppSizes.lg),
              if (result.isPartial || result.isCompletedWithLimit) ...[
                _PartialLimitDetailCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (result.hasTokenUsage) ...[
                _TokenUsageReportCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (result.imageUrl.isNotEmpty) ...[
                _UploadedBanknoteCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (!showRecognizedMoney) ...[
                _NonSuccessDetailCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (showRecognizedMoney) ...[
                _FinalDecisionCard(result: result),
                const SizedBox(height: AppSizes.lg),
                _VndConversionDetailCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (showRecognizedMoney &&
                  result.finalResult.summary.isNotEmpty) ...[
                _DetectedObjectsDetailCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              _AgentOutputsSection(result: result),
              const SizedBox(height: AppSizes.lg),
              if (result.hasDiagnostics) ...[
                _DiagnosticsCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              _RawJsonCard(rawJson: rawJson),
              const SizedBox(height: AppSizes.lg),
              _ContinueActions(result: result, rawJson: rawJson),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final BanknoteResultModel result;

  const _ReportHeader({required this.result});

  @override
  Widget build(BuildContext context) {
    final finalResult = result.finalResult;
    final isNonSuccess =
        result.isNoBanknote ||
        result.isTechnicalFailure ||
        result.needsUserReview;
    final title = result.isNoBanknote
        ? context.tr('noValidBanknoteTitle')
        : isNonSuccess
        ? context.tr(
            result.needsUserReview
                ? 'betterImageTitle'
                : 'technicalFailureTitle',
          )
        : finalResult.displayTitle;
    final subtitle = isNonSuccess
        ? context.trStatus(result.status)
        : '${finalResult.country} · ${finalResult.matchedAgents}';

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.20),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('analysisReport'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              _HeroPill(
                icon: Icons.verified_rounded,
                label: context.trStatus(result.status),
              ),
              const SizedBox(width: AppSizes.sm),
              _HeroPill(
                icon: Icons.schedule_rounded,
                label: DateFormatter.formatDateTime(result.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartialLimitDetailCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _PartialLimitDetailCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isLimit = result.isCompletedWithLimit;
    final objects = isLimit ? result.overflowObjects : result.unresolvedObjects;
    final title = context.tr(
      isLimit ? 'limitResultTitle' : 'partialResultTitle',
    );
    final message = isLimit
        ? context.trArgs('limitResultMessage', {
            'count': result.overflowObjects.length,
          })
        : context.tr('partialResultMessage');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isLimit ? Icons.filter_3_rounded : Icons.info_outline_rounded,
                color: AppColors.warning,
                size: 30,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(message, style: const TextStyle(height: 1.45)),
                  ],
                ),
              ),
            ],
          ),
          if (objects.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            SelectableText(
              const JsonEncoder.withIndent('  ').convert(objects),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _NonSuccessDetailCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _NonSuccessDetailCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isReview = result.needsUserReview;
    final color = result.isNoBanknote || isReview
        ? AppColors.warning
        : AppColors.danger;
    final title = result.isNoBanknote
        ? context.tr('noValidBanknoteTitle')
        : context.tr(isReview ? 'betterImageTitle' : 'technicalFailureTitle');
    final fallbackMessage = result.isNoBanknote
        ? context.tr('noBanknoteMessage')
        : context.tr('resultFailureMessage');
    final evidence = <Map<String, dynamic>>[
      ...result.rejectedObjects,
      ...result.unresolvedObjects,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                result.isNoBanknote
                    ? Icons.image_not_supported_outlined
                    : isReview
                    ? Icons.photo_camera_back_outlined
                    : Icons.error_outline_rounded,
                color: color,
                size: 30,
              ),
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
                      result.message.trim().isNotEmpty
                          ? result.message
                          : fallbackMessage,
                      style: const TextStyle(height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (evidence.isNotEmpty || result.cropChecker.isNotEmpty) ...[
            const SizedBox(height: AppSizes.lg),
            Text(
              context.tr('rejectedReasonTitle'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSizes.sm),
            SelectableText(
              const JsonEncoder.withIndent('  ').convert({
                if (evidence.isNotEmpty) 'objects': evidence,
                if (result.cropChecker.isNotEmpty)
                  'crop_checker': result.cropChecker,
              }),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _TokenUsageReportCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _TokenUsageReportCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('tokenUsage'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('actualTokenCharged'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _GridMetric(
                  label: context.tr('charged'),
                  value: '${result.tokensCharged}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _GridMetric(
                  label: context.tr('mode'),
                  value: result.billingMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _GridMetric(
                  label: context.tr('before'),
                  value: result.balanceBefore == 0
                      ? 'N/A'
                      : '${result.balanceBefore}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _GridMetric(
                  label: context.tr('after'),
                  value: result.balanceAfter == 0
                      ? 'N/A'
                      : '${result.balanceAfter}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _GridMetric(
                  label: context.tr('input'),
                  value: result.inputTokens == 0
                      ? 'N/A'
                      : '${result.inputTokens}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _GridMetric(
                  label: context.tr('output'),
                  value: result.outputTokens == 0
                      ? 'N/A'
                      : '${result.outputTokens}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadedBanknoteCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _UploadedBanknoteCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              context.tr('uploadedBanknote'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          NetworkImageView(
            imageUrl: result.imageUrl,
            height: 260,
            fit: BoxFit.contain,
            borderRadius: AppSizes.radiusLg,
          ),
        ],
      ),
    );
  }
}

class _FinalDecisionCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _FinalDecisionCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final finalResult = result.finalResult;

    return AppCard(
      glowColor: AppColors.success, // Premium consensus green glow border
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('finalDecision'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSizes.md),
          _DetailGrid(
            items: [
              _DetailGridItem(context.tr('country'), finalResult.country),
              _DetailGridItem(
                context.tr('denomination'),
                FinalResultModel.formatMoneyLabel(
                  finalResult.denomination,
                  finalResult.currency,
                ),
              ),
              _DetailGridItem(
                context.tr('currencyLabel'),
                finalResult.currency,
              ),
              _DetailGridItem(
                context.tr('consensus'),
                finalResult.matchedAgents,
              ),
              _DetailGridItem(
                context.tr('material'),
                finalResult.material.isEmpty ? 'Unknown' : finalResult.material,
              ),
              _DetailGridItem(
                context.tr('origin'),
                finalResult.origin.isEmpty
                    ? finalResult.country
                    : finalResult.origin,
              ),
            ],
          ),
          if (finalResult.decisionReason.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            Container(
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
                    context.tr('refereeConclusion'),
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    finalResult.decisionReason,
                    style: const TextStyle(
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VndConversionDetailCard extends StatefulWidget {
  final BanknoteResultModel result;

  const _VndConversionDetailCard({required this.result});

  @override
  State<_VndConversionDetailCard> createState() =>
      _VndConversionDetailCardState();
}

class _VndConversionDetailCardState extends State<_VndConversionDetailCard> {
  final CurrencyService _currencyService = CurrencyService();

  bool _loading = true;
  double? _converted;
  String? _error;

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Future<void> _convert() async {
    final amount = _extractAmount(widget.result.finalResult.denomination);
    final currency = widget.result.finalResult.currency.toUpperCase();

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
        _converted = amount;
      });
      return;
    }

    final value = await _currencyService.convertToVnd(
      amount: amount,
      fromCurrency: currency,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _converted = value;
      _error = value == null ? context.tr('exchangeUnavailable') : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final amount = _extractAmount(widget.result.finalResult.denomination);
    final currency = widget.result.finalResult.currency.toUpperCase();

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
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
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Text(
                    currency == 'VND'
                        ? '${_formatNumber(amount)} VND'
                        : '${_formatNumber(amount)} $currency ≈ ${_formatNumber(_converted ?? 0)} VND',
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

class _DetectedObjectsDetailCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _DetectedObjectsDetailCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final summary = result.finalResult.summary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.length} ${context.tr('detectedBanknotes')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            context.tr('eachObjectAnalyzed'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.md),
          for (final item in summary)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: _ObjectRow(item: item),
            ),
        ],
      ),
    );
  }
}

class _AgentOutputsSection extends StatelessWidget {
  final BanknoteResultModel result;

  const _AgentOutputsSection({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.agentResults.isEmpty) {
      return AppCard(child: Text(context.tr('noAgentOutput')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('agentPipeline'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSizes.sm),
        ...result.agentResults.map(
          (agent) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: AgentStatusCard(agent: agent),
          ),
        ),
      ],
    );
  }
}

class _DiagnosticsCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _DiagnosticsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    void addRow(String label, String value) {
      if (value.trim().isEmpty) return;
      if (rows.isNotEmpty) rows.add(const Divider(height: AppSizes.lg));
      rows.add(_DiagnosticRow(label: label, value: value));
    }

    addRow(context.tr('winnerVote'), result.winnerVoteKey);
    addRow(context.tr('matchedAgents'), result.matchedAgentKeys.join(', '));
    if (result.billableAiTokens > 0) {
      addRow(
        context.tr('billableAiTokens'),
        result.billableAiTokens.toString(),
      );
    }
    addRow(context.tr('billingSkipReason'), result.billingSkipReason);
    if (result.modelTrace.isNotEmpty) {
      addRow(
        context.tr('modelTrace'),
        context
            .tr('diagnosticEntries')
            .replaceAll('{count}', result.modelTrace.length.toString()),
      );
    }
    if (result.agentUsages.isNotEmpty) {
      addRow(
        context.tr('agentUsage'),
        context
            .tr('diagnosticEntries')
            .replaceAll('{count}', result.agentUsages.length.toString()),
      );
    }
    if (result.limitInfo.isNotEmpty) {
      addRow(context.tr('limitInfo'), jsonEncode(result.limitInfo));
    }
    if (result.objectStatusSummary.isNotEmpty) {
      addRow(
        context.tr('objectStatusSummary'),
        jsonEncode(result.objectStatusSummary),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                context.tr('diagnostics'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...rows,
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final String label;
  final String value;

  const _DiagnosticRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _RawJsonCard extends StatefulWidget {
  final String rawJson;

  const _RawJsonCard({required this.rawJson});

  @override
  State<_RawJsonCard> createState() => _RawJsonCardState();
}

class _RawJsonCardState extends State<_RawJsonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.codeBg,
      hasBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('structuredOutput'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.rawJson));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('jsonCopied'))),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text(context.tr('copy')),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            widget.rawJson,
            maxLines: _expanded ? null : 18,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
            style: const TextStyle(
              color: AppColors.codeText,
              fontSize: 12,
              height: 1.45,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: AppSizes.md),
          OutlinedButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: Colors.white,
            ),
            label: Text(
              _expanded ? context.tr('collapseJson') : context.tr('expandJson'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueActions extends StatelessWidget {
  final BanknoteResultModel result;
  final String rawJson;

  const _ContinueActions({required this.result, required this.rawJson});

  @override
  Widget build(BuildContext context) {
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
            text: context.tr('scanAnother'),
            icon: Icons.document_scanner_rounded,
            onPressed: () {
              context.read<RecognitionController>().clearState();
              Navigator.of(context).popUntil((route) => route.isFirst);
              try {
                context.read<MainTabController>().goScan();
              } catch (_) {}
            },
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: context.tr('recognitionHistory'),
            type: AppButtonType.outline,
            icon: Icons.history_rounded,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              try {
                context.read<MainTabController>().goHistory();
              } catch (_) {}
            },
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: context.tr('copyJson'),
            type: AppButtonType.outline,
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawJson));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(context.tr('jsonCopied'))));
            },
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailGridItem> items;

  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: Row(
              children: [
                Expanded(child: _GridBox(item: items[i])),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: i + 1 < items.length
                      ? _GridBox(item: items[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DetailGridItem {
  final String label;
  final String value;

  const _DetailGridItem(this.label, this.value);
}

class _GridBox extends StatelessWidget {
  final _DetailGridItem item;

  const _GridBox({required this.item});

  @override
  Widget build(BuildContext context) {
    return _GridMetric(label: item.label, value: item.value);
  }
}

class _GridMetric extends StatelessWidget {
  final String label;
  final String value;

  const _GridMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? 'N/A' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ObjectRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final denomination = (item['denomination'] ?? item['menh_gia'] ?? 'Unknown')
        .toString();
    final currency = (item['currency'] ?? '').toString();
    final country = (item['country'] ?? item['quoc_gia'] ?? 'Unknown')
        .toString();
    final objectIndex = (item['object_index'] ?? '').toString();
    final matched =
        (item['matched_agents'] ?? item['so_luong_dong_thuan'] ?? '')
            .toString();

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
                  FinalResultModel.formatMoneyLabel(denomination, currency),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  matched.isEmpty ? country : '$country · $matched/3 agents',
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
