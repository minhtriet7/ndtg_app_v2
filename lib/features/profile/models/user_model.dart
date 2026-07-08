import '../../../core/network/response_parser.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String avatarUrl;
  final String role;
  final String provider;
  final int tokenBalance;
  final int totalScans;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.provider,
    required this.tokenBalance,
    required this.totalScans,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin {
    final normalized = role.toLowerCase().trim();
    return normalized == 'admin';
  }

  String get initials {
    final cleanName = fullName.trim();

    if (cleanName.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : 'U';
    }

    final parts = cleanName
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toList();

    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserModel.fromJson(dynamic raw) {
    final root = ResponseParser.parseMap(raw);
    final json = ResponseParser.parseMap(
      root['data'] ?? root['user'] ?? root['profile'] ?? root,
    );

    return UserModel(
      id: ResponseParser.getValue(json, [
        'id',
        '_id',
        'user_id',
        'userId',
      ], defaultValue: '').toString(),
      email: ResponseParser.getValue(json, [
        'email',
        'user.email',
      ], defaultValue: '').toString(),
      fullName: ResponseParser.getValue(json, [
        'full_name',
        'fullName',
        'name',
        'display_name',
        'displayName',
        'username',
        'user.full_name',
        'user.name',
      ], defaultValue: 'BanknoteAI User').toString(),
      phone: ResponseParser.getValue(json, [
        'phone',
        'phone_number',
        'phoneNumber',
      ], defaultValue: '').toString(),
      avatarUrl: ResponseParser.getValue(json, [
        'avatar_url',
        'avatarUrl',
        'avatar',
        'photo_url',
        'picture',
        'user.avatar_url',
        'user.picture',
      ], defaultValue: '').toString(),
      role: ResponseParser.getValue(json, [
        'role',
        'user.role',
      ], defaultValue: 'user').toString(),
      provider: ResponseParser.getValue(json, [
        'provider',
        'auth_provider',
        'login_provider',
      ], defaultValue: 'email').toString(),
      tokenBalance: _asInt(
        ResponseParser.getValue(json, [
          'token_balance',
          'tokens',
          'balance',
          'tokenBalance',
          'user.token_balance',
        ], defaultValue: 0),
      ),
      totalScans: _asInt(
        ResponseParser.getValue(json, [
          'total_scans',
          'scan_count',
          'scans',
          'totalScans',
          'recognition_count',
          'user.total_scans',
        ], defaultValue: 0),
      ),
      createdAt: ResponseParser.getValue(json, [
        'created_at',
        'createdAt',
      ], defaultValue: '').toString(),
      updatedAt: ResponseParser.getValue(json, [
        'updated_at',
        'updatedAt',
      ], defaultValue: '').toString(),
    );
  }

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      email: '',
      fullName: 'BanknoteAI User',
      phone: '',
      avatarUrl: '',
      role: 'user',
      provider: 'email',
      tokenBalance: 0,
      totalScans: 0,
      createdAt: '',
      updatedAt: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'provider': provider,
      'token_balance': tokenBalance,
      'total_scans': totalScans,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? role,
    String? provider,
    int? tokenBalance,
    int? totalScans,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      totalScans: totalScans ?? this.totalScans,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();

    final text = value.toString().replaceAll(',', '').trim();
    return int.tryParse(text) ?? 0;
  }
}
