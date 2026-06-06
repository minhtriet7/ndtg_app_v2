import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_service.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  UserInfo? _currentUser;
  bool _isCheckingAuth = true;

  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;
  UserInfo? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      if (response.accessToken.isNotEmpty) {
        await SecureStorage.instance.saveToken(response.accessToken);
      }
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : 'Đăng nhập thất bại. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Gọi API Đăng ký (Backend chỉ tạo tài khoản, không cấp Token)
      await _authService.register(
        RegisterRequest(email: email, password: password, fullName: fullName),
      );

      // 2. Tự động gọi API Đăng nhập ngầm để lấy Token lưu vào máy
      final loginResponse = await _authService.login(
        LoginRequest(email: email, password: password),
      );

      if (loginResponse.accessToken.isNotEmpty) {
        await SecureStorage.instance.saveToken(loginResponse.accessToken);
      }

      _currentUser = loginResponse.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : 'Không thể tạo tài khoản.';
      notifyListeners();
      return false;
    }
  }

  // ĐÃ THÊM LẠI HÀM NÀY ĐỂ FIX LỖI ĐỎ Ở MÀN HÌNH LOGIN/REGISTER
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.authenticateWithGoogle();

      await SecureStorage.instance.saveToken(token);
      _currentUser = await _authService.getMe();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException
          ? e.message
          : 'Google sign-in was cancelled or failed.';
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    final token = await SecureStorage.instance.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        _currentUser = await _authService.getMe();
      } catch (_) {
        await logout();
      }
    } else {
      _currentUser = null;
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await SecureStorage.instance.clearToken();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}