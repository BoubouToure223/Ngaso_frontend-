import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoviceStepsPage extends StatelessWidget {
  const NoviceStepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _mockSteps;
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
                  'Guide de construction',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suivez et validez chaque étape de votre projet de maison.',
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
            ),
            const SizedBox(height: 12),
            Text('Progression', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1C120D))),
            const SizedBox(height: 8),
            _Progress(value: 0.10),
            const SizedBox(height: 16),
            for (final s in steps) _StepCard(data: s),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final double value;
  const _Progress({required this.value});
  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: const Color(0xFFE8E4E1),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF3F51B5)),
        ),
        const SizedBox(height: 6),
        Text('$percent%', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A))),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final _Step data;
  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(data.imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (data.title.startsWith('Étape 1')) {
                    context.push('/Novice/steps/1');
                  } else if (data.title.startsWith('Étape 2')) {
                    context.push('/Novice/steps/2');
                  } else if (data.title.startsWith('Étape 3')) {
                    context.push('/Novice/steps/3');
                  } else if (data.title.startsWith('Étape 4')) {
                    context.push('/Novice/steps/4');
                  } else if (data.title.startsWith('Étape 5')) {
                    context.push('/Novice/steps/5');
                  } else if (data.title.startsWith('Étape 6')) {
                    context.push('/Novice/steps/6');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Voir détails: ${data.title}')),
                    );
                  }
                },
                child: const Text('Voir détails'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step {
  final String title;
  final String subtitle;
  final String imageAsset;
  const _Step({required this.title, required this.subtitle, required this.imageAsset});
}

const _mockSteps = <_Step>[
  _Step(title: 'Étape 1', subtitle: 'Étude du terrain\nTerminé', imageAsset: 'assets/images/etape1_img.png'),
  _Step(title: 'Étape 2', subtitle: 'Demande de permis de construire\nÀ venir', imageAsset: 'assets/images/etape2_img.png'),
  _Step(title: 'Étape 3', subtitle: 'Fondation\nÀ venir', imageAsset: 'assets/images/etape3_img.png'),
  _Step(title: 'Étape 4', subtitle: 'Élévation des murs\nÀ venir', imageAsset: 'assets/images/etape4_img.png'),
  _Step(title: 'Étape 5', subtitle: 'Couverture\nÀ venir', imageAsset: 'assets/images/etape5_img.png'),
  _Step(title: 'Étape 6', subtitle: 'Finition\nÀ venir', imageAsset: 'assets/images/etape6_img.png'),
];
