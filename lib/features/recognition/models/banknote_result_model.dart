import '../../../core/network/response_parser.dart';
import 'agent_result_model.dart';
import 'final_result_model.dart';

class BanknoteResultModel {
  final String id;
  final String taskId;
  final String status;
  final String message;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;
  final int detectedCount;
  final List<Map<String, dynamic>> detectedObjects;
  final List<Map<String, dynamic>> rejectedObjects;
  final List<Map<String, dynamic>> unresolvedObjects;
  final List<Map<String, dynamic>> overflowObjects;
  final Map<String, dynamic> cropChecker;
  final List<Map<String, dynamic>> consensusTrace;
  final Map<String, dynamic> conversionResult;
  final double confidence;
  final int processingTimeMs;
  final FinalResultModel finalResult;
  final List<AgentResultModel> agentResults;
  final Map<String, dynamic> rawJson;

  const BanknoteResultModel({
    required this.id,
    required this.taskId,
    required this.status,
    required this.message,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.detectedCount,
    required this.detectedObjects,
    required this.rejectedObjects,
    required this.unresolvedObjects,
    required this.overflowObjects,
    required this.cropChecker,
    required this.consensusTrace,
    required this.conversionResult,
    required this.confidence,
    required this.processingTimeMs,
    required this.finalResult,
    required this.agentResults,
    required this.rawJson,
  });

