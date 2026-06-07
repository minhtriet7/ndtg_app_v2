class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String googleLogin = '/auth/google/login';

  // Current backend does NOT expose /auth/me.
  // Use /users/me for the authenticated profile.
  static const String userMe = '/users/me';
  static const String authMe = userMe;

  // Users
  static const String updateMe = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String userHistory = '/users/me/history';
  static const String userTransactions = '/users/me/transactions';

  // Recognition / scan
  static const String recognitionScan = '/recognition/scan';
  static const String recognitionStart = '/recognition/tasks';
  static const String recognitionHistory = userHistory;

  static String recognitionTaskStatus(String taskId) => '/recognition/tasks/$taskId';
  static String recognitionDetail(String id) => '/recognition/$id';

  // Compatibility aliases for older code
  static const String recognitionAnalyze = recognitionScan;
  static String recognitionTask(String taskId) => recognitionTaskStatus(taskId);

  // Currency
  static const String currencyRates = '/currency/rates';
  static const String currencyConvert = '/currency/convert';

  // Banknote directory
  static const String banknotes = '/banknotes/';
  static String banknoteDetail(String id) => '/banknotes/$id';

  // Token packages / payment
  static const String tokenPackages = '/payment/token-packages';
  static const String paymentCreate = '/payment/buy';
  static String paymentStatus(String paymentId) => '/payment/status/$paymentId';
  static const String myTransactions = '/payment/transactions';

  // Alternative user transaction route exposed by user_router.py
  static const String myUserTransactions = '/users/me/transactions';

  // Feedback
  static const String feedback = '/feedback';
  static const String myFeedback = '/feedback/my';

  // Admin lite
  static const String adminDashboardSummary = '/admin/dashboard/summary';
  static const String adminSystemHealth = '/admin/system/health';
  static const String adminPendingFeedback = '/admin/feedbacks/pending';
  static const String adminTransactions = '/admin/transactions';
}