import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';
import 'agent_result_model.dart';
import 'final_result_model.dart';

class BanknoteResultModel {
  final String id;
  final String imageUrl;
  final String localImagePath;
  final FinalResultModel finalResult;
  final List<AgentResultModel> agentResults;
  final String status;
  final String createdAt;
  final Map<String, dynamic> rawJson;

  const BanknoteResultModel({
    required this.id,
    required this.imageUrl,
    required this.localImagePath,
    required this.finalResult,
    required this.agentResults,
    required this.status,
    required this.createdAt,
    required this.rawJson,
  });

  factory BanknoteResultModel.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);
    final data = json.isNotEmpty ? json : JsonHelper.safeMap(raw);

    final finalRaw = ResponseParser.getValue(
      data,
      ['final_result', 'result.final_result', 'result', 'final'],
      defaultValue: <String, dynamic>{},
    );

    final agentsRaw = ResponseParser.getValue(
      data,
      ['agent_results', 'agents', 'agent_outputs', 'pipeline_results'],
      defaultValue: [],
    );

    return BanknoteResultModel(
      id: JsonHelper.safeString(
        ResponseParser.getValue(data, ['id', '_id', 'recognition_id', 'result_id']),
      ),
      imageUrl: JsonHelper.safeString(
        ResponseParser.getValue(
          data,
          [
            'uploaded_image_url',
            'image_url',
            'image',
            'file_url',
            'input_image_url',
          ],
        ),
      ),
      localImagePath: JsonHelper.safeString(
        ResponseParser.getValue(data, ['local_image_path', 'local_path']),
      ),
      finalResult: FinalResultModel.fromJson(finalRaw),
      agentResults: _parseAgents(agentsRaw),
      status: JsonHelper.safeString(
        ResponseParser.getValue(data, ['status', 'state']),
        fallback: 'completed',
      ),
      createdAt: JsonHelper.safeString(
        ResponseParser.getValue(data, ['created_at', 'createdAt', 'time', 'updated_at']),
      ),
      rawJson: data,
    );
  }

  static List<AgentResultModel> _parseAgents(dynamic raw) {
    final list = JsonHelper.safeList(raw);

    if (list.isEmpty) {
      return const [
        AgentResultModel(
          id: 'vision',
          agentName: 'vision',
          displayName: 'YOLO / Vision Agent',
          status: AgentStatus.waiting,
          confidence: 0,
          summary: 'No vision agent data returned.',
          data: {},
        ),
        AgentResultModel(
          id: 'llm',
          agentName: 'llm',
          displayName: 'Gemini LLM Agent',
          status: AgentStatus.waiting,
          confidence: 0,
          summary: 'No LLM agent data returned.',
          data: {},
        ),
        AgentResultModel(
          id: 'lens',
          agentName: 'lens',
          displayName: 'Google Lens Agent',
          status: AgentStatus.waiting,
          confidence: 0,
          summary: 'No visual search data returned.',
          data: {},
        ),
      ];
    }

    return list.map((item) => AgentResultModel.fromJson(item)).toList();
  }

  bool get isCompleted {
    final normalized = status.toLowerCase();
    return ['completed', 'success', 'done'].contains(normalized);
  }

  bool get isFailed {
    final normalized = status.toLowerCase();
    return ['failed', 'error'].contains(normalized);
  }

  String get displayTitle {
    final denomination = finalResult.denomination;
    final currency = finalResult.currency;

    if (denomination.toLowerCase() == 'unknown' && currency.toLowerCase() == 'unknown') {
      return 'Unknown Banknote';
    }

    if (currency.toLowerCase() == 'unknown') return denomination;
    return '$denomination $currency';
  }
}
