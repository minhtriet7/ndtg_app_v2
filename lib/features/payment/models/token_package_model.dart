import '../../../core/network/response_parser.dart';
import '../../../core/utils/json_helper.dart';

class TokenPackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int tokens;
  final int bonus;
  final bool isActive;
  final bool isPopular;
  final String currency;
  final String createdAt;

  const TokenPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tokens,
    required this.bonus,
    required this.isActive,
    required this.isPopular,
    required this.currency,
    required this.createdAt,
  });

  int get totalTokens => tokens + bonus;

  factory TokenPackageModel.fromJson(dynamic raw) {
    final json = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    return TokenPackageModel(
      id: JsonHelper.safeString(ResponseParser.getValue(json, ['id', '_id', 'package_id'])),
      name: JsonHelper.safeString(
        ResponseParser.getValue(json, ['name', 'package_name', 'title']),
        fallback: 'Token Package',
      ),
      description: JsonHelper.safeString(
        ResponseParser.getValue(json, ['description', 'subtitle']),
        fallback: 'AI recognition token bundle',
      ),
      price: JsonHelper.safeDouble(
        ResponseParser.getValue(json, ['price', 'amount', 'amount_vnd', 'price_vnd']),
      ),
      tokens: JsonHelper.safeInt(
        ResponseParser.getValue(json, ['tokens', 'token_amount', 'token_count']),
      ),
      bonus: JsonHelper.safeInt(
        ResponseParser.getValue(json, ['bonus', 'bonus_tokens', 'extra_tokens']),
      ),
      isActive: JsonHelper.safeBool(
        ResponseParser.getValue(json, ['is_active', 'active', 'enabled']),
        fallback: true,
      ),
      isPopular: JsonHelper.safeBool(
        ResponseParser.getValue(json, ['is_popular', 'popular', 'recommended']),
        fallback: false,
      ),
      currency: JsonHelper.safeString(
        ResponseParser.getValue(json, ['currency', 'currency_code']),
        fallback: 'VND',
      ).toUpperCase(),
      createdAt: JsonHelper.safeString(
        ResponseParser.getValue(json, ['created_at', 'createdAt']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'tokens': tokens,
    'bonus': bonus,
    'is_active': isActive,
    'is_popular': isPopular,
    'currency': currency,
    'created_at': createdAt,
  };
}
