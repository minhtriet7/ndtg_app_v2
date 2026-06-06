import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/response_parser.dart';
import '../models/payment_model.dart';
import '../models/payment_status_model.dart';
import '../models/token_package_model.dart';
import '../models/transaction_model.dart';

class PaymentService {
  final DioClient _client = DioClient();

  Future<List<TokenPackageModel>> getPackages() async {
    final response = await _client.get(ApiEndpoints.tokenPackages);
    final listData = ResponseParser.parseList(response);

    return listData
        .whereType<Map>()
        .map((e) => TokenPackageModel.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.isActive)
        .toList();
  }

  Future<PaymentModel> createPayment(String packageId, {String gateway = 'sepay'}) async {
    final response = await _client.post(
      ApiEndpoints.paymentCreate,
      data: {
        'package_id': packageId,
        'gateway': gateway,
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
