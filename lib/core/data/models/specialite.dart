class Specialite {
  final dynamic id;
  final String libelle;

  Specialite({required this.id, required this.libelle});

  factory Specialite.fromJson(dynamic json) {
    // Tolérant: accepte Map avec clés variées ou chaîne simple
    if (json is Map<String, dynamic>) {
      final id = json['id'] ?? json['code'] ?? json['value'];
      final name = (json['nom'] ?? json['libelle'] ?? json['name'] ?? json['label'] ?? '').toString();
      return Specialite(id: id, libelle: name);
    }
    return Specialite(id: json, libelle: json.toString());
  }
}
