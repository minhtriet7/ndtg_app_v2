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
      id: JsonHelper.safeString(JsonHelper.getValue(json, ['id', '_id'])),
      transactionCode: JsonHelper.safeString(
        JsonHelper.getValue(json, ['transaction_code', 'payment_code', 'checkout_code']),
        defaultValue: 'UNKNOWN',
      ),
      userId: JsonHelper.safeString(
        JsonHelper.getValue(json, ['user_id', 'user.id', 'user._id']),
      ),
      userEmail: JsonHelper.safeString(
        JsonHelper.getValue(json, ['user.email', 'email']),
        defaultValue: 'Unknown user',
      ),
      packageName: JsonHelper.safeString(
        JsonHelper.getValue(json, ['package_name', 'package.name', 'token_package.name']),
        defaultValue: 'Token Package',
      ),
      amount: JsonHelper.safeDouble(
        JsonHelper.getValue(json, ['amount', 'amount_vnd', 'total_amount', 'price']),
      ),
      tokensAdded: JsonHelper.safeInt(
        JsonHelper.getValue(json, ['tokens_added', 'tokens', 'token_amount']),
      ),
      gateway: JsonHelper.safeString(
        JsonHelper.getValue(json, ['gateway', 'provider', 'payment_gateway']),
        defaultValue: 'sepay',
      ),
      status: JsonHelper.safeString(
        JsonHelper.getValue(json, ['status']),
        defaultValue: 'pending',
      ),
      createdAt: JsonHelper.safeString(
        JsonHelper.getValue(json, ['created_at', 'createdAt']),
      ),
    );
  }
}