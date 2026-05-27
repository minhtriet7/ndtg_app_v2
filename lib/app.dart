import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/language_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';

class BanknoteAIApp extends StatelessWidget {
  const BanknoteAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageController>();

    return MaterialApp(
      title: 'BanknoteAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: Locale(language.currentLocale),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RouteNames.splash,
    );
  }
}
