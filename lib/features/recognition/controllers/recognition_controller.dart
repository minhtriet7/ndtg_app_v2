import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/constants/storage_keys.dart';
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

  AgentPipelineStatus copyWith({String? status}) {
    return AgentPipelineStatus(
      key: key,
      name: name,
      icon: icon,
      status: status ?? this.status,
      description: description,
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

  final List<AgentPipelineStatus> _agentStatuses = const [
    AgentPipelineStatus(
      key: 'vision',
      name: 'YOLO / Vision Agent',
      icon: Icons.center_focus_strong_rounded,
      status: 'waiting',
      description: 'Detects visual banknote patterns and denomination regions.',
    ),
    AgentPipelineStatus(
      key: 'llm',
      name: 'Gemini LLM Agent',
      icon: Icons.psychology_rounded,
      status: 'waiting',
      description: 'Reads textual clues and contextual evidence.',
    ),
    AgentPipelineStatus(
      key: 'lens',
      name: 'Visual Search Agent',
      icon: Icons.travel_explore_rounded,
      status: 'waiting',
      description: 'Checks external visual references when available.',
    ),
    AgentPipelineStatus(
      key: 'aggregator',
      name: 'Aggregator',
      icon: Icons.hub_rounded,
      status: 'waiting',
      description: 'Combines agent outputs into the final consensus.',
    ),
  ];

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get processingMessage => _processingMessage;
  BanknoteResultModel? get finalResult => _finalResult;
  double get progress => _progress;
  List<AgentPipelineStatus> get agentStatuses => _agentStatuses;

  void clearState() {
    _selectedImage = null;
    _error = null;
    _finalResult = null;
    _processingMessage = 'Preparing your banknote image...';
    _progress = 0.0;
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
    notifyListeners();
    return true;
  }

  Future<void> startAnalysis() async {
    if (_selectedImage == null || _isLoading) return;

    _isLoading = true;
    _error = null;
    _progress = 0.12;
    _processingMessage = 'Uploading image to the AI pipeline...';
    notifyListeners();

    try {
      final dynamic response = await _service.startRecognition(_selectedImage!);

      if (response is BanknoteResultModel) {
        _finalResult = response;
        _progress = 1.0;
        _processingMessage = 'Analysis completed.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final taskId = _extractTaskId(response);
      if (taskId != null && taskId.isNotEmpty) {
        await LocalStorage.instance.setString(StorageKeys.activeRecognitionTaskId, taskId);
        _pollTaskStatus(taskId);
        return;
      }

      final maybeResult = _extractResult(response);
      if (maybeResult != null) {
        _finalResult = maybeResult;
        _progress = 1.0;
        _processingMessage = 'Analysis completed.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      throw ApiException(message: 'The server returned an unsupported recognition response.');
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : 'Failed to analyze the banknote image.';
      notifyListeners();
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
        _isLoading = false;
        _error = 'AI processing timed out. Please try again.';
        notifyListeners();
        return;
      }

      try {
        final task = await _service.getTaskStatus(taskId);
        final normalizedStatus = task.status.toLowerCase();

        _processingMessage = task.message;
        _progress = ((attempts / maxAttempts) * 0.85).clamp(0.18, 0.92).toDouble();

        if (normalizedStatus == 'completed' ||
            normalizedStatus == 'success' ||
            normalizedStatus == 'done') {
          _cancelTimer();
          _progress = 0.96;
          _processingMessage = 'Fetching final result...';
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
            throw ApiException(message: 'Task completed but no result was returned.');
          }

          await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
          _progress = 1.0;
          _processingMessage = 'Analysis completed.';
          _isLoading = false;
          notifyListeners();
          return;
        }

        if (normalizedStatus == 'failed' || normalizedStatus == 'error') {
          _cancelTimer();
          _isLoading = false;
          _error = task.message.isNotEmpty ? task.message : 'AI analysis failed.';
          await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
          notifyListeners();
          return;
        }

        notifyListeners();
      } catch (e) {
        if (attempts > 3) {
          _processingMessage = 'Still processing. Waiting for AI agents...';
          notifyListeners();
        }
      }
    });
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
      if (result is Map<String, dynamic>) return BanknoteResultModel.fromJson(result);
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