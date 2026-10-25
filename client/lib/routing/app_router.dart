import 'package:go_router/go_router.dart';
import '../features/today/presentation/today_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodayScreen(),
    ),
  ],
);
