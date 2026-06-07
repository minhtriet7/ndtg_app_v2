import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/localization/language_controller.dart';
import 'core/network/dio_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/theme_controller.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/banknote_directory/controllers/banknote_directory_controller.dart';
import 'features/currency/controllers/currency_controller.dart';
import 'features/feedback/controllers/feedback_controller.dart';
import 'features/history/controllers/history_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/payment/controllers/payment_controller.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'features/recognition/controllers/recognition_controller.dart';

import 'admin_lite/controllers/admin_lite_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.instance.initialize();
  DioClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),

        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RecognitionController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => HistoryController()),
        ChangeNotifierProvider(create: (_) => CurrencyController()),
        ChangeNotifierProvider(create: (_) => PaymentController()),
        ChangeNotifierProvider(create: (_) => FeedbackController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),

        ChangeNotifierProvider(create: (_) => BanknoteDirectoryController()),

        ChangeNotifierProvider(create: (_) => AdminLiteController()),
      ],
      child: const BanknoteAIApp(),
    ),
  );
}