import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page "Mes demandes" (Espace Pro).
///
/// Affiche une liste de demandes de services reçues par le professionnel.
/// Chaque demande peut être en attente, acceptée ou rejetée, avec des actions
/// contextuelles (Accepter / Rejeter) et un passage à l'état suivant.
class ProServiceRequestsPage extends StatefulWidget {
  const ProServiceRequestsPage({super.key});

  @override
  State<ProServiceRequestsPage> createState() => _ProServiceRequestsPageState();
}

/// State principal de la page Mes demandes.
///
/// - Maintient une liste en mémoire `_items` des demandes.
/// - Construit l'interface en fonction du statut de chaque demande.
/// - Met à jour l'état (acceptée/rejetée) au clic sur les boutons.
class _ProServiceRequestsPageState extends State<ProServiceRequestsPage> {
  /// Liste en mémoire des demandes de service (mock pour démonstration UI).
  final List<_ServiceRequest> _items = <_ServiceRequest>[
    const _ServiceRequest(
      initials: 'MK',
      name: 'Mamadou Koné',
      titleLine1: "Construction d'une",
      titleLine2: 'maison familiale',
      location: 'Bamako, ACI 2000',
      sentDate: '22 octobre 2025',
      sizeText: '300m².',
      status: _RequestStatus.pending,
    ),
    const _ServiceRequest(
      initials: 'IT',
      name: 'Ibrahim Traoré',
      titleLine1: "Construction d'un mur de",
      titleLine2: 'clôture',
      location: 'Bamako, Kalaban Coura',
      sentDate: '20 octobre 2025',
      sizeText: null,
      status: _RequestStatus.accepted,
    ),
    const _ServiceRequest(
      initials: 'AS',
      name: 'Aminata Sangaré',
      titleLine1: 'Extension de bâtiment',
      titleLine2: null,
      location: 'Bamako, Magnambougou',
      sentDate: '19 octobre 2025',
      sizeText: null,
      status: _RequestStatus.rejected,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pro/home'),
        ),
        centerTitle: true,
        title: const Text('Mes demandes'),
      ),
      // Corps: liste des cartes de demandes avec séparateurs verticaux
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = _items[index];
          // Déterminer l'état visuel (pastille) et l'action principale selon le statut
          late final String statusLabel;
          late final Color statusBg;
          late final Color statusFg;
          late final _PrimaryAction action;
          switch (r.status) {
            case _RequestStatus.pending:
              statusLabel = 'En attente';
              statusBg = const Color(0xFFFEF9C3);
              statusFg = const Color(0xFF854D0E);
              action = _PrimaryAction.acceptReject;
              break;
            case _RequestStatus.accepted:
              statusLabel = 'Acceptée';
              statusBg = const Color(0xFFDCFCE7);
              statusFg = const Color(0xFF15803D);
              action = _PrimaryAction.propose;
              break;
            case _RequestStatus.rejected:
              statusLabel = 'Rejetée';
              statusBg = const Color(0xFFFEE2E2);
              statusFg = const Color(0xFFB91C1C);
              action = _PrimaryAction.none;
              break;
          }

          return _RequestCard(
            initials: r.initials,
            name: r.name,
            titleLine1: r.titleLine1,
            titleLine2: r.titleLine2,
            statusLabel: statusLabel,
            statusColor: statusBg,
            statusTextColor: statusFg,
            location: r.location,
            sentDate: r.sentDate,
            sizeText: r.sizeText,
            primaryAction: action,
            // Action: passer à Acceptée
            onAccept: action == _PrimaryAction.acceptReject
                ? () => setState(() => _items[index] = r.copyWith(status: _RequestStatus.accepted))
                : null,
            // Action: passer à Rejetée
            onReject: action == _PrimaryAction.acceptReject
                ? () => setState(() => _items[index] = r.copyWith(status: _RequestStatus.rejected))
                : null,
            // Action: ouvrir la page de création de proposition
            onPropose: action == _PrimaryAction.propose
                ? () { context.push('/pro/proposition-create'); }
                : null,
          );
        },
      ),
    );
  }
}

