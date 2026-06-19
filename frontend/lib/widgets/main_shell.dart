import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _mapBranchToNavIndex(navigationShell.currentIndex),
        onTap: (index) => _onTap(context, index),
      ),
    );
  }

  int _mapBranchToNavIndex(int branchIndex) {
    // branches: 0=today, 1=stats, 2=food, 3=me
    // nav items: 0=today, 1=stats, 2=scan, 3=food, 4=me
    switch (branchIndex) {
      case 0: return 0;
      case 1: return 1;
      case 2: return 3;
      case 3: return 4;
      default: return 0;
    }
  }

  void _onTap(BuildContext context, int navIndex) {
    switch (navIndex) {
      case 0:
        navigationShell.goBranch(0);
      case 1:
        navigationShell.goBranch(1);
      case 2:
        context.push('/scanner');
      case 3:
        navigationShell.goBranch(2);
      case 4:
        navigationShell.goBranch(3);
    }
  }
}
