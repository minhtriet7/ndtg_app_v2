import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';
import 'banknote_result_model.dart';

class RecognitionTaskModel {
  final String taskId;
  final String status;
  final String stage;
  final String message;
  final String? errorMessage;
  final String? resultId;
  final String? inputImageUrl;
  final int progress;
  final String createdAt;
  final BanknoteResultModel? result;

  const RecognitionTaskModel({
    required this.taskId,
    required this.status,
    required this.stage,
    required this.message,
    this.errorMessage,
    this.resultId,
    this.inputImageUrl,
    required this.progress,
    required this.createdAt,
    this.result,
  });

  factory RecognitionTaskModel.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);
    final root = json.isNotEmpty ? json : JsonHelper.safeMap(raw);
    final wrappedTask = root['task'];
    final data = wrappedTask is Map
        ? Map<String, dynamic>.from(wrappedTask)
        : root;

    final embeddedResult = ResponseParser.getValue(data, [
      'result',
      'data.result',
      'recognition_result',
    ]);

    return RecognitionTaskModel(
      taskId: JsonHelper.safeString(
        ResponseParser.getValue(data, ['task_id', 'id', 'job_id']),
      ),
      status: JsonHelper.safeString(
        ResponseParser.getValue(data, ['status', 'state']),
        fallback: 'pending',
      ).toLowerCase(),
      stage: JsonHelper.safeString(
        ResponseParser.getValue(data, ['stage', 'step']),
        fallback: 'queued',
      ),
      message: JsonHelper.safeString(
        ResponseParser.getValue(data, [
          'message',
          'detail',
          'error_message',
          'stage',
        ]),
        fallback: 'The banknote image is being processed...',
      ),
      errorMessage: JsonHelper.safeStringOrNull(
        ResponseParser.getValue(data, ['error_message', 'error']),
      ),
      resultId: JsonHelper.safeStringOrNull(
        ResponseParser.getValue(data, [
          'result_id',
          'recognition_id',
          'scan_id',
        ]),
      ),
      inputImageUrl: JsonHelper.safeStringOrNull(
        ResponseParser.getValue(data, [
          'input_image_url',
          'uploaded_image_url',
          'image_url',
        ]),
      ),
      progress: JsonHelper.safeInt(
        ResponseParser.getValue(data, ['progress', 'percent']),
        fallback: 0,
      ),
      createdAt: JsonHelper.safeString(
        ResponseParser.getValue(data, ['created_at', 'started_at']),
      ),
      result: embeddedResult == null
          ? null
          : BanknoteResultModel.fromJson(embeddedResult),
    );
  }

  String get businessStatus {
    final nested = result?.normalizedStatus ?? '';
    return nested.isEmpty ? status : nested;
  }

  bool get hasTerminalResult {
    if (isFailed) return false;
    return _terminalBusinessStatuses.contains(businessStatus);
  }

  bool get isDone {
    return ['done', 'completed', 'success'].contains(status) ||
        hasTerminalResult;
  }

  bool get isFailed {
    return ['failed', 'error', 'cancelled'].contains(status);
  }

  bool get isProcessing {
    return ['pending', 'processing', 'running', 'queued'].contains(status);
  }

  static const Set<String> _terminalBusinessStatuses = {
    'completed',
    'completed_partial',
    'completed_with_limit',
    'no_banknote_detected',
    'needs_better_image',
    'needs_review',
    'consensus_failed',
    'agent_error',
    'technical_error',
    'failed',
  };
}
