
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/screens/connexion_page.dart';
import 'package:myapp/features/auth/screens/forgot_password_page.dart';
import 'package:myapp/features/auth/screens/novice_signup_page.dart';
import 'package:myapp/features/auth/screens/profile_choice_page.dart';
import 'package:myapp/features/auth/screens/pro_signup_page.dart';
import 'package:myapp/features/onboarding/screens/onboarding_page.dart';
import 'package:myapp/features/splash/screens/splash_page.dart';
import 'package:myapp/shared/shell/app_shell.dart';
import 'package:myapp/features/pro/screens/home_page.dart';
import 'package:myapp/features/pro/screens/messages_page.dart';
import 'package:myapp/features/pro/screens/projects_page.dart';
import 'package:myapp/features/pro/screens/profile_page.dart';
import 'package:myapp/features/pro/screens/notifications_page.dart';
import 'package:myapp/features/pro/screens/proposal_details_page.dart';
import 'package:myapp/features/pro/screens/chat_page.dart';
import 'package:myapp/features/pro/screens/proposal_create_page.dart';
import 'package:myapp/features/novice/screens/home_page.dart';
import 'package:myapp/features/novice/screens/messages_page.dart';
import 'package:myapp/features/novice/screens/projects_page.dart';
import 'package:myapp/features/novice/screens/profile_page.dart';

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
    // Espace Professionnels avec barre de navigation persistante (AppShell paramétré).
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        const noviceTabs = [
          NavTab('/app/home', 'Accueil', Icons.home_outlined),
          NavTab('/app/messages', 'Messages', Icons.chat_bubble_outline),
          NavTab('/app/projet', 'Projet', Icons.topic_outlined),
          NavTab('/app/profil', 'Profile', Icons.person_outline),
        ];
        return AppShell(tabs: noviceTabs, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/app/home',
          builder: (BuildContext context, GoRouterState state) {
            return const ProHomePage();
          },
        ),
        GoRoute(
          path: '/app/messages',
          builder: (BuildContext context, GoRouterState state) {
            return const ProMessagesPage();
          },
        ),
        GoRoute(
          path: '/app/projet',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProjectsPage();
          },
        ),
        GoRoute(
          path: '/app/profil',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProfilePage();
          },
        ),
        GoRoute(
          path: '/app/notifications',
          builder: (BuildContext context, GoRouterState state) {
            return const ProNotificationsPage();
          },
        ),
        GoRoute(
          path: '/app/proposition-details',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProposalDetailsPage();
          },
        ),
        GoRoute(
          path: '/app/proposition-create',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProposalCreatePage();
          },
        ),
        GoRoute(
          path: '/app/chat',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            String? name;
            String? initials;
            if (extra is Map) {
              name = extra['name'] as String?;
              initials = extra['initials'] as String?;
            }
            return ProChatPage(name: name, initials: initials);
          },
        ),
      ],
    ),
    // Espace Novice avec barre de navigation persistante (AppShell paramétré).
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        const proTabs = [
          NavTab('/pro/home', 'Accueil', Icons.home_outlined),
          NavTab('/pro/messages', 'Messages', Icons.chat_bubble_outline),
          NavTab('/pro/projet', 'Projet', Icons.topic_outlined),
          NavTab('/pro/profil', 'Profile', Icons.person_outline),
        ];
        return AppShell(tabs: proTabs, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/pro/home',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceHomePage();
          },
        ),
        GoRoute(
          path: '/pro/messages',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceMessagesPage();
          },
        ),
        GoRoute(
          path: '/pro/projet',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceProjectsPage();
          },
        ),
        GoRoute(
          path: '/pro/profil',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceProfilePage();
          },
        ),
      ],
    ),
  ],
);
