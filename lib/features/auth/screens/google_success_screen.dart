import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../routes/route_names.dart';
import '../controllers/auth_controller.dart';

class GoogleSuccessScreen extends StatefulWidget {
  final Object? arguments;

  const GoogleSuccessScreen({super.key, this.arguments});

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
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.main, (route) => false);
      return;
    }

    setState(() {
      _isChecking = false;
      _message = context.tr('googleSessionMissing');
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
              : AppColors.lightBrandGradient,
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
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          gradient: _isChecking ? AppColors.tealGradient : null,
                          color: _isChecking
                              ? null
                              : AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            if (_isChecking)
                              BoxShadow(
                                color: AppColors.primaryTeal.withOpacity(0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                          ],
                        ),
                        child: Icon(
                          _isChecking
                              ? Icons.sync_rounded
                              : Icons.info_outline_rounded,
                          color: _isChecking ? Colors.white : AppColors.warning,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isChecking
                            ? context.tr('googleCompletingSignIn')
                            : context.tr('googleSignInAction'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _message ?? context.tr('googleVerifySession'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 26),
                      if (_isChecking)
                        const CircularProgressIndicator(
                          color: AppColors.primaryTeal,
                        )
                      else
                        AppButton(
                          text: context.tr('backToSignIn'),
                          icon: Icons.login_rounded,
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteNames.login,
                              (route) => false,
                            );
                          },
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
