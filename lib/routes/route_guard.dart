import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../features/auth/controllers/auth_controller.dart';
import 'route_names.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool adminOnly;

  const RouteGuard({super.key, required this.child, this.adminOnly = false});

  bool _isAdmin(AuthController auth) {
    final role = (auth.currentUser?.role ?? '').toLowerCase().trim();
    return role == 'admin';
  }

  void _goToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.login, (route) => false);
    });
  }

  void _goToMain(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(RouteNames.main, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      _goToLogin(context);
      return const SizedBox.shrink();
    }

    if (adminOnly && !_isAdmin(auth)) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('accessDenied'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('adminPermissionRequired'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('adminPermissionDesc'),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _goToMain(context),
                  child: Text(context.tr('backToApp')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
