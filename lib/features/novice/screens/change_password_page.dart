import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/data/repositories/auth_repository.dart';

class NoviceChangePasswordPage extends StatefulWidget {
  const NoviceChangePasswordPage({super.key});

  @override
  State<NoviceChangePasswordPage> createState() => _NoviceChangePasswordPageState();
}

class _NoviceChangePasswordPageState extends State<NoviceChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _ob1 = true, _ob2 = true, _ob3 = true;
  bool _submitting = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C120D)),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.lock_outline, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Changer',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Mot de passe',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF1C120D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _PwdField(
                    controller: _oldCtrl,
                    hint: 'Entrez votre mot de passe',
                    obscure: _ob1,
                    onToggle: () => setState(() => _ob1 = !_ob1),
                    validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                  const SizedBox(height: 14),
                  _PwdField(
                    controller: _newCtrl,
                    hint: 'Entrez le nouveau mot de passe',
                    obscure: _ob2,
                    onToggle: () => setState(() => _ob2 = !_ob2),
                    validator: (v) => (v == null || v.length < 6) ? '6 caractères min.' : null,
                  ),
                  const SizedBox(height: 14),
                  _PwdField(
                    controller: _confirmCtrl,
                    hint: 'Confirmez le mot de passe',
                    obscure: _ob3,
                    onToggle: () => setState(() => _ob3 = !_ob3),
                    validator: (v) => (v != _newCtrl.text) ? 'Les mots de passe ne correspondent pas' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Confirmer'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _submitting = true);
    try {
      final repo = AuthRepository();
      await repo.changePassword(
        oldPassword: _oldCtrl.text.trim(),
        newPassword: _newCtrl.text.trim(),
        confirmPassword: _confirmCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final msg = raw.startsWith('Exception: ') ? raw.substring('Exception: '.length) : raw;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _PwdField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final bool obscure;
  final VoidCallback onToggle;
  const _PwdField({
    required this.controller,
    required this.hint,
    required this.validator,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7D7D7D)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF7D7D7D)),
          ),
        ],
      ),
    );
  }
}
