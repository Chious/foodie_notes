import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_shell.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/goal_setup/goal_setup_screen.dart';
import '../screens/daily_overview/daily_overview_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/food_search/food_search_screen.dart';
import '../screens/body_data/body_data_screen.dart';
import '../screens/scanner/scanner_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/goal-setup',
      builder: (context, state) => const GoalSetupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const DailyOverviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/food',
              builder: (context, state) => const FoodSearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/me',
              builder: (context, state) => const BodyDataScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/scanner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScannerScreen(),
    ),
  ],
);
