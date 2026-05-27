import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../data/feedback_service.dart';
import '../models/feedback_model.dart';

class FeedbackController extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  bool _isLoading = false;
  String? _error;
  List<FeedbackModel> _feedbacks = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeedbackModel> get feedbacks => _feedbacks;

  Future<void> fetchFeedbacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feedbacks = await _service.getMyFeedbacks();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load your feedback.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required String message,
    required int rating,
    String type = 'general',
    String? recognitionResultId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newFeedback = await _service.createFeedback(
        message: message,
        rating: rating,
        type: type,
        recognitionResultId: recognitionResultId,
      );
      _feedbacks.insert(0, newFeedback);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to submit feedback.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
