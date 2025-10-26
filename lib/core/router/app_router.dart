
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
import 'package:myapp/features/pro/screens/realizations_page.dart';
import 'package:myapp/features/pro/screens/change_password_page.dart';
import 'package:myapp/features/pro/screens/service_requests_page.dart';
import 'package:myapp/features/novice/screens/home_page.dart';
import 'package:myapp/features/novice/screens/messages_page.dart';
import 'package:myapp/features/novice/screens/projects_page.dart';
import 'package:myapp/features/novice/screens/profile_page.dart';
import 'package:myapp/features/novice/screens/chat_page.dart';
import 'package:myapp/features/novice/screens/change_password_page.dart';
import 'package:myapp/features/novice/screens/notifications_page.dart';
import 'package:myapp/features/novice/screens/guide_permis_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Fonction utilitaire pour le SVG (avec placeholder discret)
Widget createSvgIcon(String assetPath) {
  return SvgPicture.asset(
    assetPath,
    width: 24,
    height: 24,
    placeholderBuilder: (context) => const SizedBox(width: 24, height: 24),
  );
}

/// La configuration du routeur de l'application.
final GoRouter router = GoRouter(
  routes: <RouteBase>[
    // La route initiale de l'application.
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) => '/Novice/home',
    ),
    // La route pour la page splash.
    GoRoute(
      path: '/splash',
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
        const proTabs = [
          NavTab('/pro/home', 'Accueil', Icon(Icons.home_outlined)),
          NavTab('/pro/messages', 'Messages', Icon(Icons.chat_bubble_outline)),
          NavTab('/pro/projet', 'Projet', Icon(Icons.topic_outlined)),
          NavTab('/pro/profil', 'Profile', Icon(Icons.person_outline)),
        ];
        return AppShell(tabs: proTabs, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/pro/home',
          builder: (BuildContext context, GoRouterState state) {
            return const ProHomePage();
          },
        ),
        GoRoute(
          path: '/pro/messages',
          builder: (BuildContext context, GoRouterState state) {
            return const ProMessagesPage();
          },
        ),
        GoRoute(
          path: '/pro/projet',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProjectsPage();
          },
        ),
        GoRoute(
          path: '/pro/profil',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProfilePage();
          },
        ),
        GoRoute(
          path: '/pro/notifications',
          builder: (BuildContext context, GoRouterState state) {
            return const ProNotificationsPage();
          },
        ),
        GoRoute(
          path: '/pro/service-requests',
          builder: (BuildContext context, GoRouterState state) {
            return const ProServiceRequestsPage();
          },
        ),
        GoRoute(
          path: '/pro/proposition-details',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProposalDetailsPage();
          },
        ),
        GoRoute(
          path: '/pro/proposition-create',
          builder: (BuildContext context, GoRouterState state) {
            return const ProProposalCreatePage();
          },
        ),
        GoRoute(
          path: '/pro/realizations',
          builder: (BuildContext context, GoRouterState state) {
            return const ProRealizationsPage();
          },
        ),
        GoRoute(
          path: '/pro/change-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ProChangePasswordPage();
          },
        ),
        GoRoute(
          path: '/pro/chat',
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
        final noviceTabs = [
          NavTab('/Novice/home', 'Accueil', createSvgIcon('assets/icons/home_icon.svg')),
          NavTab('/Novice/messages', 'Messages', createSvgIcon('assets/icons/message_icon.svg')),
          NavTab('/Novice/projet', 'Demandes', createSvgIcon('assets/icons/demande_icon.svg')),
          NavTab('/Novice/profil', 'Profile', createSvgIcon('assets/icons/profile_icon.svg')),
        ];
        return AppShell(tabs: noviceTabs, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/Novice/home',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceHomePage();
          },
        ),
        GoRoute(
          path: '/Novice/messages',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceMessagesPage();
          },
        ),
        GoRoute(
          path: '/Novice/projet',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceProjectsPage();
          },
        ),
        GoRoute(
          path: '/Novice/profil',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceProfilePage();
          },
        ),
        GoRoute(
          path: '/Novice/guide-permis',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceGuidePermisPage();
          },
        ),
        GoRoute(
          path: '/Novice/notifications',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceNotificationsPage();
          },
        ),
        GoRoute(
          path: '/Novice/change-password',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceChangePasswordPage();
          },
        ),
        GoRoute(
          path: '/Novice/chat',
          builder: (BuildContext context, GoRouterState state) {
            return const NoviceChatPage();
          },
        ),
      ],
    ),
  ],
);
