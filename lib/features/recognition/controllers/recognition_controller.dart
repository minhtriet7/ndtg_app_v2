import 'dart:async';
import 'dart:io';

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

  AgentPipelineStatus copyWith({
    String? status,
    String? description,
  }) {
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
  final RecognitionService _service = RecognitionService();

  File? _selectedImage;
  bool _isLoading = false;
  String? _error;
  String _processingMessage = 'Preparing your banknote image...';
  BanknoteResultModel? _finalResult;
  Timer? _pollingTimer;
  double _progress = 0.0;

  List<AgentPipelineStatus> _agentStatuses = _initialAgentStatuses();

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get processingMessage => _processingMessage;
  BanknoteResultModel? get finalResult => _finalResult;
  double get progress => _progress;
  List<AgentPipelineStatus> get agentStatuses => List.unmodifiable(_agentStatuses);

  static List<AgentPipelineStatus> _initialAgentStatuses() {
    return const [
      AgentPipelineStatus(
        key: 'vision',
        name: 'ML/DL Vision Agent',
        icon: Icons.center_focus_strong_rounded,
        status: 'waiting',
        description: 'Waiting to detect banknote regions and visual patterns.',
      ),
      AgentPipelineStatus(
        key: 'llm',
        name: 'LLM Reasoning Agent',
        icon: Icons.psychology_alt_rounded,
        status: 'waiting',
        description: 'Waiting to reason over text, denomination, and country clues.',
      ),
      AgentPipelineStatus(
        key: 'lens',
        name: 'Visual Search Agent',
        icon: Icons.travel_explore_rounded,
        status: 'waiting',
        description: 'Waiting to compare visual references when available.',
      ),
      AgentPipelineStatus(
        key: 'aggregator',
        name: 'Aggregator Decision',
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
    if (_selectedImage == null || _isLoading) return;

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
      _processingMessage = 'Vision agent is preparing banknote detection...';
      _setPipelineStage('vision_running');
      notifyListeners();

      final dynamic response = await _service.startRecognition(_selectedImage!);

      if (response is BanknoteResultModel) {
        _finalResult = response;
        _completePipeline();
        return;
      }

      final taskId = _extractTaskId(response);
      if (taskId != null && taskId.isNotEmpty) {
        await LocalStorage.instance.setString(
          StorageKeys.activeRecognitionTaskId,
          taskId,
        );
        _pollTaskStatus(taskId);
        return;
      }

      final maybeResult = _extractResult(response);
      if (maybeResult != null) {
        _finalResult = maybeResult;
        _completePipeline();
        return;
      }

      throw ApiException(
        message: 'The server returned an unsupported recognition response.',
      );
    } catch (e) {
      _failPipeline(
        e is ApiException ? e.message : 'Failed to analyze the banknote image.',
      );
    }
  }

  void _pollTaskStatus(String taskId) {
    int attempts = 0;
    const maxAttempts = 45;

    _cancelTimer();

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      attempts++;

      if (attempts > maxAttempts) {
        _cancelTimer();
        await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
        _failPipeline('AI processing timed out. Please try again.');
        return;
      }

      try {
        final task = await _service.getTaskStatus(taskId);
        final normalizedStatus = task.status.toLowerCase();

        _processingMessage = task.message.isNotEmpty
            ? task.message
            : _messageForAttempt(attempts);

        _progress = ((attempts / maxAttempts) * 0.82)
            .clamp(0.20, 0.92)
            .toDouble();

        _setPipelineFromAttempt(attempts, maxAttempts);

        if (normalizedStatus == 'completed' ||
            normalizedStatus == 'success' ||
            normalizedStatus == 'done') {
          _cancelTimer();

          _progress = 0.96;
          _processingMessage = 'Aggregator completed. Fetching final result...';
          _setPipelineStage('aggregator_running');
          notifyListeners();

          if (task.resultId != null && task.resultId!.isNotEmpty) {
            _finalResult = await _service.getResultDetail(task.resultId!);
          } else {
            final dynamic taskDynamic = task;
            final extracted = _extractResult(taskDynamic);
            if (extracted != null) {
              _finalResult = extracted;
            }
          }

          if (_finalResult == null) {
            throw ApiException(
              message: 'Task completed but no result was returned.',
            );
          }

          await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
          _completePipeline();
          return;
        }

        if (normalizedStatus == 'failed' || normalizedStatus == 'error') {
          _cancelTimer();
          await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
          _failPipeline(
            task.message.isNotEmpty ? task.message : 'AI analysis failed.',
          );
          return;
        }

        notifyListeners();
      } catch (_) {
        if (attempts > 3) {
          _processingMessage = 'Still processing. Waiting for AI agents...';
          _setPipelineFromAttempt(attempts, maxAttempts);
          notifyListeners();
        }
      }
    });
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
          _agent('vision', 'pending', 'Image uploaded. Waiting for visual detection.'),
          _agent('llm', 'waiting', 'Waiting for visual evidence.'),
          _agent('lens', 'waiting', 'Waiting for reference search.'),
          _agent('aggregator', 'waiting', 'Waiting for agent outputs.'),
        ];
        break;

      case 'vision_running':
        _agentStatuses = [
          _agent('vision', 'running', 'Detecting banknote object, layout, and visual features.'),
          _agent('llm', 'pending', 'Queued for reasoning after visual extraction.'),
          _agent('lens', 'waiting', 'Waiting for image reference search.'),
          _agent('aggregator', 'waiting', 'Waiting for agent votes.'),
        ];
        break;

      case 'llm_running':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual features extracted successfully.'),
          _agent('llm', 'running', 'Reasoning over denomination, text, and country clues.'),
          _agent('lens', 'pending', 'Queued for visual reference lookup.'),
          _agent('aggregator', 'waiting', 'Waiting for agent votes.'),
        ];
        break;

      case 'lens_running':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual features extracted successfully.'),
          _agent('llm', 'completed', 'Reasoning output received.'),
          _agent('lens', 'running', 'Comparing image against visual references.'),
          _agent('aggregator', 'pending', 'Preparing final consensus.'),
        ];
        break;

      case 'aggregator_running':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual features extracted successfully.'),
          _agent('llm', 'completed', 'Reasoning output received.'),
          _agent('lens', 'completed', 'Visual reference check completed.'),
          _agent('aggregator', 'running', 'Combining agent votes into the final decision.'),
        ];
        break;

      case 'completed':
        _agentStatuses = [
          _agent('vision', 'completed', 'Visual analysis completed.'),
          _agent('llm', 'completed', 'LLM reasoning completed.'),
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

  AgentPipelineStatus _agent(
      String key,
      String status,
      String description,
      ) {
    final base = _initialAgentStatuses().firstWhere((item) => item.key == key);
    return base.copyWith(status: status, description: description);
  }

  void _completePipeline() {
    _progress = 1.0;
    _processingMessage = 'Analysis completed. Preparing the result report...';
    _isLoading = false;
    _error = null;
    _setPipelineStage('completed');
    notifyListeners();
  }

  void _failPipeline(String message) {
    _isLoading = false;
    _error = message;
    _processingMessage = 'Analysis could not be completed.';
    _setPipelineStage('failed');
    notifyListeners();
  }

  String _messageForAttempt(int attempts) {
    if (attempts <= 4) {
      return 'Vision agent is extracting visual features...';
    }

    if (attempts <= 10) {
      return 'LLM agent is reasoning over denomination and country clues...';
    }

    if (attempts <= 18) {
      return 'Visual search is comparing reference signals...';
    }

    return 'Aggregator is evaluating consensus across agents...';
  }

  String? _extractTaskId(dynamic response) {
    try {
      final dynamic value = response.taskId;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final dynamic value = response.id;
      if (value != null) return value.toString();
    } catch (_) {}

    return null;
  }

  BanknoteResultModel? _extractResult(dynamic response) {
    if (response is BanknoteResultModel) return response;

    try {
      final dynamic result = response.result;
      if (result is BanknoteResultModel) return result;
      if (result is Map<String, dynamic>) {
        return BanknoteResultModel.fromJson(result);
      }
    } catch (_) {}

    try {
      final dynamic data = response.data;
      if (data is Map<String, dynamic>) return BanknoteResultModel.fromJson(data);
    } catch (_) {}

    return null;
  }

  List<AgentResultModel> get safeAgentResults {
    final result = _finalResult;
    if (result == null) return const [];
    return result.agentResults;
  }

  void _cancelTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}