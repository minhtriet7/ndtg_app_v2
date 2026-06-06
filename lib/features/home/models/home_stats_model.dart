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
    final total = _asInt(
      ResponseParser.getValue(
        json,
        [
          'total_scans',
          'scan_count',
          'scans',
          'totalScans',
          'stats.total_scans',
          'stats.scan_count',
          'stats.scans',
        ],
        defaultValue: 0,
      ),
    );

    final completed = _asInt(
      ResponseParser.getValue(
        json,
        [
          'completed',
          'completed_scans',
          'success',
          'success_scans',
          'successful_scans',
          'completed_count',
          'success_count',
          'stats.completed',
          'stats.completed_scans',
          'stats.success',
          'stats.success_scans',
          'recognitions.completed',
        ],
        defaultValue: 0,
      ),
    );

    final failed = _asInt(
      ResponseParser.getValue(
        json,
        [
          'failed',
          'failed_scans',
          'error_scans',
          'needs_review',
          'review_scans',
          'stats.failed',
          'stats.failed_scans',
          'stats.needs_review',
          'recognitions.failed',
          'recognitions.needs_review',
        ],
        defaultValue: 0,
      ),
    );

    final rawSuccessRate = ResponseParser.getValue(
      json,
      [
        'success_rate',
        'successRate',
        'completed_rate',
        'stats.success_rate',
        'stats.successRate',
        'recognitions.success_rate',
      ],
      defaultValue: null,
    );

    final calculatedSuccessRate = total > 0 ? (completed / total) * 100 : 0.0;
    final successRate = rawSuccessRate == null
        ? calculatedSuccessRate
        : _normalizeRate(_asDouble(rawSuccessRate));

    return HomeStatsModel(
      fullName: ResponseParser.getValue(
        json,
        [
          'full_name',
          'fullName',
          'name',
          'display_name',
          'displayName',
          'user.full_name',
          'user.fullName',
          'user.name',
        ],
        defaultValue: 'User',
      ).toString(),
      email: ResponseParser.getValue(
        json,
        [
          'email',
          'user.email',
        ],
        defaultValue: '',
      ).toString(),
      role: ResponseParser.getValue(
        json,
        [
          'role',
          'user.role',
        ],
        defaultValue: 'user',
      ).toString(),
      tokenBalance: _asInt(
        ResponseParser.getValue(
          json,
          [
            'token_balance',
            'tokenBalance',
            'tokens',
            'balance',
            'user.token_balance',
            'user.tokenBalance',
            'user.tokens',
          ],
          defaultValue: 0,
        ),
      ),
      totalScans: total,
      completedScans: completed,
      failedScans: failed,
      usedTokens: _asInt(
        ResponseParser.getValue(
          json,
          [
            'used_tokens',
            'tokens_used',
            'system_tokens_charged',
            'stats.used_tokens',
            'stats.tokens_used',
          ],
          defaultValue: total,
        ),
      ),
      successRate: successRate,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();

    final text = value.toString().trim();
    if (text.isEmpty) return 0;

    return int.tryParse(text) ?? double.tryParse(text)?.round() ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    final text = value.toString().trim().replaceAll('%', '');
    if (text.isEmpty) return 0;

    return double.tryParse(text) ?? 0;
  }

  static double _normalizeRate(double value) {
    if (value <= 1 && value > 0) return value * 100;
    return value;
  }
}