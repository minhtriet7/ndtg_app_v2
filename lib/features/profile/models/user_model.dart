import '../../../core/network/response_parser.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
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
    return normalized == 'admin' || normalized == 'superadmin';
  }

  String get initials {
    final cleanName = fullName.trim();
    if (cleanName.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : 'U';
    }

    final parts = cleanName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: ResponseParser.getValue(json, ['id', '_id', 'user_id'], defaultValue: '').toString(),
      email: ResponseParser.getValue(json, ['email'], defaultValue: '').toString(),
      fullName: ResponseParser.getValue(
        json,
        ['full_name', 'fullName', 'name', 'display_name', 'displayName', 'username'],
        defaultValue: 'BanknoteAI User',
      ).toString(),
      avatarUrl: ResponseParser.getValue(
        json,
        ['avatar_url', 'avatarUrl', 'avatar', 'photo_url', 'picture'],
        defaultValue: '',
      ).toString(),
      role: ResponseParser.getValue(json, ['role'], defaultValue: 'user').toString(),
      provider: ResponseParser.getValue(json, ['provider', 'auth_provider'], defaultValue: 'email').toString(),
      tokenBalance: int.tryParse(
        ResponseParser.getValue(
          json,
          ['token_balance', 'tokens', 'balance', 'tokenBalance'],
          defaultValue: 0,
        ).toString(),
      ) ??
          0,
      totalScans: int.tryParse(
        ResponseParser.getValue(
          json,
          ['total_scans', 'scan_count', 'scans', 'totalScans'],
          defaultValue: 0,
        ).toString(),
      ) ??
          0,
      createdAt: ResponseParser.getValue(json, ['created_at', 'createdAt'], defaultValue: '').toString(),
      updatedAt: ResponseParser.getValue(json, ['updated_at', 'updatedAt'], defaultValue: '').toString(),
    );
  }

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      email: '',
      fullName: 'BanknoteAI User',
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      totalScans: totalScans ?? this.totalScans,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
