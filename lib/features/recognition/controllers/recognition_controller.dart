import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/file_validator.dart';
import '../../../core/utils/image_helper.dart';
import '../data/recognition_service.dart';
import '../models/agent_result_model.dart';
import '../models/banknote_result_model.dart';

class AgentPipelineStatus {
  final String key;
  final String name;
  final IconData icon;
  final String status;
  final String description;

  const AgentPipelineStatus({
    required this.key,
    required this.name,
    required this.icon,
    required this.status,
    required this.description,
  });

  AgentPipelineStatus copyWith({String? status, String? description}) {
    return AgentPipelineStatus(
      key: key,
      name: name,
      icon: icon,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}

class RecognitionController extends ChangeNotifier {
  RecognitionController() {
    unawaited(_restorePersistedState());
  }

  final RecognitionService _service = RecognitionService();

  File? _selectedImage;
  bool _isLoading = false;
  String? _error;
  String _processingMessage = 'Preparing your banknote image...';
  BanknoteResultModel? _finalResult;
  Timer? _pollingTimer;
  String? _pollingTaskId;
  bool _pollRequestInFlight = false;
  bool _disposed = false;
  double _progress = 0.0;

  List<AgentPipelineStatus> _agentStatuses = _initialAgentStatuses();

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get processingMessage => _processingMessage;
  BanknoteResultModel? get finalResult => _finalResult;
  double get progress => _progress;
  List<AgentPipelineStatus> get agentStatuses =>
      List.unmodifiable(_agentStatuses);

  static List<AgentPipelineStatus> _initialAgentStatuses() {
    return const [
      AgentPipelineStatus(
        key: 'vision',
        name: 'Visual analysis',
        icon: Icons.center_focus_strong_rounded,
        status: 'waiting',
        description:
            'Waiting to extract denomination, country, and visual features.',
      ),
      AgentPipelineStatus(
        key: 'llm',
        name: 'Evidence analysis',
        icon: Icons.fact_check_outlined,
        status: 'waiting',
        description:
            'Waiting to reason over text, denomination, and country clues.',
      ),
      AgentPipelineStatus(
        key: 'lens',
        name: 'Reference verification',
        icon: Icons.travel_explore_rounded,
        status: 'waiting',
        description: 'Waiting to compare visual references when available.',
      ),
      AgentPipelineStatus(
        key: 'aggregator',
        name: 'Consensus review',
        icon: Icons.hub_rounded,
        status: 'waiting',
        description: 'Waiting to combine agent outputs into a final decision.',
      ),
    ];
  }

  void clearState() {
    _selectedImage = null;
    _error = null;
    _finalResult = null;
    _processingMessage = 'Preparing your banknote image...';
    _progress = 0.0;
    _isLoading = false;
    _agentStatuses = _initialAgentStatuses();
    _cancelTimer();
    notifyListeners();
  }

  Future<bool> pickImage(bool fromCamera) async {
    clearState();

    final dynamic result = fromCamera
        ? await ImageHelper.pickImageFromCamera()
        : await ImageHelper.pickImageFromGallery();

    File? pickedFile;
    String? pickError;

    if (result is File) {
      pickedFile = result;
    } else if (result != null) {
      try {
        final bool success = result.success == true;
        if (success) {
          pickedFile = result.file as File?;
        } else {
          pickError = result.error?.toString();
        }
      } catch (_) {
        pickError = 'Unable to read selected image.';
      }
    }

    if (pickedFile == null) {
      _error = pickError;
      notifyListeners();
      return false;
    }

    final validationError = FileValidator.validateImageFile(pickedFile);
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _selectedImage = pickedFile;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> startAnalysis() async {
    if (_isLoading) return;

    final persistedTaskId = LocalStorage.instance.getString(
      StorageKeys.activeRecognitionTaskId,
    );
    if (persistedTaskId != null && persistedTaskId.trim().isNotEmpty) {
      await resumeActiveTask();
      return;
    }

    if (_selectedImage == null) return;

    _cancelTimer();
    _isLoading = true;
    _error = null;
    _finalResult = null;
    _progress = 0.10;
    _processingMessage = 'Uploading image to the AI workspace...';
    _setPipelineStage('uploading');
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      _progress = 0.18;
      _processingMessage = 'Preparing visual analysis...';
      _setPipelineStage('vision_running');
      notifyListeners();

      final response = await _service.startRecognition(_selectedImage!);

      if (response.result != null) {
        _finalResult = response.result;
        await _clearActiveTask();
        _completePipeline();
        return;
      }

      final taskId = response.task?.taskId;
      if (taskId != null && taskId.isNotEmpty) {
        await _saveActiveTask(taskId);
        _pollTaskStatus(taskId);
        return;
      }

      throw ApiException(message: 'recognitionUnsupportedResponse');
    } catch (e) {
      _failPipeline(e is ApiException ? e.message : 'recognitionAnalyzeFailed');
    }
  }

  Future<bool> resumeActiveTask() async {
    final taskId = LocalStorage.instance.getString(
      StorageKeys.activeRecognitionTaskId,
    );
    if (taskId == null || taskId.trim().isEmpty) return false;

    if (_pollingTaskId == taskId && _pollingTimer != null) return true;

    _isLoading = true;
    _error = null;
    _finalResult = null;
    _progress = _progress < 0.18 ? 0.18 : _progress;
    _processingMessage = 'Restoring the active recognition task...';
    _setPipelineStage('vision_running');
    if (!_disposed) notifyListeners();
    _pollTaskStatus(taskId);
    return true;
  }

  Future<void> restoreLastResult() async {
    if (_finalResult != null || _isLoading) return;

    final resultId = LocalStorage.instance.getString(
      StorageKeys.lastRecognitionResultId,
    );
    if (resultId == null || resultId.trim().isEmpty) return;

    _isLoading = true;
    if (!_disposed) notifyListeners();
    try {
      _finalResult = await _service.getResultDetail(resultId);
    } catch (_) {
      // History remains the source of truth if a saved result was removed.
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _restorePersistedState() async {
    await resumeActiveTask();
  }

  void _pollTaskStatus(String taskId) {
    final startedAt = LocalStorage.instance.getInt(
      StorageKeys.activeRecognitionTaskStartedAt,
    );
    final elapsedSeconds = startedAt == null
        ? 0
        : DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(startedAt))
              .inSeconds;
    int attempts = (elapsedSeconds ~/ 2).clamp(0, 119).toInt();
    const maxAttempts = 120;

    _cancelTimer();
    _pollingTaskId = taskId;

    Future<void> pollOnce() async {
      if (_pollRequestInFlight || _disposed || _pollingTaskId != taskId) {
        return;
      }

      _pollRequestInFlight = true;
      attempts++;

      if (attempts > maxAttempts) {
        _cancelTimer();
        await _clearActiveTask();
        _failPipeline('recognitionProcessingTimeout');
        _pollRequestInFlight = false;
        return;
      }

      try {
        final task = await _service.getTaskStatus(taskId);

        _processingMessage = task.message.isNotEmpty
            ? task.message
            : _messageForAttempt(attempts);

        _progress = task.progress > 0
            ? (task.progress / 100).clamp(0.20, 0.96).toDouble()
            : ((attempts / maxAttempts) * 0.82).clamp(0.20, 0.92).toDouble();

        _setPipelineFromTask(task.stage, attempts, maxAttempts);

        if (task.isFailed) {
          _cancelTimer();
          await _clearActiveTask();
          _failPipeline(
            task.errorMessage ??
                (task.message.isNotEmpty
                    ? task.message
                    : 'recognitionAnalyzeFailed'),
          );
          return;
        }

        if (task.isDone || task.hasTerminalResult) {
          _progress = 0.96;
          _processingMessage = 'Aggregator completed. Fetching final result...';
          _setPipelineStage('aggregator_running');
          if (!_disposed) notifyListeners();

          if (task.result != null) {
            _finalResult = task.result;
          } else if (task.resultId != null && task.resultId!.isNotEmpty) {
            _finalResult = await _service.getResultDetail(task.resultId!);
          }

          if (_finalResult == null) {
            _cancelTimer();
            await _clearActiveTask();
            _failPipeline(task.errorMessage ?? 'recognitionResultMissing');
            return;
          }

          _cancelTimer();
          await _clearActiveTask();
          _completePipeline();
          _pollRequestInFlight = false;
          return;
        }

        if (!_disposed) notifyListeners();
      } catch (error) {
        final apiError = error is ApiException
            ? error
            : error is DioException && error.error is ApiException
            ? error.error as ApiException
            : null;

        if (apiError != null &&
            const {401, 403, 404}.contains(apiError.statusCode)) {
          _cancelTimer();
          await _clearActiveTask();
          _failPipeline(apiError.message);
          return;
        }

        if (attempts > 3) {
          _processingMessage = 'Processing is still in progress...';
          _setPipelineFromAttempt(attempts, maxAttempts);
          if (!_disposed) notifyListeners();
        }
      } finally {
        _pollRequestInFlight = false;
      }
    }

    unawaited(pollOnce());
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(pollOnce()),
    );
  }

  void _setPipelineFromTask(String stage, int attempts, int maxAttempts) {
    final normalized = stage.toLowerCase();
    if (normalized.contains('aggregate') ||
        normalized.contains('consensus') ||
        normalized.contains('saving')) {
      _setPipelineStage('aggregator_running');
    } else if (normalized.contains('lens') || normalized.contains('search')) {
      _setPipelineStage('lens_running');
    } else if (normalized.contains('llm') || normalized.contains('agent')) {
      _setPipelineStage('llm_running');
    } else if (normalized.contains('crop') ||
        normalized.contains('image') ||
        normalized.contains('vision')) {
      _setPipelineStage('vision_running');
    } else {
      _setPipelineFromAttempt(attempts, maxAttempts);
    }
  }

  void _setPipelineFromAttempt(int attempts, int maxAttempts) {
    final ratio = attempts / maxAttempts;

    if (ratio < 0.22) {
      _setPipelineStage('vision_running');
    } else if (ratio < 0.46) {
      _setPipelineStage('llm_running');
    } else if (ratio < 0.70) {
      _setPipelineStage('lens_running');
    } else {
      _setPipelineStage('aggregator_running');
    }
  }

  void _setPipelineStage(String stage) {
    switch (stage) {
      case 'uploading':
        _agentStatuses = [
          _agent(
            'vision',
            'pending',
            'Image uploaded. Waiting for visual analysis.',
          ),
          _agent('llm', 'waiting', 'Waiting for visual evidence.'),
          _agent('lens', 'waiting', 'Waiting for reference search.'),
          _agent('aggregator', 'waiting', 'Waiting for agent outputs.'),
        ];
        break;

      case 'vision_running':
        _agentStatuses = [
          _agent(
            'vision',
            'running',
            'Analyzing banknote denomination and country.',
          ),
          _agent(
            'llm',
            'pending',
            'Queued for reasoning after visual extraction.',
          ),
          _agent('lens', 'waiting', 'Waiting for image reference search.'),
          _agent('aggregator', 'waiting', 'Waiting for agent votes.'),
        ];
        break;

      case 'llm_running':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual analysis completed.'),
          _agent(
            'llm',
            'running',
            'Reasoning over denomination, text, and country clues.',
          ),
          _agent('lens', 'pending', 'Queued for visual reference lookup.'),
          _agent('aggregator', 'waiting', 'Waiting for agent votes.'),
        ];
        break;

      case 'lens_running':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual analysis completed.'),
          _agent('llm', 'completed', 'Reasoning output received.'),
          _agent(
            'lens',
            'running',
            'Comparing image against visual references.',
          ),
          _agent('aggregator', 'pending', 'Preparing final consensus.'),
        ];
        break;

      case 'aggregator_running':
        _agentStatuses = [
          _agent(
            'vision',
            'completed',
            'Visual features extracted successfully.',
          ),
          _agent('llm', 'completed', 'Reasoning output received.'),
          _agent('lens', 'completed', 'Visual reference check completed.'),
          _agent(
            'aggregator',
            'running',
            'Combining agent votes into the final decision.',
          ),
        ];
        break;

      case 'completed':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual analysis completed.'),
          _agent('llm', 'completed', 'Evidence analysis completed.'),
          _agent('lens', 'completed', 'Visual search completed.'),
          _agent('aggregator', 'completed', 'Consensus decision completed.'),
        ];
        break;

      case 'failed':
        _agentStatuses = _agentStatuses.map((item) {
          final current = item.status.toLowerCase();
          if (current == 'completed') return item;
          return item.copyWith(
            status: current == 'running' ? 'failed' : 'waiting',
            description: current == 'running'
                ? 'This stage failed or was interrupted.'
                : item.description,
          );
        }).toList();
        break;
    }
  }

  AgentPipelineStatus _agent(String key, String status, String description) {
    final base = _initialAgentStatuses().firstWhere((item) => item.key == key);
    return base.copyWith(status: status, description: description);
  }

  void _completePipeline() {
    _progress = 1.0;
    _processingMessage = 'Analysis completed. Preparing the result report...';
    _isLoading = false;
    _error = null;
    _setPipelineStage('completed');
    final resultId = _finalResult?.id;
    if (resultId != null && resultId.isNotEmpty) {
      unawaited(
        LocalStorage.instance.setString(
          StorageKeys.lastRecognitionResultId,
          resultId,
        ),
      );
    }
    if (!_disposed) notifyListeners();
  }

  void _failPipeline(String message) {
    _isLoading = false;
    _error = message;
    _processingMessage = 'Analysis could not be completed.';
    _setPipelineStage('failed');
    if (!_disposed) notifyListeners();
  }

  String _messageForAttempt(int attempts) {
    if (attempts <= 4) {
      return 'Extracting visual banknote details...';
    }

    if (attempts <= 10) {
      return 'Reviewing denomination and country evidence...';
    }

    if (attempts <= 18) {
      return 'Visual search is comparing reference signals...';
    }

    return 'Aggregator is evaluating consensus across agents...';
  }

  Future<void> _saveActiveTask(String taskId) async {
    await LocalStorage.instance.setString(
      StorageKeys.activeRecognitionTaskId,
      taskId,
    );
    await LocalStorage.instance.setInt(
      StorageKeys.activeRecognitionTaskStartedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _clearActiveTask() async {
    await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
    await LocalStorage.instance.remove(
      StorageKeys.activeRecognitionTaskStartedAt,
    );
  }

  List<AgentResultModel> get safeAgentResults {
    final result = _finalResult;
    if (result == null) return const [];
    return result.agentResults;
  }

  void _cancelTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingTaskId = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimer();
    super.dispose();
  }
}
