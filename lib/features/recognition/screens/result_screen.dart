import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../currency/data/currency_service.dart';
import '../../main/controllers/main_tab_controller.dart';
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Token Usage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Actual tokens charged for this recognition.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Text(
                  '${result.tokensCharged == 0 ? 1 : result.tokensCharged}',
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
                  label: 'Before',
                  value: result.balanceBefore == 0 ? 'N/A' : '${result.balanceBefore}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _TinyBox(
                  label: 'After',
                  value: result.balanceAfter == 0 ? 'N/A' : '${result.balanceAfter}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _TinyBox(
                  label: 'AI tokens',
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
        _error = 'Unable to calculate exchange value.';
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
      _error = converted == null ? 'Exchange rate unavailable.' : null;
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
                const Text(
                  'VND Conversion',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
                  label: 'Currency',
                  value: _normalizeCurrency(
                    finalResult.currency,
                    finalResult.denomination,
                  ),
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
    final denomination =
    (item['denomination'] ?? item['menh_gia'] ?? 'Unknown').toString();
    final country = (item['country'] ?? item['quoc_gia'] ?? 'Unknown').toString();
    final currency = _normalizeCurrency((item['currency'] ?? '').toString(), denomination);
    final matched =
    (item['matched_agents'] ?? item['so_luong_dong_thuan'] ?? 0).toString();
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

class _ResultActionPanel extends StatelessWidget {
  final BanknoteResultModel result;

  const _ResultActionPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final jsonText = const JsonEncoder.withIndent('  ').convert(result.rawJson);

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
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This result is saved in your recognition history. You can review full details or start another scan.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              height: 1.4,
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: 'View Scan History',
            type: AppButtonType.outline,
            icon: Icons.history_rounded,
            onPressed: () => _goHistory(context),
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: 'Copy JSON',
            type: AppButtonType.outline,
            icon: Icons.copy_rounded,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recognition JSON copied.')),
              );
            },
          ),
          const SizedBox(height: AppSizes.sm),
          AppButton(
            text: 'Scan Another Banknote',
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

class _TinyBox extends StatelessWidget {
  final String label;
  final String value;

  const _TinyBox({
    required this.label,
    required this.value,
  });

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
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
  if (cleanCurrency.isEmpty || cleanCurrency == 'UNKNOWN') return cleanDenomination;

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