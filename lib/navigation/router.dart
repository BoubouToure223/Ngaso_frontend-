
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/connexion_page.dart';
import 'package:myapp/features/auth/forgot_password_page.dart';
import 'package:myapp/features/auth/novice_signup_page.dart';
import 'package:myapp/features/auth/profile_choice_page.dart';
import 'package:myapp/features/auth/pro_signup_page.dart';
import 'package:myapp/features/onboarding/onboarding_page.dart';
import 'package:myapp/features/splash_page.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'onboarding',
          builder: (BuildContext context, GoRouterState state) {
            return const OnboardingPage();
          },
        ),
        GoRoute(
          path: 'connexion',
          builder: (BuildContext context, GoRouterState state) {
            return const ConnexionPage();
          },
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordPage();
          },
        ),
        GoRoute(
          path: 'profile-choice',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileChoicePage();
          },
        ),
        GoRoute(  
          path: 'pro-signup',
          builder: (BuildContext context, GoRouterState state) {
            return const ProSignupPage();
          },
        ),
        GoRoute(
          path: 'novice-signup',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceSignupPage();
          },
        ),
      ],
    ),
  ],
);
