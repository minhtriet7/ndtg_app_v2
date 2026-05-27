import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_service.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _error;
  UserInfo? _currentUser;

  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;
  UserInfo? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      if (!response.hasToken) {
        throw ApiException(message: 'Login succeeded but no access token was returned.');
      }

      await _persistSession(response.accessToken, response.user);
      _setLoading(false);
      return true;
    } catch (error) {
      _setError(_readError(error, fallback: 'Login failed. Please check your credentials.'));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _authService.register(
        RegisterRequest(email: email, password: password, fullName: fullName),
      );

      if (!response.hasToken) {
        throw ApiException(message: 'Registration succeeded but no access token was returned.');
      }

      await _persistSession(response.accessToken, response.user);
      _setLoading(false);
      return true;
    } catch (error) {
      _setError(_readError(error, fallback: 'Registration failed. Please review your information.'));
      _setLoading(false);
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    final token = await SecureStorage.instance.getToken();
    if (token == null || token.isEmpty) {
      _currentUser = null;
      _isCheckingAuth = false;
      notifyListeners();
      return;
    }

    try {
      _currentUser = await _authService.getMe();
      await LocalStorage.instance.saveString(
        StorageKeys.userJson,
        jsonEncode(_currentUser!.toJson()),
      );
    } catch (_) {
      await logout(notify: false);
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    try {
      _currentUser = await _authService.getMe();
      await LocalStorage.instance.saveString(
        StorageKeys.userJson,
        jsonEncode(_currentUser!.toJson()),
      );
      notifyListeners();
    } catch (error) {
      _setError(_readError(error, fallback: 'Unable to refresh profile.'));
    }
  }

  Future<void> logout({bool notify = true}) async {
    await SecureStorage.instance.clearToken();
    await LocalStorage.instance.remove(StorageKeys.userJson);
    await LocalStorage.instance.remove(StorageKeys.activeRecognitionTaskId);
    await LocalStorage.instance.remove(StorageKeys.activePaymentId);
    _currentUser = null;
    _error = null;
    _isLoading = false;
    if (notify) notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> _persistSession(String token, UserInfo user) async {
    await SecureStorage.instance.saveToken(token);
    await LocalStorage.instance.saveString(StorageKeys.userJson, jsonEncode(user.toJson()));
    _currentUser = user;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  String _readError(Object error, {required String fallback}) {
    if (error is ApiException) return error.message;
    if (error is DioException) {
      final inner = error.error;
      if (inner is ApiException) return inner.message;
      if (error.message != null && error.message!.isNotEmpty) return error.message!;
    }
    return fallback;
  }
}
