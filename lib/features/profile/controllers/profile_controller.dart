import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../routes/route_names.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../payment/controllers/payment_controller.dart';
import '../../recognition/controllers/recognition_controller.dart';
import '../data/profile_service.dart';
import '../models/user_model.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  UserModel? _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  UserModel? get profile => _profile;

  Future<void> fetchProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load your profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to update your profile.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    if (_isSaving) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.uploadAvatar(filePath);
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'photoUpdateFailed';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    if (context.mounted) {
      context.read<RecognitionController>().clearState();
      await context.read<PaymentController>().clearCheckout();
    }

    await SecureStorage.instance.clearAll();
    await LocalStorage.instance.remove(StorageKeys.userJson);
    await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
    await LocalStorage.instance.remove(
      StorageKeys.activeRecognitionTaskStartedAt,
    );
    await LocalStorage.instance.remove(StorageKeys.activeRecognitionInput);
    await LocalStorage.instance.remove(StorageKeys.lastRecognitionResultId);
    await LocalStorage.instance.remove(StorageKeys.activePaymentId);
    await LocalStorage.instance.remove(StorageKeys.activePaymentPayload);

    if (context.mounted) {
      await context.read<AuthController>().logout();
    }

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}
