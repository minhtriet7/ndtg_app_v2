class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String authMe = '/auth/me';
  static const String userMe = '/users/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String googleLogin = '/auth/google/login';

  // Recognition / scan
  static const String recognitionAnalyze = '/recognition/analyze';
  static const String recognitionStart = '/recognition/start';
  static const String recognitionHistory = '/recognition/history';

  static String recognitionTaskStatus(String taskId) => '/recognition/task/$taskId';
  static String recognitionDetail(String id) => '/recognition/$id';

  // Currency
  static const String currencyRates = '/currency/rates';
  static const String currencyConvert = '/currency/convert';

  // Token packages / payment
  static const String tokenPackages = '/token-packages';
  static const String paymentCreate = '/payment/create';
  static String paymentStatus(String paymentId) => '/payment/status/$paymentId';
  static const String myTransactions = '/transactions/my';

  // Feedback
  static const String feedback = '/feedback';
  static const String myFeedback = '/feedback/my';

  // Admin lite
  static const String adminDashboardSummary = '/admin/dashboard/summary';
  static const String adminSystemHealth = '/admin/system/health';
  static const String adminPendingFeedback = '/admin/feedbacks/pending';
  static const String adminTransactions = '/admin/transactions';
}
