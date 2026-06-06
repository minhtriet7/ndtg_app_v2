import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryTeal = Color(0xFF00BFA6);
  static const Color primaryLightTeal = Color(0xFF2DD4BF);
  static const Color primaryDarkTeal = Color(0xFF0F766E);
  static const Color secondaryBlue = Color(0xFF0EA5E9);
  static const Color secondaryLightBlue = Color(0xFF38BDF8);
  static const Color agentPurple = Color(0xFF8B5CF6);

  static const Color bgLight = Color(0xFFF8FBFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color bgDark = Color(0xFF07111F);
  static const Color cardDark = Color(0xFF0F172A);
  static const Color borderDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF94A3B8);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = secondaryBlue;
  static const Color violet = agentPurple;
  static const Color codeBg = Color(0xFF020617);
  static const Color codeText = Color(0xFFD1FAE5);

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  static const LinearGradient tealGradient = LinearGradient(
    colors: [primaryTeal, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [cardDark, codeBg],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;
  static Color pageBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textMutedDark : textMutedLight;
}
