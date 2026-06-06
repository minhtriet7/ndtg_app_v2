import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../routes/route_names.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthController>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    _handleAuthResult(success);
  }

  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthController>();
    final success = await auth.loginWithGoogle();
    _handleAuthResult(success);
  }

  void _handleAuthResult(bool success) {
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.main,
            (route) => false,
      );
      return;
    }

    final auth = context.read<AuthController>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.error ?? 'Login failed. Please try again.'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        message: 'Signing you in...',
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.darkGradient
                : const LinearGradient(
              colors: [Color(0xFFF8FBFF), Color(0xFFEFFDFB), Color(0xFFF8FBFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -110,
                right: -100,
                child: _AuthGlow(color: AppColors.primaryTeal.withOpacity(isDark ? 0.16 : 0.12)),
              ),
              Positioned(
                bottom: -130,
                left: -110,
                child: _AuthGlow(color: AppColors.info.withOpacity(isDark ? 0.10 : 0.08)),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, AppSizes.xxl),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BrandHeader(isDark: isDark),
                          const SizedBox(height: AppSizes.xl),
                          AppCard(
                            padding: const EdgeInsets.all(AppSizes.lg),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Welcome back',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Sign in to scan banknotes, review agent outputs, and manage tokens.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.lg),
                                  _GoogleSignInButton(
                                    isLoading: auth.isLoading,
                                    onPressed: _handleGoogleLogin,
                                  ),
                                  const SizedBox(height: AppSizes.lg),
                                  const _AuthDivider(),
                                  const SizedBox(height: AppSizes.lg),
                                  AppTextField(
                                    label: 'Email address',
                                    hint: 'you@example.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator: Validators.validateEmail,
                                  ),
                                  const SizedBox(height: AppSizes.md),
                                  AppTextField(
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    controller: _passwordController,
                                    isPassword: true,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    validator: Validators.validatePassword,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  AppButton(
                                    text: 'Sign in',
                                    icon: Icons.login_rounded,
                                    onPressed: _handleLogin,
                                    isLoading: auth.isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          _SwitchAuthRow(
                            text: 'New to BanknoteAI?',
                            action: 'Create account',
                            onTap: () {
                              auth.clearError();
                              Navigator.of(context).pushNamed(RouteNames.register);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isDark;

  const _BrandHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(isDark ? 0.18 : 0.26),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 42),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          'BanknoteAI',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'AI-powered Southeast Asian banknote recognition',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Continue with Google',
      type: AppButtonType.outline,
      icon: Icons.g_mobiledata_rounded,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'or continue with email',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SwitchAuthRow extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onTap;

  const _SwitchAuthRow({required this.text, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _AuthGlow extends StatelessWidget {
  final Color color;

  const _AuthGlow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 35)],
      ),
    );
  }
}
