import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceProjectCreatePage extends StatefulWidget {
  const NoviceProjectCreatePage({super.key});

  @override
  State<NoviceProjectCreatePage> createState() => _NoviceProjectCreatePageState();
}

class _NoviceProjectCreatePageState extends State<NoviceProjectCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _sizeCtrl.dispose();
    _budgetCtrl.dispose();
    _locationCtrl.dispose();
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
              Expanded(
                child: Text(
                  'Nouveau projet',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1C120D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _Field(hint: 'Titre du projet', controller: _titleCtrl, validator: _req),
              const SizedBox(height: 14),
              _Field(hint: 'Dimensions du terrain', controller: _sizeCtrl, validator: _req),
              const SizedBox(height: 14),
              _Field(hint: 'Budget estimé', controller: _budgetCtrl, keyboardType: TextInputType.number, validator: _req),
              const SizedBox(height: 14),
              _Field(hint: 'Localisation du terrain', controller: _locationCtrl, validator: _req),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: const Text('Créer le projet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Requis' : null;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Projet créé (mock)')),
    );
    context.pop();
  }
}

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  const _Field({
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
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
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7D7D7D)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        ),
      ),
    );
  }
}
