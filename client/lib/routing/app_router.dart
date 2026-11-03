import 'package:go_router/go_router.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/today/presentation/today_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodayScreen(),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => ExploreScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
    GoRoute(
      path: '/research',
      builder: (context, state) => ExploreScreen(
        initialQuery: state.uri.queryParameters['q'],
      ),
    ),
  ],
);
