import 'package:flutter/material.dart';

class MainTabController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index < 0 || index > 4) return;
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void goHome() => setIndex(0);
  void goScan() => setIndex(1);
  void goCurrency() => setIndex(2);
  void goHistory() => setIndex(3);
  void goProfile() => setIndex(4);
}
