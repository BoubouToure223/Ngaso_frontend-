class DashboardNoviceResponse {
  final String? nom;
  final String? prenom;
  final int? unreadNotifications;
  final LastProjectInfo? lastProject;

  DashboardNoviceResponse({this.nom, this.prenom, this.unreadNotifications, this.lastProject});

  factory DashboardNoviceResponse.fromJson(Map<String, dynamic> json) {
    return DashboardNoviceResponse(
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt(),
      lastProject: json['lastProject'] == null
          ? null
          : LastProjectInfo.fromJson(Map<String, dynamic>.from(json['lastProject'] as Map)),
    );
  }
}

class LastProjectInfo {
  final int? id;
  final String? titre;
  final int? totalEtapes;
  final int? etapesValidees;
  final int? progressPercent; // 0..100
  final String? currentEtape;
  final String? prochaineEtape;

  LastProjectInfo({
    this.id,
    this.titre,
    this.totalEtapes,
    this.etapesValidees,
    this.progressPercent,
    this.currentEtape,
    this.prochaineEtape,
  });

  factory LastProjectInfo.fromJson(Map<String, dynamic> json) {
    return LastProjectInfo(
      id: (json['id'] as num?)?.toInt(),
      titre: json['titre'] as String?,
      totalEtapes: (json['totalEtapes'] as num?)?.toInt(),
      etapesValidees: (json['etapesValidees'] as num?)?.toInt(),
      progressPercent: (json['progressPercent'] as num?)?.toInt(),
      currentEtape: json['currentEtape'] as String?,
      prochaineEtape: json['prochaineEtape'] as String?,
    );
  }
}
