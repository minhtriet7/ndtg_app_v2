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
      ['features', 'key_features'],
      defaultValue: const [],
    );

    final features = <String>[];
    if (featuresRaw is List) {
      features.addAll(featuresRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty));
    } else if (featuresRaw is String && featuresRaw.trim().isNotEmpty) {
      features.add(featuresRaw);
    }

    return BanknoteDirectoryModel(
      id: ResponseParser.getValue(json, ['id', '_id'], defaultValue: '').toString(),
      country: ResponseParser.getValue(json, ['country', 'origin'], defaultValue: 'Unknown').toString(),
      denomination: ResponseParser.getValue(json, ['denomination', 'value'], defaultValue: '').toString(),
      currencyCode: ResponseParser.getValue(json, ['currency_code', 'currency'], defaultValue: 'N/A').toString(),
      origin: ResponseParser.getValue(json, ['origin', 'country'], defaultValue: 'Unknown').toString(),
      description: ResponseParser.getValue(json, ['description'], defaultValue: '').toString(),
      features: features,
      material: ResponseParser.getValue(json, ['material'], defaultValue: 'Unknown').toString(),
      seriesYear: ResponseParser.getValue(json, ['series_year', 'year'], defaultValue: 'Unknown').toString(),
      frontImageUrl: ResponseParser.getValue(
        json,
        ['front_image_url', 'image_url', 'frontImageUrl'],
        defaultValue: '',
      ).toString(),
      backImageUrl: ResponseParser.getValue(
        json,
        ['back_image_url', 'backImageUrl'],
        defaultValue: '',
      ).toString(),
      isActive: ResponseParser.getValue(json, ['is_active', 'active'], defaultValue: true) != false,
      createdAt: ResponseParser.getValue(json, ['created_at', 'createdAt'], defaultValue: '').toString(),
      updatedAt: ResponseParser.getValue(json, ['updated_at', 'updatedAt'], defaultValue: '').toString(),
    );
  }

  String get displayName {
    final value = formattedDenomination;
    if (currencyCode == 'N/A' || currencyCode.isEmpty) return value;
    return '$value $currencyCode';
  }

  String get formattedDenomination {
    final number = double.tryParse(denomination.replaceAll(',', '').trim());

    if (number == null) {
      return denomination.isEmpty ? 'N/A' : denomination;
    }

    final intValue = number.round();
    final text = intValue.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  bool matches(String keyword) {
    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return true;

    final searchable = [
      country,
      denomination,
      currencyCode,
      origin,
      description,
      material,
      seriesYear,
      ...features,
    ].join(' ').toLowerCase();

    return searchable.contains(q);
  }
}