import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';
import 'banknote_result_model.dart';

class RecognitionTaskModel {
  final String taskId;
  final String status;
  final String message;
  final String? resultId;
  final int progress;
  final BanknoteResultModel? result;

  const RecognitionTaskModel({
    required this.taskId,
    required this.status,
    required this.message,
    this.resultId,
    required this.progress,
    this.result,
  });

  factory RecognitionTaskModel.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);
    final data = json.isNotEmpty ? json : JsonHelper.safeMap(raw);

    final embeddedResult = ResponseParser.getValue(
      data,
      ['result', 'data.result', 'recognition_result'],
    );

    return RecognitionTaskModel(
      taskId: JsonHelper.safeString(
        ResponseParser.getValue(data, ['task_id', 'id', 'job_id']),
      ),
      status: JsonHelper.safeString(
        ResponseParser.getValue(data, ['status', 'state']),
        fallback: 'pending',
      ).toLowerCase(),
      message: JsonHelper.safeString(
        ResponseParser.getValue(data, ['message', 'detail']),
        fallback: 'AI agents are processing your banknote...',
      ),
      resultId: JsonHelper.safeStringOrNull(
        ResponseParser.getValue(data, ['result_id', 'recognition_id', 'scan_id']),
      ),
      progress: JsonHelper.safeInt(
        ResponseParser.getValue(data, ['progress', 'percent']),
        fallback: 0,
      ),
      result: embeddedResult == null ? null : BanknoteResultModel.fromJson(embeddedResult),
    );
  }

  bool get isDone {
    return ['done', 'completed', 'success'].contains(status);
  }

  bool get isFailed {
    return ['failed', 'error', 'cancelled'].contains(status);
  }

  bool get isProcessing {
    return ['pending', 'processing', 'running', 'queued'].contains(status);
  }
}
