import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/local_storage.dart';
import '../data/payment_service.dart';
import '../models/payment_model.dart';
import '../models/token_package_model.dart';
import '../models/transaction_model.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  PaymentController() {
    unawaited(_restoreActivePayment());
  }

  bool _isLoading = false;
  bool _isPolling = false;
  bool _isCheckingStatus = false;
  bool _isRestoringPayment = true;
  bool _pollRequestInFlight = false;
  int _pollingGeneration = 0;
  String? _error;

  bool _isUsingGatewayFallback = false;
  String _latestPaymentStatus = 'pending';

  List<String> _enabledGateways = const [];
  List<TokenPackageModel> _packages = [];
  List<TransactionModel> _transactions = [];
  PaymentModel? _currentPayment;

  Timer? _pollingTimer;

  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  bool get isCheckingStatus => _isCheckingStatus;
  bool get isRestoringPayment => _isRestoringPayment;
  bool get isUsingGatewayFallback => _isUsingGatewayFallback;
  bool get hasAvailablePaymentMethod => _enabledGateways.isNotEmpty;
  String get latestPaymentStatus => _latestPaymentStatus;
  String? get error => _error;

  List<String> get enabledGateways => List.unmodifiable(_enabledGateways);
  List<TokenPackageModel> get packages => _packages;
  List<TransactionModel> get transactions => _transactions;
  PaymentModel? get currentPayment => _currentPayment;

  Future<void> fetchPackages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final availability = await _service.getGatewayAvailability();
      _enabledGateways = availability.gateways;
      _isUsingGatewayFallback = availability.usedFallback;
      _packages = await _service.getPackages();
    } catch (e) {
      _error = e is ApiException ? e.message : 'paymentPackagesLoadError';
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
      _error = e is ApiException ? e.message : 'transactionsLoadError';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> initiatePayment(
    String packageId, {
    String gateway = 'bank_transfer',
  }) async {
    if (_enabledGateways.isEmpty) {
      _error = 'noPaymentMethodAvailable';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalizedGateway = gateway.trim().toLowerCase();
      final safeGateway = _enabledGateways.contains(normalizedGateway)
          ? normalizedGateway
          : _enabledGateways.first;
      _currentPayment = await _service.createPayment(
        packageId,
        gateway: safeGateway,
      );
      _latestPaymentStatus = _currentPayment!.status;
      await _persistActivePayment(_currentPayment!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : 'checkoutCreateError';
      notifyListeners();
      return false;
    }
  }

  void startPollingPaymentStatus({
    required String paymentId,
    required Future<void> Function() onSuccess,
    VoidCallback? onFailed,
  }) {
    int attempts = 0;
    stopPolling(notify: false);
    final generation = ++_pollingGeneration;
    _isPolling = true;
    notifyListeners();

    Future<void> pollOnce() async {
      if (_pollRequestInFlight || generation != _pollingGeneration) return;
      _pollRequestInFlight = true;
      attempts++;

      if (attempts > 60) {
        _pollingTimer?.cancel();
        _isPolling = false;
        _error = 'paymentConfirmationTimeout';
        notifyListeners();
        onFailed?.call();
        _pollRequestInFlight = false;
        return;
      }

      try {
        final paymentStatus = await _service.getPaymentStatus(paymentId);
        if (generation != _pollingGeneration) return;
        final status = paymentStatus.status.toLowerCase();
        _latestPaymentStatus = status;

        if (_isSuccessfulStatus(status)) {
          _pollingTimer?.cancel();
          _isPolling = false;
          await _clearActivePaymentStorage();
          notifyListeners();
          await onSuccess();
        } else if (_isFailedStatus(status)) {
          _pollingTimer?.cancel();
          _isPolling = false;
          _error = 'paymentFailedOrCancelled';
          await _clearActivePaymentStorage();
          notifyListeners();
          onFailed?.call();
        } else {
          notifyListeners();
        }
      } catch (_) {
        // Keep polling. Temporary API errors should not break checkout.
      } finally {
        _pollRequestInFlight = false;
      }
    }

    unawaited(pollOnce());
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => unawaited(pollOnce()),
    );
  }

  Future<void> checkPaymentStatusNow({
    required Future<void> Function() onSuccess,
    VoidCallback? onFailed,
  }) async {
    final paymentId = _currentPayment?.id ?? '';
    if (paymentId.isEmpty || _pollRequestInFlight) return;

    _pollRequestInFlight = true;
    _isCheckingStatus = true;
    _error = null;
    notifyListeners();

    try {
      final paymentStatus = await _service.getPaymentStatus(paymentId);
      final status = paymentStatus.status.toLowerCase();
      _latestPaymentStatus = status;

      if (_isSuccessfulStatus(status)) {
        _pollingTimer?.cancel();
        _isPolling = false;
        await _clearActivePaymentStorage();
        notifyListeners();
        await onSuccess();
      } else if (_isFailedStatus(status)) {
        _pollingTimer?.cancel();
        _isPolling = false;
        _error = 'paymentFailedOrCancelled';
        await _clearActivePaymentStorage();
        notifyListeners();
        onFailed?.call();
      }
    } catch (_) {
      _error = 'paymentStatusCheckError';
    } finally {
      _pollRequestInFlight = false;
      _isCheckingStatus = false;
      notifyListeners();
    }
  }

  bool _isSuccessfulStatus(String status) {
    return status == 'completed' || status == 'success' || status == 'paid';
  }

  bool _isFailedStatus(String status) {
    return status == 'failed' ||
        status == 'cancelled' ||
        status == 'canceled' ||
        status == 'expired';
  }

  void stopPolling({bool notify = true}) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingGeneration++;
    _isPolling = false;
    if (notify) notifyListeners();
  }

  Future<void> clearCheckout() async {
    stopPolling();
    _currentPayment = null;
    _latestPaymentStatus = 'pending';
    _error = null;
    await _clearActivePaymentStorage();
    notifyListeners();
  }

  Future<void> _restoreActivePayment() async {
    try {
      final payload = LocalStorage.instance.getString(
        StorageKeys.activePaymentPayload,
      );
      if (payload == null || payload.trim().isEmpty) return;

      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      final payment = PaymentModel.fromJson(Map<String, dynamic>.from(decoded));
      if (payment.id.isNotEmpty) {
        _currentPayment = payment;
        _latestPaymentStatus = payment.status;
      }
    } catch (_) {
      await _clearActivePaymentStorage();
    } finally {
      _isRestoringPayment = false;
      notifyListeners();
    }
  }

  Future<void> _persistActivePayment(PaymentModel payment) async {
    final payload = Map<String, dynamic>.from(payment.raw);
    payload.putIfAbsent('id', () => payment.id);
    await LocalStorage.instance.setString(
      StorageKeys.activePaymentId,
      payment.id,
    );
    await LocalStorage.instance.setString(
      StorageKeys.activePaymentPayload,
      jsonEncode(payload),
    );
  }

  Future<void> _clearActivePaymentStorage() async {
    await LocalStorage.instance.remove(StorageKeys.activePaymentId);
    await LocalStorage.instance.remove(StorageKeys.activePaymentPayload);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