  factory BanknoteResultModel.fromJson(dynamic raw) {
    final unwrapped = ResponseParser.unwrap(raw);
    final root = unwrapped is Map
        ? Map<String, dynamic>.from(unwrapped)
        : <String, dynamic>{};
    final hasRecognitionFields =
        root.containsKey('final_result') ||
        root.containsKey('agent_results') ||
        root.containsKey('detected_objects') ||
        root.containsKey('system_tokens_charged');
    final wrappedData = root['data'];
    final wrappedResult = root['result'];
    final data = hasRecognitionFields
        ? root
        : wrappedData is Map
        ? Map<String, dynamic>.from(wrappedData)
        : wrappedResult is Map
        ? Map<String, dynamic>.from(wrappedResult)
        : root;

    final finalRaw = ResponseParser.getValue(data, [
      'final_result',
      'finalResult',
      'result.final_result',
    ], defaultValue: const {});

    final agentsRaw = ResponseParser.getValue(data, [
      'agent_results',
      'agents',
      'agentResults',
    ], defaultValue: const []);

    final agents = <AgentResultModel>[];
    if (agentsRaw is List) {
      agents.addAll(
        agentsRaw.whereType<Map>().map(
          (item) => AgentResultModel.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
    }

    final finalResult = FinalResultModel.fromJson(finalRaw);
    final finalMap = ResponseParser.parseMap(finalRaw);
    final detectedObjects = _listOfMap(
      ResponseParser.getValue(
        data,
        ['detected_objects'],
        defaultValue: ResponseParser.getValue(finalMap, [
          'detected_objects',
        ], defaultValue: const []),
      ),
    );
    final rejectedObjects = _listOfMap(
      ResponseParser.getValue(
        data,
        ['rejected_objects'],
        defaultValue: ResponseParser.getValue(finalMap, [
          'rejected_objects',
        ], defaultValue: const []),
      ),
    );
    final unresolvedObjects = _listOfMap(
      ResponseParser.getValue(
        data,
        ['unresolved_objects'],
        defaultValue: ResponseParser.getValue(finalMap, [
          'unresolved_objects',
        ], defaultValue: const []),
      ),
    );
    final overflowObjects = _listOfMap(
      ResponseParser.getValue(
        data,
        ['overflow_objects'],
        defaultValue: ResponseParser.getValue(finalMap, [
          'overflow_objects',
        ], defaultValue: const []),
      ),
    );

    if (agents.isEmpty && finalResult.summary.isNotEmpty) {
      for (final item in finalResult.summary) {
        agents.add(
          AgentResultModel.fromJson({
            'agent': 'Aggregator',
            'status': item['status'] ?? finalResult.status,
            'denomination': item['denomination'],
            'country': item['country'],
            'currency': item['currency'],
            'summary':
                'Object #${item['object_index'] ?? ''}: ${item['country'] ?? ''} ${item['denomination'] ?? ''}',
            'object_index': item['object_index'],
          }),
        );
      }
    }

    return BanknoteResultModel(
      id: ResponseParser.getValue(data, [
        'id',
        '_id',
      ], defaultValue: '').toString(),
      taskId: ResponseParser.getValue(data, [
        'task_id',
      ], defaultValue: '').toString(),
      status: ResponseParser.getValue(data, [
        'status',
        'state',
        'final_result.status',
      ], defaultValue: finalResult.status).toString(),
      message: ResponseParser.getValue(data, [
        'message',
        'detail',
        'error_message',
        'final_result.error_message',
        'final_result.message',
        'final_result.warning',
      ], defaultValue: '').toString(),
      imageUrl: ResponseParser.getValue(data, [
        'uploaded_image_url',
        'input_image_url',
        'image_url',
        'thumbnail_url',
        'image',
        'result.uploaded_image_url',
      ], defaultValue: '').toString(),
      createdAt: ResponseParser.getValue(data, [
        'created_at',
        'createdAt',
      ], defaultValue: '').toString(),
      updatedAt: ResponseParser.getValue(data, [
        'updated_at',
        'updatedAt',
      ], defaultValue: '').toString(),
      detectedCount: _asInt(
        ResponseParser.getValue(data, [
          'detected_count',
        ], defaultValue: finalResult.detectedCount),
      ),
      detectedObjects: detectedObjects,
      rejectedObjects: rejectedObjects,
      unresolvedObjects: unresolvedObjects,
      overflowObjects: overflowObjects,
      cropChecker: ResponseParser.parseMap(
        ResponseParser.getValue(data, ['crop_checker'], defaultValue: const {}),
      ),
      consensusTrace: _listOfMap(
        ResponseParser.getValue(
          data,
          ['consensus_trace'],
          defaultValue: ResponseParser.getValue(finalMap, [
            'consensus_trace',
          ], defaultValue: const []),
        ),
      ),
      conversionResult: ResponseParser.parseMap(
        ResponseParser.getValue(data, [
          'conversion_result',
        ], defaultValue: const {}),
      ),
      confidence: _asDouble(
        ResponseParser.getValue(data, [
          'confidence',
        ], defaultValue: finalResult.confidence),
      ),
      processingTimeMs: _asInt(
        ResponseParser.getValue(data, ['processing_time_ms'], defaultValue: 0),
      ),
      finalResult: finalResult,
      agentResults: agents,
      rawJson: data,
    );
  }

  Map<String, dynamic> get tokenUsage {
    final usage = ResponseParser.getValue(rawJson, [
      'token_usage',
      'tokenUsage',
      'billing',
      'billing_info',
      'usage',
    ], defaultValue: const {});

    return ResponseParser.parseMap(usage);
  }

  int get tokensCharged {
    return _asInt(
      ResponseParser.getValue(
        rawJson,
        ['system_tokens_charged'],
        defaultValue: ResponseParser.getValue(tokenUsage, [
          'system_tokens_charged',
          'tokens_charged',
          'charged_tokens',
          'token_charged',
          'tokens',
          'charged',
        ], defaultValue: 0),
      ),
    );
  }

  int get balanceBefore {
    return _asInt(
      ResponseParser.getValue(
        rawJson,
        ['balance_before'],
        defaultValue: ResponseParser.getValue(tokenUsage, [
          'balance_before',
          'before_balance',
          'token_balance_before',
        ], defaultValue: 0),
      ),
    );
  }

  int get balanceAfter {
    return _asInt(
      ResponseParser.getValue(
        rawJson,
        ['balance_after'],
        defaultValue: ResponseParser.getValue(tokenUsage, [
          'balance_after',
          'after_balance',
          'token_balance_after',
        ], defaultValue: 0),
      ),
    );
  }

  int get inputTokens {
    return _asInt(
      ResponseParser.getValue(
        rawJson,
        ['input_tokens'],
        defaultValue: ResponseParser.getValue(tokenUsage, [
          'input_tokens',
          'prompt_tokens',
        ], defaultValue: 0),
      ),
    );
  }

  int get outputTokens {
    return _asInt(
      ResponseParser.getValue(
        rawJson,
        ['output_tokens'],
        defaultValue: ResponseParser.getValue(tokenUsage, [
          'output_tokens',
          'completion_tokens',
        ], defaultValue: 0),
      ),
    );
  }

  int get aiTokens {
    return _asInt(
      ResponseParser.getValue(
        rawJson,
        ['total_ai_tokens'],
        defaultValue: ResponseParser.getValue(tokenUsage, [
          'ai_tokens',
          'total_ai_tokens',
          'total_tokens',
        ], defaultValue: inputTokens + outputTokens),
      ),
    );
  }

  String get billingMode {
    return ResponseParser.getValue(
      rawJson,
      ['billing_mode'],
      defaultValue: ResponseParser.getValue(tokenUsage, [
        'billing_mode',
        'mode',
      ], defaultValue: tokensCharged > 0 ? 'fixed' : 'n/a'),
    ).toString();
  }

  Map<String, dynamic> get modelTrace {
    return ResponseParser.parseMap(
      ResponseParser.getValue(
        rawJson,
        ['model_trace'],
        defaultValue: ResponseParser.getValue(finalResult.raw, [
          'model_trace',
        ], defaultValue: const {}),
      ),
    );
  }

  String get winnerVoteKey {
    return ResponseParser.getValue(
      rawJson,
      ['winner_vote_key'],
      defaultValue: ResponseParser.getValue(finalResult.raw, [
        'winner_vote_key',
      ], defaultValue: ''),
    ).toString();
  }

  List<String> get matchedAgentKeys {
    final value = ResponseParser.getValue(
      rawJson,
      ['matched_agents_keys'],
      defaultValue: ResponseParser.getValue(finalResult.raw, [
        'matched_agents_keys',
      ], defaultValue: const []),
    );
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> get limitInfo => ResponseParser.parseMap(
    ResponseParser.getValue(
      rawJson,
      ['limit_info'],
      defaultValue: ResponseParser.getValue(finalResult.raw, [
        'limit_info',
      ], defaultValue: const {}),
    ),
  );

  Map<String, dynamic> get objectStatusSummary => ResponseParser.parseMap(
    ResponseParser.getValue(
      rawJson,
      ['object_status_summary'],
      defaultValue: ResponseParser.getValue(finalResult.raw, [
        'object_status_summary',
      ], defaultValue: const {}),
    ),
  );

  String get billingSkipReason => ResponseParser.getValue(
    rawJson,
    ['billing_skip_reason'],
    defaultValue: ResponseParser.getValue(tokenUsage, [
      'billing_skip_reason',
    ], defaultValue: ''),
  ).toString();

  int get billableAiTokens => _asInt(
    ResponseParser.getValue(
      rawJson,
      ['billable_ai_tokens'],
      defaultValue: ResponseParser.getValue(tokenUsage, [
        'billable_ai_tokens',
      ], defaultValue: 0),
    ),
  );

  List<Map<String, dynamic>> get agentUsages => _listOfMap(
    ResponseParser.getValue(
      rawJson,
      ['agent_usages'],
      defaultValue: ResponseParser.getValue(tokenUsage, [
        'agent_usages',
      ], defaultValue: const []),
    ),
  );

  bool get hasDiagnostics =>
      modelTrace.isNotEmpty ||
      winnerVoteKey.isNotEmpty ||
      matchedAgentKeys.isNotEmpty ||
      limitInfo.isNotEmpty ||
      objectStatusSummary.isNotEmpty ||
      billingSkipReason.isNotEmpty ||
      billableAiTokens > 0 ||
      agentUsages.isNotEmpty;

  String get normalizedStatus {
    final value = status.trim().toLowerCase().replaceAll(' ', '_');
    if (value == 'needs_review') return value;
    return value;
  }

  bool get isNoBanknote => normalizedStatus == 'no_banknote_detected';

  bool get isPartial => normalizedStatus == 'completed_partial';

  bool get isCompletedWithLimit => normalizedStatus == 'completed_with_limit';

  bool get needsUserReview =>
      const {'needs_better_image', 'needs_review'}.contains(normalizedStatus);

  bool get isTechnicalFailure => const {
    'failed',
    'technical_error',
    'agent_error',
    'consensus_failed',
  }.contains(normalizedStatus);

  bool get hasTokenUsage {
    return tokenUsage.isNotEmpty ||
        tokensCharged > 0 ||
        balanceBefore > 0 ||
        balanceAfter > 0 ||
        aiTokens > 0;
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();

    final text = value.toString().replaceAll(',', '').trim();
    return int.tryParse(text) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll('%', '').trim()) ?? 0;
  }

  static List<Map<String, dynamic>> _listOfMap(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
