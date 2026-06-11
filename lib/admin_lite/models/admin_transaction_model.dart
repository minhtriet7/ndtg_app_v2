import '../../core/utils/json_helper.dart';

class AdminTransactionModel {
  final String id;
  final String transactionCode;
  final String userId;
  final String userEmail;
  final String packageName;
  final double amount;
  final int tokensAdded;
  final String gateway;
  final String status;
  final String createdAt;

  const AdminTransactionModel({
    required this.id,
    required this.transactionCode,
    required this.userId,
    required this.userEmail,
    required this.packageName,
    required this.amount,
    required this.tokensAdded,
    required this.gateway,
    required this.status,
    required this.createdAt,
  });

  factory AdminTransactionModel.fromJson(Map<String, dynamic> json) {
    return AdminTransactionModel(
      id: JsonHelper.safeString(
        JsonHelper.getValue(json, ['id', '_id', 'transaction_id']),
      ),
      transactionCode: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'transaction_code',
          'payment_code',
          'checkout_code',
          'code',
          'order_code',
          'reference_code',
        ]),
        defaultValue: 'UNKNOWN',
      ),
      userId: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'user_id',
          'user.id',
          'user._id',
          'userId',
        ]),
      ),
      userEmail: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'user.email',
          'email',
          'user_email',
          'userEmail',
          'customer_email',
        ]),
        defaultValue: 'Unknown user',
      ),
      packageName: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'package_name',
          'package.name',
          'token_package.name',
          'tokenPackage.name',
          'plan_name',
        ]),
        defaultValue: 'Token Package',
      ),
      amount: JsonHelper.safeDouble(
        JsonHelper.getValue(json, [
          'amount',
          'amount_vnd',
          'total_amount',
          'total',
          'price',
          'paid_amount',
        ]),
      ),
      tokensAdded: JsonHelper.safeInt(
        JsonHelper.getValue(json, [
          'tokens_added',
          'tokens',
          'token_amount',
          'token_count',
          'package.tokens',
          'token_package.tokens',
        ]),
      ),
      gateway: JsonHelper.safeString(
        JsonHelper.getValue(json, [
          'gateway',
          'provider',
          'payment_gateway',
          'method',
        ]),
        defaultValue: 'sepay',
      ),
      status: JsonHelper.safeString(
        JsonHelper.getValue(json, ['status', 'payment_status']),
        defaultValue: 'pending',
      ),
      createdAt: JsonHelper.safeString(
        JsonHelper.getValue(json, ['created_at', 'createdAt', 'created']),
      ),
    );
  }

  bool get isPending {
    final value = status.toLowerCase();
    return value.contains('pending') ||
        value.contains('waiting') ||
        value.contains('unpaid') ||
        value.contains('processing');
  }
}