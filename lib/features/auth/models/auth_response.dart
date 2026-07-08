import '../../../core/network/response_parser.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserInfo user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);
    final data = ResponseParser.parseMap(json['data'] ?? json);

    final token = ResponseParser.getValue(data, [
      'access_token',
      'token',
      'jwt',
      'data.access_token',
      'data.token',
    ], defaultValue: '').toString();

    final userRaw = ResponseParser.getValue(data, [
      'user',
      'profile',
      'account',
      'data.user',
    ], defaultValue: data);

    return AuthResponse(
      accessToken: token,
      refreshToken: ResponseParser.getValue(data, [
        'refresh_token',
        'refreshToken',
        'data.refresh_token',
      ], defaultValue: '').toString(),
      tokenType: ResponseParser.getValue(data, [
        'token_type',
        'type',
      ], defaultValue: 'Bearer').toString(),
      user: UserInfo.fromJson(userRaw),
    );
  }

  bool get hasToken => accessToken.trim().isNotEmpty;
}

class UserInfo {
  final String id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final int tokenBalance;
  final String role;
  final bool isActive;
  final String provider;

  const UserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.tokenBalance,
    required this.role,
    required this.isActive,
    required this.provider,
  });

  factory UserInfo.empty() {
    return const UserInfo(
      id: '',
      email: '',
      fullName: 'User',
      avatarUrl: '',
      tokenBalance: 0,
      role: 'user',
      isActive: true,
      provider: 'local',
    );
  }

  factory UserInfo.fromJson(dynamic raw) {
    final json = ResponseParser.parseMap(raw);

    int parseTokens(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      return int.tryParse(value.toString()) ?? 0;
    }

    final tokenValue = ResponseParser.getValue(json, [
      'token_balance',
      'tokens',
      'balance',
      'credit',
      'tokenBalance',
    ], defaultValue: 0);

    return UserInfo(
      id: ResponseParser.getValue(json, [
        'id',
        '_id',
        'user_id',
      ], defaultValue: '').toString(),
      email: ResponseParser.getValue(json, [
        'email',
      ], defaultValue: '').toString(),
      fullName: ResponseParser.getValue(json, [
        'full_name',
        'name',
        'display_name',
        'username',
      ], defaultValue: 'User').toString(),
      avatarUrl: ResponseParser.getValue(json, [
        'avatar_url',
        'avatar',
        'picture',
        'photo_url',
      ], defaultValue: '').toString(),
      tokenBalance: parseTokens(tokenValue),
      role: ResponseParser.getValue(json, [
        'role',
      ], defaultValue: 'user').toString(),
      isActive:
          ResponseParser.getValue(json, [
            'is_active',
            'active',
          ], defaultValue: true) !=
          false,
      provider: ResponseParser.getValue(json, [
        'provider',
        'auth_provider',
      ], defaultValue: 'local').toString(),
    );
  }

  bool get isAdmin {
    final normalized = role.toLowerCase().trim();
    return normalized == 'admin';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'token_balance': tokenBalance,
      'role': role,
      'is_active': isActive,
      'provider': provider,
    };
  }

  UserInfo copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    int? tokenBalance,
    String? role,
    bool? isActive,
    String? provider,
  }) {
    return UserInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      provider: provider ?? this.provider,
    );
  }
}
