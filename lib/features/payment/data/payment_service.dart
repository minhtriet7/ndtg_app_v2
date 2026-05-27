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
    return listData.map((e) => TokenPackageModel.fromJson(e)).where((e) => e.isActive).toList();
  }

  Future<PaymentModel> createPayment(String packageId) async {
    final response = await _client.post(
      ApiEndpoints.paymentCreate,
      data: {'package_id': packageId},
    );
    return PaymentModel.fromJson(ResponseParser.parseMap(response));
  }

  Future<PaymentStatusModel> getPaymentStatus(String paymentId) async {
    final response = await _client.get(ApiEndpoints.paymentStatus(paymentId));
    return PaymentStatusModel.fromJson(ResponseParser.parseMap(response));
  }

  Future<List<TransactionModel>> getMyTransactions() async {
    final response = await _client.get(ApiEndpoints.myTransactions);
    final listData = ResponseParser.parseList(response);
    return listData.map((e) => TransactionModel.fromJson(e)).toList();
  }
}
