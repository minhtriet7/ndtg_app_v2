import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class PaymentModel {
  final String id;
  final String hexId;
  final String status;
  final String qrCode;
  final String qrData;
  final String transferContent;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final double amount;
  final int tokens;
  final String expiredAt;
  final Map<String, dynamic> raw;

  const PaymentModel({
    required this.id,
    required this.hexId,
    required this.status,
    required this.qrCode,
    required this.qrData,
    required this.transferContent,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.tokens,
    required this.expiredAt,
    required this.raw,
  });

  String get effectiveQrData => qrData.isNotEmpty ? qrData : qrCode;

  factory PaymentModel.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    return PaymentModel(
      id: JsonHelper.safeString(ResponseParser.getValue(json, ['id', '_id', 'payment_id'])),
      hexId: JsonHelper.safeString(ResponseParser.getValue(json, ['hex_id', 'hexId', 'invoice_code'])),
      status: JsonHelper.safeString(ResponseParser.getValue(json, ['status']), fallback: 'pending').toLowerCase(),
      qrCode: JsonHelper.safeString(ResponseParser.getValue(json, ['qr_code', 'qr_url', 'vietqr_url'])),
      qrData: JsonHelper.safeString(ResponseParser.getValue(json, ['qr_data', 'qr_content', 'qr_payload'])),
      transferContent: JsonHelper.safeString(
        ResponseParser.getValue(json, ['transfer_content', 'content', 'description', 'bank_content']),
        fallback: 'BANKNOTEAI',
      ),
      bankName: JsonHelper.safeString(
        ResponseParser.getValue(json, ['bank_name', 'bank_brand', 'bank']),
        fallback: 'Bank transfer',
      ),
      accountNumber: JsonHelper.safeString(
        ResponseParser.getValue(json, ['account_number', 'bank_account', 'receiver_account']),
      ),
      accountName: JsonHelper.safeString(
        ResponseParser.getValue(json, ['account_name', 'receiver_name']),
      ),
      amount: JsonHelper.safeDouble(
        ResponseParser.getValue(json, ['amount', 'amount_vnd', 'total_amount', 'price_vnd']),
      ),
      tokens: JsonHelper.safeInt(ResponseParser.getValue(json, ['tokens', 'token_amount', 'tokens_added'])),
      expiredAt: JsonHelper.safeString(ResponseParser.getValue(json, ['expired_at', 'expires_at'])),
      raw: Map<String, dynamic>.from(json),
    );
  }
}
