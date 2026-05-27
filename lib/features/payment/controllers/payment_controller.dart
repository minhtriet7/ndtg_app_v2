import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../data/payment_service.dart';
import '../models/payment_model.dart';
import '../models/payment_status_model.dart';
import '../models/token_package_model.dart';
import '../models/transaction_model.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  bool _isLoading = false;
  bool _isPolling = false;
  String? _error;

  List<TokenPackageModel> _packages = [];
  List<TransactionModel> _transactions = [];
  PaymentModel? _currentPayment;
  PaymentStatusModel? _lastPaymentStatus;

  Timer? _pollingTimer;

  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;
  List<TokenPackageModel> get packages => _packages;
  List<TransactionModel> get transactions => _transactions;
  PaymentModel? get currentPayment => _currentPayment;
  PaymentStatusModel? get lastPaymentStatus => _lastPaymentStatus;

  Future<void> fetchPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _packages = await _service.getPackages();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load token packages.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _service.getMyTransactions();
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to load transactions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> initiatePayment(String packageId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPayment = await _service.createPayment(packageId);
      if (_currentPayment!.id.isNotEmpty) {
        await LocalStorage.instance.saveString(StorageKeys.activePaymentId, _currentPayment!.id);
      }
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : 'Unable to create payment invoice.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resumePendingPayment({
    required VoidCallback onSuccess,
    VoidCallback? onFailed,
  }) async {
    final paymentId = LocalStorage.instance.getString(StorageKeys.activePaymentId);
    if (paymentId == null || paymentId.isEmpty) return;

    startPollingPaymentStatus(
      paymentId: paymentId,
      onSuccess: onSuccess,
      onFailed: onFailed,
    );
  }

  void startPollingPaymentStatus({
    required String paymentId,
    required VoidCallback onSuccess,
    VoidCallback? onFailed,
  }) {
    stopPolling();
    _isPolling = true;
    _error = null;
    notifyListeners();

    int attempts = 0;
    const int maxAttempts = 72; // 72 * 5 seconds = 6 minutes

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      attempts++;

      if (attempts > maxAttempts) {
        _error = 'Payment verification timed out. You can reopen this screen to check again.';
        stopPolling();
        onFailed?.call();
        return;
      }

      try {
        final status = await _service.getPaymentStatus(paymentId);
        _lastPaymentStatus = status;

        if (status.isCompleted) {
          await LocalStorage.instance.remove(StorageKeys.activePaymentId);
          stopPolling();
          onSuccess();
          return;
        }

        if (status.isFailed) {
          await LocalStorage.instance.remove(StorageKeys.activePaymentId);
          _error = status.message;
          stopPolling();
          onFailed?.call();
          return;
        }

        notifyListeners();
      } catch (_) {
        // Keep polling through short network interruptions.
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    notifyListeners();
  }

  void clearCheckout() {
    stopPolling();
    _currentPayment = null;
    _lastPaymentStatus = null;
    _error = null;
    LocalStorage.instance.remove(StorageKeys.activePaymentId);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
