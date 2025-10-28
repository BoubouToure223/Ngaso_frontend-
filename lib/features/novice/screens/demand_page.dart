import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DemandPage extends StatelessWidget {
  const DemandPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _mockDemands;
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              
              Expanded(
                child: Text(
                  'Mes propositions de devis',
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _DemandCard(data: items[i]),
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  final _Demand data;
  const _DemandCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E3DF)),
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.category,
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.proName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1C120D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Devis estimé à ${data.price}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF3F51B5)),
                          foregroundColor: const Color(0xFF3F51B5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Voir profil: ${data.proName}')),
                          );
                        },
                        child: const Text('Voir profil'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  color: const Color(0xFFF0E5E1),
                  child: const Icon(Icons.person, size: 48, color: Color(0xFF7A4C3A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B4F4A)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB23B3B),
                    side: const BorderSide(color: Color(0xFFE7DCD5)),
                    backgroundColor: const Color(0xFFFAF2EE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Téléchargement du devis: ${data.proName}')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Télécharger le devis'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Proposition acceptée: ${data.proName}')),
                  );
                },
                child: const Text('Accepter'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFE53935),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Proposition refusée: ${data.proName}')),
                );
              },
              child: const Text('Refuser'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Demand {
  final String category;
  final String proName;
  final String price;
  final String description;

  const _Demand({
    required this.category,
    required this.proName,
    required this.price,
    required this.description,
  });
}

const _mockDemands = <_Demand>[
  _Demand(
    category: 'Maçonnerie',
    proName: 'Mamadou Traoré',
    price: '1 500 000 CFA',
    description: "Proposition de devis pour la maçonnerie de votre maison. Inclut les matériaux et la main-d'œuvre.",
  ),
  _Demand(
    category: 'Maçonnerie',
    proName: 'Mamadou Traoré',
    price: '1 500 000 CFA',
    description: "Proposition de devis pour la maçonnerie de votre maison. Inclut les matériaux et la main-d'œuvre.",
  ),
];
