import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../routes/route_names.dart';
import '../../auth/controllers/auth_controller.dart';
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

  Future<void> logout(BuildContext context) async {
    await SecureStorage.instance.clearAll();
    await LocalStorage.instance.remove(StorageKeys.userJson);
    await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
    await LocalStorage.instance.remove(StorageKeys.activePaymentId);

    if (context.mounted) {
      await context.read<AuthController>().logout();
    }

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
