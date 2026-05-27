import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

enum AgentStatus {
  waiting,
  processing,
  success,
  failed,
  warning,
}

class AgentResultModel {
  final String id;
  final String agentName;
  final String displayName;
  final AgentStatus status;
  final double confidence;
  final String summary;
  final Map<String, dynamic> data;

  const AgentResultModel({
    required this.id,
    required this.agentName,
    required this.displayName,
    required this.status,
    required this.confidence,
    required this.summary,
    required this.data,
  });

  factory AgentResultModel.placeholder({
    required String id,
    required String displayName,
    AgentStatus status = AgentStatus.waiting,
  }) {
    return AgentResultModel(
      id: id,
      agentName: id,
      displayName: displayName,
      status: status,
      confidence: 0,
      summary: 'Waiting for this agent to report.',
      data: const {},
    );
  }

  factory AgentResultModel.fromJson(dynamic raw) {
    final json = JsonHelper.safeMap(raw);
    final name = JsonHelper.safeString(
      ResponseParser.getValue(
        json,
        ['agent', 'agent_name', 'name', 'key', 'module'],
      ),
      fallback: 'unknown_agent',
    );

    final resultData = JsonHelper.safeMap(
      ResponseParser.getValue(json, ['data', 'result', 'output', 'payload']),
    );

    final confidenceRaw = ResponseParser.getValue(
      json,
      ['confidence', 'score', 'data.confidence', 'result.confidence'],
      defaultValue: resultData['confidence'] ?? resultData['score'] ?? 0,
    );

    return AgentResultModel(
      id: name.toLowerCase().replaceAll(' ', '_'),
      agentName: name,
      displayName: _formatAgentName(name),
      status: parseStatus(
        JsonHelper.safeString(
          ResponseParser.getValue(json, ['status', 'state']),
          fallback: 'success',
        ),
      ),
      confidence: JsonHelper.safeDouble(confidenceRaw),
      summary: JsonHelper.safeString(
        ResponseParser.getValue(
          json,
          ['summary', 'message', 'description', 'data.summary', 'result.summary'],
        ),
        fallback: _buildFallbackSummary(resultData),
      ),
      data: resultData.isNotEmpty ? resultData : json,
    );
  }

  static String _formatAgentName(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('yolo') || lower.contains('model') || lower.contains('agent_1')) {
      return 'YOLO / Vision Agent';
    }

    if (lower.contains('llm') || lower.contains('gemini') || lower.contains('agent_2')) {
      return 'Gemini LLM Agent';
    }

    if (lower.contains('lens') || lower.contains('serp') || lower.contains('agent_3')) {
      return 'Google Lens Agent';
    }

    if (lower.contains('aggregator') || lower.contains('vote')) {
      return 'Aggregator';
    }

    return name
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String _buildFallbackSummary(Map<String, dynamic> data) {
    if (data.isEmpty) return 'Agent completed without additional summary.';

    final denomination = data['denomination'] ?? data['menh_gia'] ?? data['final_denomination'];
    final currency = data['currency'] ?? data['loai_tien'];
    final country = data['country'] ?? data['quoc_gia'];

    final parts = [
      if (denomination != null) denomination.toString(),
      if (currency != null) currency.toString(),
      if (country != null) country.toString(),
    ];

    if (parts.isEmpty) return 'Agent returned structured data.';
    return parts.join(' • ');
  }

  static AgentStatus parseStatus(String value) {
    final normalized = value.toLowerCase().trim();

    if (['success', 'completed', 'done', 'ok'].contains(normalized)) {
      return AgentStatus.success;
    }

    if (['processing', 'running', 'in_progress'].contains(normalized)) {
      return AgentStatus.processing;
    }

    if (['failed', 'error', 'failure'].contains(normalized)) {
      return AgentStatus.failed;
    }

    if (['warning', 'needs_review', 'partial'].contains(normalized)) {
      return AgentStatus.warning;
    }

    return AgentStatus.waiting;
  }

  String get statusLabel {
    switch (status) {
      case AgentStatus.success:
        return 'Success';
      case AgentStatus.processing:
        return 'Processing';
      case AgentStatus.failed:
        return 'Failed';
      case AgentStatus.warning:
        return 'Review';
      case AgentStatus.waiting:
        return 'Waiting';
    }
  }

  double get normalizedConfidence {
    if (confidence > 1) return confidence / 100;
    if (confidence < 0) return 0;
    return confidence;
  }
}
