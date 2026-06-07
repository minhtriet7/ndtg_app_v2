import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../banknote_directory/screens/supported_banknotes_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../recognition/screens/scan_screen.dart';
import '../controllers/main_tab_controller.dart';

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

    final screens = <Widget>[
      const HomeScreen(),
      const ScanScreen(),
      const SupportedBanknotesScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: tabController.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardDark.withOpacity(0.94)
                : Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.35)
                    : AppColors.slate900.withOpacity(0.10),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: tabController.currentIndex,
              onTap: tabController.setIndex,
              backgroundColor: Colors.transparent,
              selectedItemColor:
              isDark ? AppColors.primaryLightTeal : AppColors.primaryTeal,
              unselectedItemColor:
              isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.space_dashboard_outlined),
                  activeIcon: Icon(Icons.space_dashboard_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: _ScanNavIcon(active: false),
                  activeIcon: _ScanNavIcon(active: true),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.public_outlined),
                  activeIcon: Icon(Icons.public_rounded),
                  label: 'Directory',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanNavIcon extends StatelessWidget {
  final bool active;

  const _ScanNavIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: active ? AppColors.tealGradient : null,
        color: active ? null : AppColors.primaryTeal.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.document_scanner_rounded,
        size: 19,
        color: active ? Colors.white : AppColors.primaryTeal,
      ),
    );
  }
}