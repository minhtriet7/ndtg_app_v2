import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary indigo and violet tones shared with the web interface.
  static const Color primaryTeal = Color(0xFF6366F1); // Indigo
  static const Color primaryLightTeal = Color(0xFF818CF8); // Light Indigo
  static const Color primaryDarkTeal = Color(0xFF4338CA); // Dark Indigo
  static const Color primaryHover = Color(0xFF4F46E5);
  static const Color secondaryBlue = Color(0xFF8B5CF6); // Premium Violet
  static const Color secondaryLightBlue = Color(0xFFA78BFA); // Light Violet
  static const Color agentPurple = Color(0xFFC084FC); // Purple

  // Minimalist light palette (Slate/Zinc)
  static const Color bgLight = Color(0xFFF9F9FB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceSubtleLight = Color(0xFFF4F4F5);
  static const Color sectionTintLight = Color(0xFFF0F4FF);
  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color textPrimaryLight = Color(0xFF09090B);
  static const Color textBodyLight = Color(0xFF4F4F56);
  static const Color textSecondaryLight = Color(0xFF71717A);
  static const Color textMutedLight = Color(0xFFA1A1AA);

  // Premium graphite dark palette (Obsidian/Zinc)
  static const Color bgDark = Color(0xFF09090B);
  static const Color cardDark = Color(0xFF18181B);
  static const Color surfaceSubtleDark = Color(0xFF141416);
  static const Color sectionDeepDark = Color(0xFF0C0C0E);
  static const Color borderDark = Color(0xFF27272A);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFD4D4D8);
  static const Color textMutedDark = Color(0xFF71717A);

  // Status indicators (Jade/Amber/Rose)
  static const Color success = Color(0xFF10B981); // Jade/Green (Consensus)
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color codeBg = Color(0xFF09090B);
  static const Color codeText = Color(
    0xFF34D399,
  ); // Crisp jade for code outputs

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

  // Brand gradients for focused headers and primary actions.
  static const LinearGradient tealGradient = LinearGradient(
    colors: [primaryTeal, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [sectionDeepDark, cardDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBrandGradient = LinearGradient(
    colors: [sectionTintLight, Color(0xFFF5F3FF), bgLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;
  static Color pageBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? borderDark
      : borderLight;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? textPrimaryDark
      : textPrimaryLight;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? textSecondaryDark
      : textSecondaryLight;
  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? textMutedDark
      : textMutedLight;
  static Color surfaceSubtle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? surfaceSubtleDark
      : surfaceSubtleLight;
  static Color primaryFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? primaryLightTeal
      : primaryTeal;
}
