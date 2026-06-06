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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthController>();
    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    _handleAuthResult(success);
  }

  Future<void> _handleGoogleRegister() async {
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
        content: Text(auth.error ?? 'Unable to create account.'),
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
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: Colors.transparent,
      ),
      body: LoadingOverlay(
        isLoading: auth.isLoading,
        message: 'Creating your account.',
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
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, AppSizes.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RegisterHero(isDark: isDark),
                      const SizedBox(height: AppSizes.lg),
                      AppCard(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _GoogleSignInButton(
                                isLoading: auth.isLoading,
                                onPressed: _handleGoogleRegister,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              const _AuthDivider(),
                              const SizedBox(height: AppSizes.lg),
                              AppTextField(
                                label: 'Full name',
                                hint: 'Your name',
                                controller: _nameController,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (value) => Validators.validateRequired(value, fieldName: 'Full name'),
                              ),
                              const SizedBox(height: AppSizes.md),
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
                                hint: 'Create a password',
                                controller: _passwordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: Validators.validatePassword,
                              ),
                              const SizedBox(height: AppSizes.md),
                              AppTextField(
                                label: 'Confirm password',
                                hint: 'Re-enter your password',
                                controller: _confirmPasswordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_reset_outlined,
                                validator: (value) {
                                  final required = Validators.validateRequired(value, fieldName: 'Confirm password');
                                  if (required != null) return required;
                                  if (value != _passwordController.text) return 'Passwords do not match.';
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.xl),
                              AppButton(
                                text: 'Create account',
                                icon: Icons.person_add_alt_1_rounded,
                                onPressed: _handleRegister,
                                isLoading: auth.isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteNames.login,
                                  (route) => route.settings.name == RouteNames.splash,
                            ),
                            child: const Text('Sign in'),
                          ),
                        ],
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

class _RegisterHero extends StatelessWidget {
  final bool isDark;

  const _RegisterHero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      hasBorder: false,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.10 : 0.22),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 38),
            SizedBox(height: AppSizes.md),
            Text(
              'Start scanning smarter',
              style: TextStyle(color: Colors.white, fontSize: 26, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -0.7),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Create your BanknoteAI account to use the multi-agent recognition pipeline.',
              style: TextStyle(color: Colors.white70, height: 1.45, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
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
            'or register with email',
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
