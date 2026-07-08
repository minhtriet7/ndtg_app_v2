import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/response_parser.dart';
import '../models/payment_model.dart';
import '../models/payment_status_model.dart';
import '../models/token_package_model.dart';
import '../models/transaction_model.dart';

class PaymentGatewayAvailability {
  final List<String> gateways;
  final bool usedFallback;

  const PaymentGatewayAvailability({
    required this.gateways,
    required this.usedFallback,
  });
}

class PaymentService {
  final DioClient _client = DioClient();

  Future<PaymentGatewayAvailability> getGatewayAvailability() async {
    try {
      final response = await _client.get(ApiEndpoints.paymentGatewaySettings);
      final root = ResponseParser.parseMap(response);
      final data = ResponseParser.parseMap(root['data'] ?? root);
      final paymentEnabled = data['feature_payment_enabled'] != false;
      final rawGateways = data['enabled_payment_gateways'];
      final vnpayEnabled = data['vnpay_enabled'] == true;

      if (!paymentEnabled) {
        return const PaymentGatewayAvailability(
          gateways: [],
          usedFallback: false,
        );
      }

      if (rawGateways is List) {
        final gateways = rawGateways
            .map((item) => item.toString().trim().toLowerCase())
            .map((item) {
              if (item == 'vietqr' || item == 'qr') return 'bank_transfer';
              return item;
            })
            .where(
              (item) =>
                  item == 'bank_transfer' || (item == 'vnpay' && vnpayEnabled),
            )
            .toSet()
            .toList();

        return PaymentGatewayAvailability(
          gateways: gateways,
          usedFallback: false,
        );
      }

      // A successful settings response without an enabled list means that the
      // server did not publish a usable payment method. Do not invent one.
      return const PaymentGatewayAvailability(
        gateways: [],
        usedFallback: false,
      );
    } catch (_) {
      // Bank transfer is the backend's safe public fallback when settings
      // cannot be loaded because of a temporary network/API problem.
      return const PaymentGatewayAvailability(
        gateways: ['bank_transfer'],
        usedFallback: true,
      );
    }
  }

  Future<List<TokenPackageModel>> getPackages() async {
    final response = await _client.get(ApiEndpoints.tokenPackages);
    final listData = ResponseParser.parseList(response);

    return listData
        .whereType<Map>()
        .map((e) => TokenPackageModel.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.isActive)
        .toList();
  }

  Future<PaymentModel> createPayment(
    String packageId, {
    String gateway = 'bank_transfer',
  }) async {
    final normalizedGateway = gateway.trim().toLowerCase();
    final response = await _client.post(
      ApiEndpoints.paymentCreate,
      data: {
        'package_id': packageId,
        'gateway': normalizedGateway.isEmpty
            ? 'bank_transfer'
            : normalizedGateway,
      },
    );

    return PaymentModel.fromJson(ResponseParser.parseMap(response));
  }

  Future<PaymentStatusModel> getPaymentStatus(String paymentId) async {
    final response = await _client.get(ApiEndpoints.paymentStatus(paymentId));
    return PaymentStatusModel.fromJson(ResponseParser.parseMap(response));
  }

  Future<List<TransactionModel>> getMyTransactions({int limit = 20}) async {
    try {
      final response = await _client.get(
        ApiEndpoints.myTransactions,
        queryParameters: {'limit': limit},
      );

      final listData = ResponseParser.parseList(response);
      return listData
          .whereType<Map>()
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      final response = await _client.get(
        ApiEndpoints.myUserTransactions,
        queryParameters: {'limit': limit},
      );

      final listData = ResponseParser.parseList(response);
      return listData
          .whereType<Map>()
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }
}
