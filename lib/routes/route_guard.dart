import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../features/auth/controllers/auth_controller.dart';
import 'route_names.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;
  final bool adminOnly;

  const RouteGuard({
    super.key,
    required this.child,
    this.adminOnly = false,
  });

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.login,
                (route) => false,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(RouteNames.login);
        }
      });
      return const SizedBox.shrink();
    }

    if (adminOnly && !auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access denied')),
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
                  'Admin permission required',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account does not have permission to access this area.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.main,
                        (route) => false,
                  ),
                  child: const Text('Back to app'),
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
