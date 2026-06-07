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
            'summary': 'Object #${item['object_index'] ?? ''}: ${item['country'] ?? ''} ${item['denomination'] ?? ''}',
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
      createdAt: ResponseParser.getValue(data, ['created_at', 'createdAt'], defaultValue: '').toString(),
      updatedAt: ResponseParser.getValue(data, ['updated_at', 'updatedAt'], defaultValue: '').toString(),
      finalResult: finalResult,
      agentResults: agents,
      rawJson: data,
    );
  }
}