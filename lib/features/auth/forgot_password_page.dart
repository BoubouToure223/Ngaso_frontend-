import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFCFAF7);

    const headingColor = Color(0xFF333333);
    const bodyColor = Color(0xFF5C5C5C);
    const primaryColor = Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFF171212),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 346),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 116),
                          SizedBox(
                            width: 280,
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.lock_outline, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Text(
                                  'Mot de passe oublier',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: headingColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20.4,
                                        height: 32 / 20.4,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Vous avez oublier votre mot de passe ?',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: bodyColor,
                                        fontSize: 13.6,
                                        height: 24 / 13.6,
                                      ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Changer le en toute tranquilité',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: bodyColor,
                                        fontSize: 13.6,
                                        height: 24 / 13.6,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _FilledTextField(
                            controller: _emailController,
                            label: 'Entrez votre email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Entrez votre email';
                              if (!RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(v)) return 'Email invalide';
                              return null;
                            },
                            topMargin: 24,
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: 0.7,
                            child: _FilledTextField(
                              controller: _newPasswordController,
                              label: 'Entrez le nouveau mot de passe',
                              obscureText: true,
                              validator: (v) => v == null || v.isEmpty ? 'Entrez le nouveau mot de passe' : null,
                              topMargin: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: 0.7,
                            child: _FilledTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmez le mot de passe',
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
                                if (v != _newPasswordController.text) return 'Les mots de passe ne correspondent pas';
                                return null;
                              },
                              topMargin: 24,
                            ),
                          ),
                          const SizedBox(height: 41),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                if (!(_formKey.currentState?.validate() ?? false)) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mot de passe mis à jour (demo)')),
                                );
                              },
                              child: const Text(
                                'Confirmer',
                                style: TextStyle(fontSize: 13.6, fontWeight: FontWeight.w500),
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

class _FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final double topMargin;

  const _FilledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.topMargin = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF000000)),
          filled: true,
          fillColor: const Color(0xFFEBEBEB),
          contentPadding: const EdgeInsets.fromLTRB(17, 13, 17, 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
