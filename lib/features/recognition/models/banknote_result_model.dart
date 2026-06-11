import '../../../core/network/response_parser.dart';
import 'agent_result_model.dart';
import 'final_result_model.dart';

class BanknoteResultModel {
  final String id;
  final String status;
  final String message;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;
  final FinalResultModel finalResult;
  final List<AgentResultModel> agentResults;
  final Map<String, dynamic> rawJson;

  const BanknoteResultModel({
    required this.id,
    required this.status,
    required this.message,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.finalResult,
    required this.agentResults,
    required this.rawJson,
  });

  factory BanknoteResultModel.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);
    final data = ResponseParser.parseMap(json['data'] ?? json['result'] ?? json);

    final finalRaw = ResponseParser.getValue(
      data,
      ['final_result', 'finalResult', 'result.final_result'],
      defaultValue: const {},
    );

    final agentsRaw = ResponseParser.getValue(
      data,
      ['agent_results', 'agents', 'agentResults'],
      defaultValue: const [],
    );

    final agents = <AgentResultModel>[];
    if (agentsRaw is List) {
      agents.addAll(
        agentsRaw
            .whereType<Map>()
            .map((item) => AgentResultModel.fromJson(Map<String, dynamic>.from(item))),
      );
    }

    final finalResult = FinalResultModel.fromJson(finalRaw);

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
      id: ResponseParser.getValue(data, ['id', '_id'], defaultValue: '').toString(),
      status: ResponseParser.getValue(
        data,
        ['status', 'state', 'final_result.status'],
        defaultValue: finalResult.status,
      ).toString(),
      message: ResponseParser.getValue(data, ['message', 'detail'], defaultValue: '').toString(),
      imageUrl: ResponseParser.getValue(
        data,
        [
          'uploaded_image_url',
          'image_url',
          'thumbnail_url',
          'image',
          'result.uploaded_image_url',
        ],
        defaultValue: '',
      ).toString(),
      createdAt: ResponseParser.getValue(
        data,
        ['created_at', 'createdAt'],
        defaultValue: '',
      ).toString(),
      updatedAt: ResponseParser.getValue(
        data,
        ['updated_at', 'updatedAt'],
        defaultValue: '',
      ).toString(),
      finalResult: finalResult,
      agentResults: agents,
      rawJson: data,
    );
  }

  Map<String, dynamic> get tokenUsage {
    final usage = ResponseParser.getValue(
      rawJson,
      [
        'token_usage',
        'tokenUsage',
        'billing',
        'billing_info',
        'usage',
      ],
      defaultValue: const {},
    );

    return ResponseParser.parseMap(usage);
  }

  int get tokensCharged {
    return _asInt(
      ResponseParser.getValue(
        tokenUsage,
        [
          'tokens_charged',
          'charged_tokens',
          'token_charged',
          'tokens',
          'charged',
        ],
        defaultValue: 0,
      ),
    );
  }

  int get balanceBefore {
    return _asInt(
      ResponseParser.getValue(
        tokenUsage,
        ['balance_before', 'before_balance', 'token_balance_before'],
        defaultValue: 0,
      ),
    );
  }

  int get balanceAfter {
    return _asInt(
      ResponseParser.getValue(
        tokenUsage,
        ['balance_after', 'after_balance', 'token_balance_after'],
        defaultValue: 0,
      ),
    );
  }

  int get inputTokens {
    return _asInt(
      ResponseParser.getValue(
        tokenUsage,
        ['input_tokens', 'prompt_tokens'],
        defaultValue: 0,
      ),
    );
  }

  int get outputTokens {
    return _asInt(
      ResponseParser.getValue(
        tokenUsage,
        ['output_tokens', 'completion_tokens'],
        defaultValue: 0,
      ),
    );
  }

  int get aiTokens {
    return _asInt(
      ResponseParser.getValue(
        tokenUsage,
        ['ai_tokens', 'total_ai_tokens', 'total_tokens'],
        defaultValue: inputTokens + outputTokens,
      ),
    );
  }

  String get billingMode {
    return ResponseParser.getValue(
      tokenUsage,
      ['billing_mode', 'mode'],
      defaultValue: tokensCharged > 0 ? 'fixed' : 'n/a',
    ).toString();
  }

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
}