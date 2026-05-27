import 'package:flutter/material.dart';

import '../admin_lite/screens/admin_dashboard_screen.dart';
import '../admin_lite/screens/admin_pending_feedback_screen.dart';
import '../admin_lite/screens/admin_pending_transactions_screen.dart';
import '../admin_lite/screens/admin_system_health_screen.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/google_success_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/feedback/screens/feedback_form_screen.dart';
import '../features/feedback/screens/feedback_screen.dart';
import '../features/main/screens/main_layout_screen.dart';
import '../features/payment/screens/checkout_screen.dart';
import '../features/payment/screens/pricing_screen.dart';
import '../features/payment/screens/sepay_checkout_screen.dart';
import '../features/payment/screens/transactions_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import 'route_guard.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case RouteNames.splash:
        page = const SplashScreen();
        break;
      case RouteNames.login:
        page = const LoginScreen();
        break;
      case RouteNames.register:
        page = const RegisterScreen();
        break;
      case RouteNames.forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case RouteNames.googleSuccess:
        page = GoogleSuccessScreen(arguments: settings.arguments);
        break;
      case RouteNames.main:
        page = const RouteGuard(child: MainLayoutScreen());
        break;
      case RouteNames.pricing:
        page = const RouteGuard(child: PricingScreen());
        break;
      case RouteNames.checkout:
        page = const RouteGuard(child: CheckoutScreen());
        break;
      case RouteNames.sepayCheckout:
        page = const RouteGuard(child: SepayCheckoutScreen());
        break;
      case RouteNames.transactions:
        page = const RouteGuard(child: TransactionsScreen());
        break;
      case RouteNames.feedback:
        page = const RouteGuard(child: FeedbackScreen());
        break;
      case RouteNames.feedbackForm:
        page = const RouteGuard(child: FeedbackFormScreen());
        break;
      case RouteNames.adminDashboard:
        page = const RouteGuard(adminOnly: true, child: AdminDashboardScreen());
        break;
      case RouteNames.adminPendingTransactions:
        page = const RouteGuard(adminOnly: true, child: AdminPendingTransactionsScreen());
        break;
      case RouteNames.adminPendingFeedback:
        page = const RouteGuard(adminOnly: true, child: AdminPendingFeedbackScreen());
        break;
      case RouteNames.adminSystemHealth:
        page = const RouteGuard(adminOnly: true, child: AdminSystemHealthScreen());
        break;
      default:
        page = _NotFoundRoute(routeName: settings.name ?? 'unknown');
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }
}

class _NotFoundRoute extends StatelessWidget {
  final String routeName;

  const _NotFoundRoute({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.route_outlined,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                'No route defined',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                routeName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.splash,
                      (route) => false,
                ),
                child: const Text('Return to app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
