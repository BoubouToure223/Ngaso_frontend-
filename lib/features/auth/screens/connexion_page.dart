import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// La page de connexion, où les utilisateurs peuvent entrer leurs identifiants.
class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

/// L'état de la page de connexion, gérant le formulaire et les contrôleurs de texte.
class _ConnexionPageState extends State<ConnexionPage> {
  // Clé globale pour le formulaire, utilisée pour la validation.
  final _formKey = GlobalKey<FormState>();
  // Contrôleur pour le champ de saisie de l'e-mail.
  final _emailController = TextEditingController();
  // Contrôleur pour le champ de saisie du mot de passe.
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Libère les ressources des contrôleurs lorsque le widget est supprimé.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Espacement supérieur pour simuler une barre d'état.
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                // Bouton de retour pour naviguer vers la page précédente.
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 346),
                    // Formulaire contenant les champs de saisie et le bouton de soumission.
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icône de connexion centrée.
                          SizedBox(
                            width: 280,
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.login, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Titre et paragraphe de la page.
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Text(
                                  'Connexion',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Accédez à votre espace personnel',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'pour gérer vos projets de',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'construction',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Champ de saisie pour l'e-mail.
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Entrez votre email';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Email invalide';
                              return null;
                            },
                             decoration: const InputDecoration(labelText: 'Entrez votre email'),
                          ),
                          const SizedBox(height: 16),
                          // Champ de saisie pour le mot de passe.
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            validator: (v) => v == null || v.isEmpty ? 'Entrez votre mot de passe' : null,
                            decoration: const InputDecoration(labelText: 'Entrez votre mot de passe'),
                          ),
                          const SizedBox(height: 12),
                          // Bouton pour la récupération du mot de passe.
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bouton de connexion.
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                // Valide le formulaire avant de continuer.
                                if (!(_formKey.currentState?.validate() ?? false)) return;
                                context.go('/pro/home');
                              },
                              child: const Text('Se connecter'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Lien pour s'inscrire.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Vous n'avez pas de compte ?",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () => context.push('/profile-choice'),
                                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                                child: const Text("S'inscrire"),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
