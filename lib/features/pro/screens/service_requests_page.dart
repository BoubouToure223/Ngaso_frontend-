import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/data/services/pro_api_service.dart';

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
  final ProApiService _api = ProApiService();
  final List<_ServiceRequest> _items = <_ServiceRequest>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _rejectDemande({required int demandeId, required int itemIndex}) async {
    try {
      await _api.refuseDemande(demandeId);
      if (!mounted) return;
      setState(() {
        _items[itemIndex] = _items[itemIndex].copyWith(status: _RequestStatus.rejected);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande rejetée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _acceptDemande({required int demandeId, required int itemIndex}) async {
    try {
      await _api.validateDemande(demandeId);
      if (!mounted) return;
      setState(() {
        _items[itemIndex] = _items[itemIndex].copyWith(status: _RequestStatus.accepted);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande acceptée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getMyDemandes();
      final mapped = data.map<_ServiceRequest>((e) {
        final m = e as Map;
        final id = (m['id'] as num?)?.toInt() ?? 0;
        final statut = (m['statut'] as String?) ?? '';
        _RequestStatus status;
        switch (statut) {
          case 'EN_ATTENTE':
            status = _RequestStatus.pending;
            break;
          case 'ACCEPTER':
            status = _RequestStatus.accepted;
            break;
          case 'REFUSER':
          case 'ANNULER':
            status = _RequestStatus.rejected;
            break;
          default:
            status = _RequestStatus.pending;
        }
        final noviceNom = m['noviceNom'] as String?;
        final novicePrenom = m['novicePrenom'] as String?;
        final name = [noviceNom, novicePrenom]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join(' ')
            .trim();
        final initials = ([noviceNom, novicePrenom]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .map((s) => s.trim()[0].toUpperCase())
                .take(2)
                .join())
            .padRight(2, '*');
        final projetTitre = (m['projetTitre'] as String?) ?? '';
        // Essayer d'extraire l'identifiant projet et budget si présents
        final int? projetId = (() {
          final v1 = m['projetId'];
          if (v1 is num) return v1.toInt();
          if (v1 is String) return int.tryParse(v1);
          final v2 = m['idProjet'];
          if (v2 is num) return v2.toInt();
          if (v2 is String) return int.tryParse(v2);
          final p = m['projet'];
          if (p is Map) {
            final pid = p['id'];
            if (pid is num) return pid.toInt();
            if (pid is String) return int.tryParse(pid);
          }
          return null;
        })();
        final projectBudget = m['budget'] ?? m['projetBudget'] ?? (m['projet'] is Map ? (m['projet']['budget']) : null);
        final etapeModeleNom = (m['etapeModeleNom'] as String?) ?? '';
        final message = (m['message'] as String?) ?? '';
        final localite =
            (m['localite'] as String?) ??
            (m['localiteNom'] as String?) ??
            (m['locality'] as String?) ??
            (m['lieu'] as String?) ??
            '';
        final iso = m['dateCreation'] as String?;
        final sentDate = (() {
          if (iso == null || iso.isEmpty) return '-';
          try {
            final dt = DateTime.parse(iso).toLocal();
            return DateFormat('dd/MM/yyyy HH:mm').format(dt);
          } catch (_) {
            return '-';
          }
        })();
        return _ServiceRequest(
          id: id,
          initials: initials,
          name: name.isEmpty ? '—' : name,
          titleLine1: projetTitre.isNotEmpty ? projetTitre : '—',
          titleLine2: null,
          location: localite,
          sentDate: sentDate,
          sizeText: null,
          message: message,
          stepLabel: etapeModeleNom.isNotEmpty ? etapeModeleNom : null,
          status: status,
          projectId: projetId,
          projectBudget: projectBudget,
        );
      }).toList(growable: false);
      setState(() {
        _items
          ..clear()
          ..addAll(mapped);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
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
        itemCount: _items.length + (_loading || _error != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (_loading && index == 0) {
            return const LinearProgressIndicator();
          }
          if (_error != null && index == 0) {
            return Text(_error!, style: const TextStyle(color: Colors.red));
          }
          final adjustedIndex = _loading || _error != null ? index - 1 : index;
          final r = _items[adjustedIndex];
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
            message: r.message,
            stepLabel: r.stepLabel,
            primaryAction: action,
            // Action: passer à Acceptée
            onAccept: action == _PrimaryAction.acceptReject
                ? () => _acceptDemande(demandeId: r.id, itemIndex: adjustedIndex)
                : null,
            // Action: passer à Rejetée
            onReject: action == _PrimaryAction.acceptReject
                ? () => _rejectDemande(demandeId: r.id, itemIndex: adjustedIndex)
                : null,
            // Action: ouvrir la page de création de proposition
            onPropose: action == _PrimaryAction.propose
                ? () {
                    context.push(
                      '/pro/proposition-create',
                      extra: {
                        if (r.projectId != null) 'projectId': r.projectId,
                        'projectTitle': r.titleLine1,
                        if (r.location.trim().isNotEmpty && r.location.trim() != '—' && r.location.trim() != '-')
                          'projectLocation': r.location,
                        if (r.projectBudget != null) 'projectBudget': r.projectBudget,
                      },
                    );
                  }
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
    required this.id,
    required this.initials,
    required this.name,
    required this.titleLine1,
    required this.titleLine2,
    required this.location,
    required this.sentDate,
    required this.sizeText,
    required this.message,
    this.stepLabel,
    required this.status,
    this.projectId,
    this.projectBudget,
  });

  /// Identifiant de la demande.
  final int id;
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
  /// Message de la demande.
  final String message;
  /// Libellé de l'étape (optionnel) ex: etapeModeleNom
  final String? stepLabel;
  /// Statut courant de la demande.
  final _RequestStatus status;
  /// Identifiant du projet lié (si disponible)
  final int? projectId;
  /// Budget du projet (dynamique car peut être int/double/String selon API)
  final dynamic projectBudget;

  /// Crée une nouvelle demande en copiant la présente (valeurs modifiées si fournies).
  _ServiceRequest copyWith({
    int? id,
    String? initials,
    String? name,
    String? titleLine1,
    String? titleLine2,
    String? location,
    String? sentDate,
    String? sizeText,
    String? message,
    String? stepLabel,
    _RequestStatus? status,
    int? projectId,
    dynamic projectBudget,
  }) {
    return _ServiceRequest(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      name: name ?? this.name,
      titleLine1: titleLine1 ?? this.titleLine1,
      titleLine2: titleLine2 ?? this.titleLine2,
      location: location ?? this.location,
      sentDate: sentDate ?? this.sentDate,
      sizeText: sizeText ?? this.sizeText,
      message: message ?? this.message,
      stepLabel: stepLabel ?? this.stepLabel,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      projectBudget: projectBudget ?? this.projectBudget,
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
    required this.message,
    this.stepLabel,
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
  /// Message de la demande.
  final String message;
  /// Libellé de l'étape (optionnel)
  final String? stepLabel;
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
            Text(message, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF111827))),
            if (stepLabel != null && stepLabel!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(stepLabel!, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF374151))))
                ],
              ),
            ],
            const SizedBox(height: 8),
            // Bloc d'informations secondaires (date)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Localité masquée sur demande
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
