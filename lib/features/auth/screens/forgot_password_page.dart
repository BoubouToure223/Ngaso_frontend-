import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page permettant à l'utilisateur de réinitialiser son mot de passe.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

/// État de la page de mot de passe oublié, gérant le formulaire et les champs de saisie.
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Clé globale pour le formulaire, utilisée pour la validation.
  final _formKey = GlobalKey<FormState>();
  // Contrôleur pour le champ de saisie de l'e-mail.
  final _emailController = TextEditingController();
  // Contrôleur pour le champ de saisie du nouveau mot de passe.
  final _newPasswordController = TextEditingController();
  // Contrôleur pour le champ de confirmation du mot de passe.
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Libère les ressources des contrôleurs lorsque le widget est supprimé.
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Espacement supérieur.
            const SizedBox(height: 24),
            // Barre supérieure avec bouton de retour.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
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
                    // Formulaire de réinitialisation de mot de passe.
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Icône de cadenas.
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
                                  child: Icon(Icons.lock_outline, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Titre et description.
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Text(
                                  'Mot de passe oublier',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Vous avez oublier votre mot de passe ?',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Changer le en toute tranquilité',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Champ de saisie pour l'email.
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
                          // Champ de saisie pour le nouveau mot de passe.
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            validator: (v) => v == null || v.isEmpty ? 'Entrez le nouveau mot de passe' : null,
                            decoration: const InputDecoration(labelText: 'Entrez le nouveau mot de passe'),
                          ),
                          const SizedBox(height: 16),
                          // Champ de saisie pour la confirmation du mot de passe.
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
                              if (v != _newPasswordController.text) return 'Les mots de passe ne correspondent pas';
                              return null;
                            },
                            decoration: const InputDecoration(labelText: 'Confirmez le mot de passe'),
                          ),
                          const SizedBox(height: 41),
                          // Bouton de confirmation.
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                // Valide le formulaire avant de soumettre.
                                if (!(_formKey.currentState?.validate() ?? false)) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mot de passe mis à jour (demo)')),
                                );
                              },
                              child: const Text(
                                'Confirmer',
                              ),
                            ),
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
