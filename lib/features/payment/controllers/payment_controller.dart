import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/payment_service.dart';
import '../models/payment_model.dart';
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

  Timer? _pollingTimer;

  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;

  List<TokenPackageModel> get packages => _packages;
  List<TransactionModel> get transactions => _transactions;
  PaymentModel? get currentPayment => _currentPayment;

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

  Future<bool> initiatePayment(String packageId, {String gateway = 'sepay'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPayment = await _service.createPayment(packageId, gateway: gateway);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e is ApiException ? e.message : 'Unable to create checkout.';
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
    _pollingTimer?.cancel();
    _isPolling = true;
    notifyListeners();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      attempts++;

      if (attempts > 60) {
        timer.cancel();
        _isPolling = false;
        _error = 'Payment confirmation timed out.';
        notifyListeners();
        onFailed?.call();
        return;
      }

      try {
        final paymentStatus = await _service.getPaymentStatus(paymentId);
        final status = paymentStatus.status.toLowerCase();

        if (status == 'completed' || status == 'success' || status == 'paid') {
          timer.cancel();
          _isPolling = false;
          notifyListeners();
          await onSuccess();
        } else if (status == 'failed' || status == 'cancelled' || status == 'canceled') {
          timer.cancel();
          _isPolling = false;
          _error = 'Payment failed or was cancelled.';
          notifyListeners();
          onFailed?.call();
        }
      } catch (_) {
        // Keep polling. Temporary API errors should not break checkout.
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
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
