import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../routes/route_names.dart';
import '../controllers/auth_controller.dart';

class GoogleSuccessScreen extends StatefulWidget {
  final Object? arguments;

  const GoogleSuccessScreen({
    super.key,
    this.arguments,
  });

  @override
  State<GoogleSuccessScreen> createState() => _GoogleSuccessScreenState();
}

class _GoogleSuccessScreenState extends State<GoogleSuccessScreen> {
  bool _isChecking = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _completeGoogleFlow());
  }

  Future<void> _completeGoogleFlow() async {
    final auth = context.read<AuthController>();
    await auth.checkAuthStatus();

    if (!mounted) return;
    if (auth.isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.main, (route) => false);
      return;
    }

    setState(() {
      _isChecking = false;
      _message = 'Google sign-in did not return an active session. Please sign in again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkGradient
              : const LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFEFFDFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          gradient: _isChecking ? AppColors.tealGradient : null,
                          color: _isChecking ? null : AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          _isChecking ? Icons.sync_rounded : Icons.info_outline_rounded,
                          color: _isChecking ? Colors.white : AppColors.warning,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        _isChecking ? 'Completing sign-in' : 'Google sign-in requires action',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _message ?? 'Please wait while BanknoteAI verifies your secure session.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isChecking)
                        const CircularProgressIndicator(color: AppColors.primaryTeal)
                      else
                        AppButton(
                          text: 'Back to sign in',
                          isFullWidth: false,
                          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                            RouteNames.login,
                                (route) => false,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
