import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/stats/my_stats_screen.dart';
import '../screens/cards/my_cards_screen.dart';
import '../screens/rules/rules_viewer_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/stats', builder: (context, state) => const MyStatsScreen()),
      GoRoute(path: '/cards', builder: (context, state) => const MyCardsScreen()),
      GoRoute(path: '/rules', builder: (context, state) => const RulesViewerScreen()),
    ],
  );
});