/// Statuts possibles d'une demande de service.
enum _RequestStatus { pending, accepted, rejected }

/// Modèle léger représentant une demande de service reçue.
class _ServiceRequest {
  const _ServiceRequest({
    required this.initials,
    required this.name,
    required this.titleLine1,
    required this.titleLine2,
    required this.location,
    required this.sentDate,
    required this.sizeText,
    required this.status,
  });

  /// Initiales de l'expéditeur (affichage avatar).
  final String initials;
  /// Nom complet de l'expéditeur.
  final String name;
  /// Première ligne du titre de la demande.
  final String titleLine1;
  /// Deuxième ligne de titre (optionnelle).
  final String? titleLine2;
  /// Localisation du projet/demande.
  final String location;
  /// Date d'envoi de la demande.
  final String sentDate;
  /// Détail sur la taille (optionnel).
  final String? sizeText;
  /// Statut courant de la demande.
  final _RequestStatus status;

  /// Crée une nouvelle demande en copiant la présente (valeurs modifiées si fournies).
  _ServiceRequest copyWith({
    String? initials,
    String? name,
    String? titleLine1,
    String? titleLine2,
    String? location,
    String? sentDate,
    String? sizeText,
    _RequestStatus? status,
  }) {
    return _ServiceRequest(
      initials: initials ?? this.initials,
      name: name ?? this.name,
      titleLine1: titleLine1 ?? this.titleLine1,
      titleLine2: titleLine2 ?? this.titleLine2,
      location: location ?? this.location,
      sentDate: sentDate ?? this.sentDate,
      sizeText: sizeText ?? this.sizeText,
      status: status ?? this.status,
    );
  }
}

/// Action principale disponible pour une carte (en fonction du statut)
enum _PrimaryAction { acceptReject, propose, none }

/// Carte d'une demande de service avec avatar, informations et actions.
class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.initials,
    required this.name,
    required this.titleLine1,
    required this.titleLine2,
    required this.statusLabel,
    required this.statusColor,
    required this.statusTextColor,
    required this.location,
    required this.sentDate,
    required this.sizeText,
    required this.primaryAction,
    this.onAccept,
    this.onReject,
    this.onPropose,
  });

  /// Initiales de l'expéditeur (affichage avatar).
  final String initials;
  /// Nom complet de l'expéditeur.
  final String name;
  /// Première ligne du titre de la demande.
  final String titleLine1;
  /// Deuxième ligne de titre (optionnelle).
  final String? titleLine2;
  /// Libellé du statut.
  final String statusLabel;
  /// Couleur de fond du statut.
  final Color statusColor;
  /// Couleur de texte du statut.
  final Color statusTextColor;
  /// Localisation du projet/demande.
  final String location;
  /// Date d'envoi de la demande.
  final String sentDate;
  /// Détail sur la taille (optionnel).
  final String? sizeText;
  /// Action principale disponible.
  final _PrimaryAction primaryAction;
  /// Action: passer à Acceptée.
  final VoidCallback? onAccept;
  /// Action: passer à Rejetée.
  final VoidCallback? onReject;
  /// Action: ouvrir la page de création de proposition.
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entête: avatar + infos de titre + chip de statut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(initials, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Text(titleLine1, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                      if (titleLine2 != null) Text(titleLine2!, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(9999)),
                  child: Text(statusLabel, style: theme.textTheme.labelSmall?.copyWith(color: statusTextColor, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bloc d'informations secondaires (lieu + date)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(location, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text('Envoyée le $sentDate', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
            if (sizeText != null) ...[
              const SizedBox(height: 8),
              Text(sizeText!, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF111827))),
            ],
            const SizedBox(height: 12),
            // Actions principales en fonction du statut
            if (primaryAction == _PrimaryAction.acceptReject)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rejeter'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              )
            else if (primaryAction == _PrimaryAction.propose)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPropose,
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Faire une proposition'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
