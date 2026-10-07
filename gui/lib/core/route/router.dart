import 'package:flyx/core/route/route_config.dart';
import 'package:flyx/features/onboarding/presentation/onboarding_screen.dart';
import 'package:go_router/go_router.dart';



GoRouter buildRouter({required bool onboarded}) => GoRouter(
  initialLocation: onboarded ? AppRoute.home.path : AppRoute.onboarding.path,
  routes: [
    GoRoute(
      path: AppRoute.onboarding.path,
      builder: (_, _) => const OnboardingScreen(),
    ),
  ],
);
