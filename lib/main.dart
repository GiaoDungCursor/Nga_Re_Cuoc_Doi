import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_colors.dart';
import 'features/onboarding/screens/welcome_screen.dart';
import 'features/assessment/screens/quiz_screen.dart';
import 'features/career_dna/screens/career_dna_screen.dart';
import 'features/simulation/screens/simulation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Cấu hình định tuyến màn hình bằng GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (BuildContext context, GoRouterState state) {
        return const QuizScreen();
      },
    ),
    GoRoute(
      path: '/career-dna',
      builder: (BuildContext context, GoRouterState state) {
        return const CareerDnaScreen();
      },
    ),
    GoRoute(
      path: '/simulation',
      builder: (BuildContext context, GoRouterState state) {
        return const SimulationScreen();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ngã Rẽ Cuộc Đời',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.neonCyan,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonCyan,
          secondary: AppColors.neonViolet,
          background: AppColors.bgDark,
          surface: AppColors.bgCard,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      routerConfig: _router,
    );
  }
}
