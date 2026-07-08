import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class PaymentModel {
  final String id;
  final String hexId;
  final String status;

  /// Can be either a VietQR image URL returned by backend/web flow,
  /// or an old raw QR payload depending on API version.
  final String qrCode;

  /// Raw EMV/VietQR payload. This is safe to render with qr_flutter.
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

  static bool _looksLikeUrl(String value) {
    final text = value.trim().toLowerCase();
    return text.startsWith('http://') || text.startsWith('https://');
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = JsonHelper.safeString(ResponseParser.getValue(json, [key]));
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  /// Prefer the real VietQR image URL returned by the backend/web checkout.
  ///
  /// Do not pass this to QrImageView. It should be rendered with Image.network.
  String get qrImageUrl {
    final direct = _firstString(raw, const [
      'vietqr_image_url',
      'viet_qr_image_url',
      'qr_image_url',
      'qrImageUrl',
      'qr_url',
      'qrUrl',
      'vietqr_url',
      'vietQrUrl',
      'sepay_qr_url',
      'sepayQrUrl',
      'checkout_qr_url',
      'checkoutQrUrl',
    ]);

    if (_looksLikeUrl(direct)) return direct;

    // Backward compatibility: older parser stored qr_url/vietqr_url in qrCode.
    if (_looksLikeUrl(qrCode)) return qrCode;

    return '';
  }

  /// Raw QR payload for qr_flutter fallback only.
  ///
  /// If backend gives a VietQR image URL, this returns empty so the UI does not
  /// accidentally encode the URL/text into a broken payment QR.
  String get effectiveQrData {
    if (qrData.trim().isNotEmpty) return qrData.trim();
    if (qrCode.trim().isNotEmpty && !_looksLikeUrl(qrCode)) {
      return qrCode.trim();
    }
    return '';
  }

  bool get hasVietQrImage => qrImageUrl.isNotEmpty;
  bool get hasQrPayload => effectiveQrData.isNotEmpty;

  factory PaymentModel.fromJson(dynamic raw) {
    final root = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    final rawData = root['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : Map<String, dynamic>.from(root);
    final rawInvoice = data['invoice'];
    final invoice = rawInvoice is Map
        ? Map<String, dynamic>.from(rawInvoice)
        : const <String, dynamic>{};
    final json = <String, dynamic>{...invoice, ...data};

    return PaymentModel(
      id: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'id',
          '_id',
          'payment_id',
          'transaction_id',
        ]),
      ),
      hexId: JsonHelper.safeString(
        ResponseParser.getValue(json, ['hex_id', 'hexId', 'invoice_code']),
      ),
      status: JsonHelper.safeString(
        ResponseParser.getValue(json, ['status']),
        fallback: 'pending',
      ).toLowerCase(),

      // Keep compatibility with existing backend fields.
      qrCode: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'qr_code',
          'qrCode',
          'qr_url',
          'qrUrl',
          'vietqr_url',
          'vietQrUrl',
          'vietqr_image_url',
          'qr_image_url',
          'sepay_qr_url',
        ]),
      ),
      qrData: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'qr_data',
          'qrData',
          'qr_content',
          'qrContent',
          'qr_payload',
          'qrPayload',
          'vietqr_payload',
          'emv_qr',
          'emvQr',
        ]),
      ),
      transferContent: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'transfer_content',
          'content',
          'description',
          'bank_content',
        ]),
      ),
      bankName: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'bank_name',
          'bank_brand',
          'bank',
          'bank_id',
        ]),
      ),
      accountNumber: JsonHelper.safeString(
        ResponseParser.getValue(json, [
          'account_number',
          'bank_account_number',
          'bank_account',
          'receiver_account',
        ]),
      ),
      accountName: JsonHelper.safeString(
        ResponseParser.getValue(json, ['account_name', 'receiver_name']),
      ),
      amount: JsonHelper.safeDouble(
        ResponseParser.getValue(json, [
          'amount',
          'amount_vnd',
          'total_amount',
          'price_vnd',
        ]),
      ),
      tokens: JsonHelper.safeInt(
        ResponseParser.getValue(json, [
          'tokens',
          'token_amount',
          'tokens_added',
        ]),
      ),
      expiredAt: JsonHelper.safeString(
        ResponseParser.getValue(json, ['expired_at', 'expires_at']),
      ),
      raw: json,
    );
  }
}
