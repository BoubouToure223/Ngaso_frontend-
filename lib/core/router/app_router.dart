
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/screens/connexion_page.dart';
import 'package:myapp/features/auth/screens/forgot_password_page.dart';
import 'package:myapp/features/auth/screens/novice_signup_page.dart';
import 'package:myapp/features/auth/screens/profile_choice_page.dart';
import 'package:myapp/features/auth/screens/pro_signup_page.dart';
import 'package:myapp/features/onboarding/screens/onboarding_page.dart';
import 'package:myapp/features/splash/screens/splash_page.dart';

/// La configuration du routeur de l'application.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    // La route initiale de l'application.
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
    ),
    // La route pour la page d'onboarding.
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingPage();
      },
    ),
    // La route pour la page de connexion.
    GoRoute(
      path: '/connexion',
      builder: (BuildContext context, GoRouterState state) {
        return const ConnexionPage();
      },
    ),
    // La route pour la page de mot de passe oublié.
    GoRoute(
      path: '/forgot-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordPage();
      },
    ),
    // La route pour la page de choix du profil.
    GoRoute(
      path: '/profile-choice',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileChoicePage();
      },
    ),
    // La route pour la page d'inscription des professionnels.
    GoRoute(
      path: '/pro-signup',
      builder: (BuildContext context, GoRouterState state) {
        return const ProSignupPage();
      },
    ),
    // La route pour la page d'inscription des novices.
    GoRoute(
      path: '/novice-signup',
      builder: (BuildContext context, GoRouterState state) {
        return const NoviceSignupPage();
      },
    ),
  ],
);
