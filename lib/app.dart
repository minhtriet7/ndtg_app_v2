import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import thư viện dịch hệ thống

import 'core/localization/language_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';

class BanknoteAIApp extends StatelessWidget {
  const BanknoteAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageController>();
    final theme = context.watch<ThemeController>();

    return MaterialApp(
      title: 'BanknoteAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: theme.themeMode,
      locale: Locale(language.currentLocale),

      // BẮT BUỘC PHẢI CÓ 2 THUỘC TÍNH NÀY ĐỂ APP KHÔNG LỖI HIỂN THỊ
      supportedLocales: const [
        Locale('vi', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RouteNames.splash,
    );
  }
}