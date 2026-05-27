import '../../../core/network/response_parser.dart';

class HomeStatsModel {
  final String fullName;
  final String email;
  final String role;
  final int tokenBalance;
  final int totalScans;
  final int completedScans;
  final int failedScans;
  final int usedTokens;
  final double successRate;

  const HomeStatsModel({
    required this.fullName,
    required this.email,
    required this.role,
    required this.tokenBalance,
    required this.totalScans,
    required this.completedScans,
    required this.failedScans,
    required this.usedTokens,
    required this.successRate,
  });

  factory HomeStatsModel.empty() {
    return const HomeStatsModel(
      fullName: 'User',
      email: '',
      role: 'user',
      tokenBalance: 0,
      totalScans: 0,
      completedScans: 0,
      failedScans: 0,
      usedTokens: 0,
      successRate: 0,
    );
  }

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) {
    final total = _asInt(ResponseParser.getValue(
      json,
      ['total_scans', 'scan_count', 'scans', 'stats.total_scans'],
      defaultValue: 0,
    ));

    final completed = _asInt(ResponseParser.getValue(
      json,
      ['completed_scans', 'stats.completed_scans'],
      defaultValue: 0,
    ));

    final failed = _asInt(ResponseParser.getValue(
      json,
      ['failed_scans', 'stats.failed_scans'],
      defaultValue: 0,
    ));

    return HomeStatsModel(
      fullName: ResponseParser.getValue(
        json,
        ['full_name', 'name', 'display_name', 'user.full_name', 'user.name'],
        defaultValue: 'User',
      ).toString(),
      email: ResponseParser.getValue(
        json,
        ['email', 'user.email'],
        defaultValue: '',
      ).toString(),
      role: ResponseParser.getValue(
        json,
        ['role', 'user.role'],
        defaultValue: 'user',
      ).toString(),
      tokenBalance: _asInt(ResponseParser.getValue(
        json,
        ['token_balance', 'tokens', 'user.token_balance', 'user.tokens'],
        defaultValue: 0,
      )),
      totalScans: total,
      completedScans: completed,
      failedScans: failed,
      usedTokens: _asInt(ResponseParser.getValue(
        json,
        ['used_tokens', 'tokens_used', 'stats.used_tokens'],
        defaultValue: 0,
      )),
      successRate: _asDouble(ResponseParser.getValue(
        json,
        ['success_rate', 'stats.success_rate'],
        defaultValue: total > 0 ? (completed / total) * 100 : 0,
      )),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
