class ProDashboard {
  final String prenom;
  final String? messageBienvenue;
  final int propositionsEnAttente;
  final int propositionsValidees;
  final int demandesTotal;
  final int messagesNonLus;
  final List<dynamic> realisations;
  final List<dynamic> derniersProjets;

  ProDashboard({
    required this.prenom,
    this.messageBienvenue,
    required this.propositionsEnAttente,
    required this.propositionsValidees,
    required this.demandesTotal,
    required this.messagesNonLus,
    required this.realisations,
    required this.derniersProjets,
  });

  factory ProDashboard.fromJson(Map<String, dynamic> json) {
    return ProDashboard(
      prenom: (json['prenom'] ?? '').toString(),
      messageBienvenue: json['messageBienvenue']?.toString(),
      propositionsEnAttente: (json['propositionsEnAttente'] ?? 0) as int,
      propositionsValidees: (json['propositionsValidees'] ?? 0) as int,
      demandesTotal: (json['demandesTotal'] ?? 0) as int,
      messagesNonLus: (json['messagesNonLus'] ?? 0) as int,
      realisations: (json['realisations'] as List?) ?? const [],
      derniersProjets: (json['derniersProjets'] as List?) ?? const [],
    );
  }
}
