import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/main_tab_controller.dart';
import '../../home/screens/home_screen.dart';
import '../../recognition/screens/scan_screen.dart';
import '../../currency/screens/currency_converter_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainTabController(),
      child: const _MainLayoutView(),
    );
  }
}

class _MainLayoutView extends StatelessWidget {
  const _MainLayoutView();

  @override
  Widget build(BuildContext context) {
    final tabController = context.watch<MainTabController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final i18n = AppLocalizations.of(context);

    final List<Widget> screens = [
      const HomeScreen(),
      const ScanScreen(),
      const CurrencyConverterScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: tabController.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: tabController.currentIndex,
          onTap: tabController.setIndex,
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          selectedItemColor: AppColors.primaryTeal,
          unselectedItemColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: i18n.t('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.document_scanner_outlined),
              activeIcon: const Icon(Icons.document_scanner),
              label: i18n.t('scan'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.currency_exchange_outlined),
              activeIcon: const Icon(Icons.currency_exchange),
              label: i18n.t('currency'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              label: i18n.t('history'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: i18n.t('profile'),
            ),
          ],
        ),
      ),
    );
  }
}