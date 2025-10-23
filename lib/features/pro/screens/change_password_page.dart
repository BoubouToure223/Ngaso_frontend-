import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page Pro: modification du mot de passe.
///
/// Cette page présente un formulaire simple (mot de passe actuel,
/// nouveau mot de passe, confirmation) avec une soumission mock.
class ProChangePasswordPage extends StatefulWidget {
  const ProChangePasswordPage({super.key});

  @override
  State<ProChangePasswordPage> createState() => _ProChangePasswordPageState();
}

class _ProChangePasswordPageState extends State<ProChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Soumission mock du formulaire.
  ///
  /// - Valide les champs.
  /// - Simule un délai réseau.
  /// - Affiche des SnackBars de feedback.
  void _submit() async {
    final current = _currentCtrl.text.trim();
    final next = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _submitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifié (mock)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Structure générale: AppBar minimaliste + contenu scrollable.
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pro/profil'),
        ),
        centerTitle: true,
        title: const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bloc d'en-tête: icône, titre en deux lignes
                    const SizedBox(height: 24),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Color(0xFF3F51B5), shape: BoxShape.circle),
                      child: const Icon(Icons.password_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 20),
                    // Two-line title
                    SizedBox(
                      width: 270,
                      child: Column(
                        children: [
                          Text(
                            'Changer',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                              fontSize: 20.4,
                              height: 32 / 20.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mot de passe',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                              fontSize: 20.4,
                              height: 32 / 20.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form block
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Champs du formulaire (actuel / nouveau / confirmation)
                          _LabeledField(
                            label: 'Entrez votre mot de passe',
                            controller: _currentCtrl,
                            obscure: true,
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: 'Entrez le nouveau mot de passe',
                            controller: _newCtrl,
                            obscure: true,
                          ),
                          const SizedBox(height: 16),
                          _LabeledField(
                            label: 'Confirmez le mot de passe',
                            controller: _confirmCtrl,
                            obscure: true,
                          ),
                          const SizedBox(height: 41),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F51B5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: _submitting
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text(
                                      'Confirmer',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.6,
                                        height: 24 / 13.6,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ texte avec libellé utilisé dans le formulaire de changement de mot de passe.
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.controller, this.obscure = false});
  final String label;
  final TextEditingController controller;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    // Hauteur fixe pour correspondre au design des champs.
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xB3000000), fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 16, height: 24 / 16),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
