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
      resizeToAvoidBottomInset: true,
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        message: 'Signing you in...',
        child: _AuthBackground(
          isDark: isDark,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AuthBrandHeader(
                        title: 'BanknoteAI',
                        subtitle:
                        'AI-powered Southeast Asian banknote recognition',
                      ),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign in to scan banknotes, review agent outputs, and manage tokens.',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              _GoogleButton(
                                text: 'Continue with Google',
                                isLoading: auth.isLoading,
                                onPressed: _handleGoogleLogin,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              const _AuthDivider(text: 'or continue with email'),
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
                              const SizedBox(height: AppSizes.xs),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                    auth.clearError();
                                    Navigator.of(context).pushNamed(
                                      RouteNames.forgotPassword,
                                    );
                                  },
                                  child: const Text('Forgot password?'),
                                ),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              AppButton(
                                text: 'Sign in',
                                icon: Icons.login_rounded,
                                isLoading: auth.isLoading,
                                onPressed: auth.isLoading ? null : _handleLogin,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      _SwitchAuthRow(
                        text: 'New to BanknoteAI?',
                        action: 'Create account',
                        onTap: auth.isLoading
                            ? null
                            : () {
                          auth.clearError();
                          Navigator.of(context).pushNamed(
                            RouteNames.register,
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

class _AuthBackground extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _AuthBackground({
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkGradient
            : const LinearGradient(
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFEFFFFB),
            Color(0xFFF8FBFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _AuthGlow(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.16 : 0.13),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: _AuthGlow(
              color: AppColors.info.withOpacity(isDark ? 0.12 : 0.09),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AuthBrandHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(isDark ? 0.18 : 0.26),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 27,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      type: AppButtonType.outline,
      icon: Icons.g_mobiledata_rounded,
      isLoading: isLoading,
      onPressed: isLoading ? null : onPressed,
    );
  }
}

class _AuthDivider extends StatelessWidget {
  final String text;

  const _AuthDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
  final VoidCallback? onTap;

  const _SwitchAuthRow({
    required this.text,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action),
        ),
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
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 90,
            spreadRadius: 34,
          ),
        ],
      ),
    );
  }
}