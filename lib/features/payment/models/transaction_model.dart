import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class TransactionModel {
  final String id;
  final String transactionCode;
  final double amount;
  final int tokensAdded;
  final String status;
  final String gateway;
  final String createdAt;
  final String paidAt;
  final String transferContent;
  final Map<String, dynamic> raw;

  const TransactionModel({
    required this.id,
    required this.transactionCode,
    required this.amount,
    required this.tokensAdded,
    required this.status,
    required this.gateway,
    required this.createdAt,
    required this.paidAt,
    required this.transferContent,
    required this.raw,
  });

  bool get isSuccess =>
      ['success', 'completed', 'paid'].contains(status.toLowerCase());
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => [
    'failed',
    'cancelled',
    'canceled',
    'expired',
  ].contains(status.toLowerCase());

  factory TransactionModel.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    return TransactionModel(
      id: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'id',
          '_id',
          'transaction_id',
          'payment_id',
        ]),
      ),
      transactionCode: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'transaction_code',
          'payment_code',
          'checkout_code',
          'code',
          'hex_id',
        ]),
        fallback: 'UNKNOWN',
      ),
      amount: JsonHelper.safeDouble(
        ResponseParser.getValue(json, [
          'amount',
          'amount_vnd',
          'total_amount',
          'price_vnd',
        ]),
      ),
      tokensAdded: JsonHelper.safeInt(
        ResponseParser.getValue(json, [
          'tokens_added',
          'tokens',
          'token_amount',
        ]),
      ),
      status: JsonHelper.safeString(
        ResponseParser.getValue(json, ['status']),
        fallback: 'pending',
      ).toLowerCase(),
      gateway: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'gateway',
          'provider',
          'payment_gateway',
        ]),
        fallback: 'bank_transfer',
      ),
      createdAt: JsonHelper.safeString(
        ResponseParser.getValue(json, ['created_at', 'createdAt']),
      ),
      paidAt: JsonHelper.safeString(
        ResponseParser.getValue(json, ['paid_at', 'completed_at']),
      ),
      transferContent: JsonHelper.safeString(
        ResponseParser.getValue(json, ['transfer_content', 'content']),
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
