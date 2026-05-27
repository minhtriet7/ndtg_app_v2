import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class PaymentStatusModel {
  final String id;
  final String status;
  final String message;
  final int tokensAdded;
  final double amount;
  final String paidAt;
  final Map<String, dynamic> raw;

  const PaymentStatusModel({
    required this.id,
    required this.status,
    required this.message,
    required this.tokensAdded,
    required this.amount,
    required this.paidAt,
    required this.raw,
  });

  bool get isCompleted => ['completed', 'success', 'paid'].contains(status.toLowerCase());
  bool get isFailed => ['failed', 'cancelled', 'canceled', 'expired'].contains(status.toLowerCase());
  bool get isPending => !isCompleted && !isFailed;

  factory PaymentStatusModel.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    return PaymentStatusModel(
      id: JsonHelper.safeString(ResponseParser.getValue(json, ['id', '_id', 'payment_id'])),
      status: JsonHelper.safeString(
        ResponseParser.getValue(json, ['status', 'payment_status']),
        fallback: 'pending',
      ).toLowerCase(),
      message: JsonHelper.safeString(
        ResponseParser.getValue(json, ['message', 'detail']),
        fallback: 'Waiting for payment confirmation.',
      ),
      tokensAdded: JsonHelper.safeInt(
        ResponseParser.getValue(json, ['tokens_added', 'tokens', 'token_amount']),
      ),
      amount: JsonHelper.safeDouble(
        ResponseParser.getValue(json, ['amount', 'amount_vnd', 'total_amount', 'price_vnd']),
      ),
      paidAt: JsonHelper.safeString(ResponseParser.getValue(json, ['paid_at', 'completed_at'])),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
