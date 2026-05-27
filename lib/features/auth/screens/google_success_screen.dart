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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(
                    _isChecking ? Icons.sync_rounded : Icons.info_outline_rounded,
                    color: AppColors.primaryTeal,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isChecking ? 'Completing sign-in...' : 'Google sign-in requires action',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _message ?? 'Please wait while BanknoteAI verifies your session.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }
}
