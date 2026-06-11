import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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

  const ResultDetailScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final rawJson = const JsonEncoder.withIndent('  ').convert(result.rawJson);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Details'),
        actions: [
          IconButton(
            tooltip: 'Copy JSON',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawJson));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Raw JSON copied.')),
              );
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
              if (result.hasTokenUsage) ...[
                _TokenUsageReportCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              if (result.imageUrl.isNotEmpty) ...[
                _UploadedBanknoteCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              _FinalDecisionCard(result: result),
              const SizedBox(height: AppSizes.lg),
              _VndConversionDetailCard(result: result),
              const SizedBox(height: AppSizes.lg),
              if (result.finalResult.summary.isNotEmpty) ...[
                _DetectedObjectsDetailCard(result: result),
                const SizedBox(height: AppSizes.lg),
              ],
              _AgentOutputsSection(result: result),
              const SizedBox(height: AppSizes.lg),
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
          const Text(
            'ANALYSIS REPORT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            finalResult.displayTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            '${finalResult.country} · ${finalResult.matchedAgents}',
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
                label: result.status,
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

class _TokenUsageReportCard extends StatelessWidget {
  final BanknoteResultModel result;

  const _TokenUsageReportCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Usage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Actual scan billing and AI token usage for this result.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _GridMetric(
                  label: 'Charged',
                  value: '${result.tokensCharged == 0 ? 1 : result.tokensCharged}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _GridMetric(
                  label: 'Mode',
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
                  label: 'Before',
                  value: result.balanceBefore == 0 ? 'N/A' : '${result.balanceBefore}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _GridMetric(
                  label: 'After',
                  value: result.balanceAfter == 0 ? 'N/A' : '${result.balanceAfter}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _GridMetric(
                  label: 'Input',
                  value: result.inputTokens == 0 ? 'N/A' : '${result.inputTokens}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _GridMetric(
                  label: 'Output',
                  value: result.outputTokens == 0 ? 'N/A' : '${result.outputTokens}',
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
          const Padding(
            padding: EdgeInsets.all(AppSizes.md),
            child: Text(
              'Uploaded Banknote',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Final Decision',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _DetailGrid(
            items: [
              _DetailGridItem('Country', finalResult.country),
              _DetailGridItem(
                'Denomination',
                FinalResultModel.formatMoneyLabel(
                  finalResult.denomination,
                  finalResult.currency,
                ),
              ),
              _DetailGridItem('Currency', finalResult.currency),
              _DetailGridItem('Consensus', finalResult.matchedAgents),
              _DetailGridItem(
                'Material',
                finalResult.material.isEmpty ? 'Unknown' : finalResult.material,
              ),
              _DetailGridItem(
                'Origin',
                finalResult.origin.isEmpty ? finalResult.country : finalResult.origin,
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
                  const Text(
                    'Referee Conclusion',
                    style: TextStyle(
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
  State<_VndConversionDetailCard> createState() => _VndConversionDetailCardState();
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
        _error = 'Exchange calculation unavailable.';
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
      _error = value == null ? 'Exchange rate unavailable.' : null;
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
                const Text(
                  'VND Conversion',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                if (_loading)
                  const Text(
                    'Checking exchange rate...',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
            '${summary.length} detected banknote${summary.length > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Each object is analyzed independently before the final aggregator decision.',
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
      return const AppCard(
        child: Text('No agent output returned.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agent Outputs',
          style: TextStyle(
            fontSize: 18,
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
              const Expanded(
                child: Text(
                  'Structured JSON Output',
                  style: TextStyle(
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
              _expanded ? 'Collapse JSON' : 'Expand JSON',
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

  const _ContinueActions({
    required this.result,
    required this.rawJson,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFF0F172A),
      hasBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Continue scanning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start another scan or review saved results in your history.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppButton(
            text: 'Scan Another Banknote',
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
            text: 'View Scan History',
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
            text: 'Copy JSON',
            type: AppButtonType.outline,
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawJson));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recognition JSON copied.')),
              );
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

  const _HeroPill({
    required this.icon,
    required this.label,
  });

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

  const _GridMetric({
    required this.label,
    required this.value,
  });

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
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
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
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
    final denomination =
    (item['denomination'] ?? item['menh_gia'] ?? 'Unknown').toString();
    final currency = (item['currency'] ?? '').toString();
    final country = (item['country'] ?? item['quoc_gia'] ?? 'Unknown').toString();
    final objectIndex = (item['object_index'] ?? '').toString();
    final matched =
    (item['matched_agents'] ?? item['so_luong_dong_thuan'] ?? '').toString();

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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
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