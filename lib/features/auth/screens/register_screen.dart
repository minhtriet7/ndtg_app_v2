import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
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
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.main, (route) => false);
      return;
    }

    final auth = context.read<AuthController>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(auth.error ?? 'accountCreateFailed')),
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
        message: context.tr('creatingAccount'),
        child: _AuthBackground(
          isDark: isDark,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton.filledTonal(
                          onPressed: auth.isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _AuthBrandHeader(
                        title: context.tr('createAccount'),
                        subtitle: context.tr('registerTagline'),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AppCard(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _GoogleButton(
                                text: context.tr('continueGoogle'),
                                isLoading: auth.isLoading,
                                onPressed: _handleGoogleRegister,
                              ),
                              const SizedBox(height: AppSizes.lg),
                              _AuthDivider(
                                text: context.tr('registerEmailDivider'),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              AppTextField(
                                label: context.tr('fullName'),
                                hint: context.tr('nameHint'),
                                controller: _nameController,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (value) =>
                                    (value?.trim().isEmpty ?? true)
                                    ? context.tr('nameRequired')
                                    : null,
                              ),
                              const SizedBox(height: AppSizes.md),
                              AppTextField(
                                label: context.tr('email'),
                                hint: context.tr('emailHint'),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return context.tr('emailRequired');
                                  }
                                  if (!RegExp(
                                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                  ).hasMatch(text)) {
                                    return context.tr('emailInvalid');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.md),
                              AppTextField(
                                label: context.tr('password'),
                                hint: context.tr('createPassword'),
                                controller: _passwordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.isEmpty) {
                                    return context.tr('passwordRequired');
                                  }
                                  if (text.length < 6) {
                                    return context.tr('passwordMinLength');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.md),
                              AppTextField(
                                label: context.tr('confirmPassword'),
                                hint: context.tr('confirmPasswordHint'),
                                controller: _confirmPasswordController,
                                isPassword: true,
                                prefixIcon: Icons.lock_reset_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.tr(
                                      'confirmPasswordRequired',
                                    );
                                  }
                                  if (value != _passwordController.text) {
                                    return context.tr('passwordMismatch');
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.xl),
                              AppButton(
                                text: context.tr('createAccount'),
                                icon: Icons.person_add_alt_1_rounded,
                                isLoading: auth.isLoading,
                                onPressed: auth.isLoading
                                    ? null
                                    : _handleRegister,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      _SwitchAuthRow(
                        text: context.tr('alreadyAccount'),
                        action: context.tr('signIn'),
                        onTap: auth.isLoading
                            ? null
                            : () {
                                auth.clearError();
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

class _AuthBackground extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _AuthBackground({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkGradient
            : AppColors.lightBrandGradient,
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

  const _AuthBrandHeader({required this.title, required this.subtitle});

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
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
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
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
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
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
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
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
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
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 34)],
      ),
    );
  }
}
