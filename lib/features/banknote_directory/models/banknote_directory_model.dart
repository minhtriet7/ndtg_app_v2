import '../../../core/network/response_parser.dart';

class BanknoteDirectoryModel {
  final String id;
  final String country;
  final String denomination;
  final String currencyCode;
  final String origin;
  final String description;
  final List<String> features;
  final String material;
  final String seriesYear;
  final String frontImageUrl;
  final String backImageUrl;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const BanknoteDirectoryModel({
    required this.id,
    required this.country,
    required this.denomination,
    required this.currencyCode,
    required this.origin,
    required this.description,
    required this.features,
    required this.material,
    required this.seriesYear,
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BanknoteDirectoryModel.fromJson(Map<String, dynamic> json) {
    final featuresRaw = ResponseParser.getValue(
      json,
      ['features', 'key_features', 'security_features'],
      defaultValue: const [],
    );

    final features = <String>[];
    if (featuresRaw is List) {
      features.addAll(
        featuresRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty),
      );
    } else if (featuresRaw is String && featuresRaw.trim().isNotEmpty) {
      features.add(featuresRaw);
    }

    final denomination = ResponseParser.getValue(
      json,
      ['denomination', 'value', 'menh_gia'],
      defaultValue: '',
    ).toString();

    final currencyCode = ResponseParser.getValue(
      json,
      ['currency_code', 'currency', 'loai_tien'],
      defaultValue: '',
    ).toString().toUpperCase();

    return BanknoteDirectoryModel(
      id: ResponseParser.getValue(json, ['id', '_id'], defaultValue: '').toString(),
      country: ResponseParser.getValue(json, ['country', 'origin', 'quoc_gia'], defaultValue: 'Unknown').toString(),
      denomination: denomination,
      currencyCode: currencyCode.isEmpty ? _currencyFromText(denomination) : currencyCode,
      origin: ResponseParser.getValue(json, ['origin', 'country', 'xuat_xu'], defaultValue: 'Unknown').toString(),
      description: ResponseParser.getValue(json, ['description', 'mo_ta'], defaultValue: '').toString(),
      features: features,
      material: ResponseParser.getValue(json, ['material', 'chat_lieu'], defaultValue: 'Unknown').toString(),
      seriesYear: ResponseParser.getValue(json, ['series_year', 'year', 'nam_phat_hanh'], defaultValue: 'Unknown').toString(),
      frontImageUrl: ResponseParser.getValue(
        json,
        ['front_image_url', 'image_url', 'frontImageUrl', 'front_image'],
        defaultValue: '',
      ).toString(),
      backImageUrl: ResponseParser.getValue(
        json,
        ['back_image_url', 'backImageUrl', 'back_image'],
        defaultValue: '',
      ).toString(),
      isActive: ResponseParser.getValue(json, ['is_active', 'active'], defaultValue: true) != false,
      createdAt: ResponseParser.getValue(json, ['created_at', 'createdAt'], defaultValue: '').toString(),
      updatedAt: ResponseParser.getValue(json, ['updated_at', 'updatedAt'], defaultValue: '').toString(),
    );
  }

  double get numericDenomination {
    final match = RegExp(r'[\d,.]+').firstMatch(denomination);
    if (match == null) return 0;

    final raw = match.group(0) ?? '';
    return double.tryParse(raw.replaceAll(',', '')) ?? 0;
  }

  String get displayName {
    final value = formattedDenomination;
    if (currencyCode.isEmpty || currencyCode == 'N/A' || currencyCode == 'UNKNOWN') {
      return value;
    }

    if (value.toUpperCase().contains(currencyCode.toUpperCase())) {
      return value;
    }

    return '$value $currencyCode';
  }

  String get formattedDenomination {
    final number = numericDenomination;

    if (number <= 0) {
      return denomination.isEmpty ? 'N/A' : denomination;
    }

    final intValue = number.round();
    final text = intValue.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final remaining = text.length - i;
      buffer.write(text[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  bool get hasFrontImage => frontImageUrl.trim().isNotEmpty;
  bool get hasBackImage => backImageUrl.trim().isNotEmpty;
  bool get hasAnyImage => hasFrontImage || hasBackImage;

  bool matches(String keyword) {
    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return true;

    final searchable = [
      country,
      denomination,
      formattedDenomination,
      currencyCode,
      origin,
      description,
      material,
      seriesYear,
      ...features,
    ].join(' ').toLowerCase();

    return searchable.contains(q);
  }

  static String _currencyFromText(String value) {
    final text = value.toUpperCase();

    const codes = [
      'VND',
      'THB',
      'IDR',
      'MYR',
      'SGD',
      'PHP',
      'KHR',
      'LAK',
      'MMK',
      'BND',
      'USD',
    ];

    for (final code in codes) {
      if (RegExp('\\b$code\\b').hasMatch(text)) return code;
    }

    return 'N/A';
  }
}