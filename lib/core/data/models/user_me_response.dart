class UserMeResponse {
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final String? adresse;

  const UserMeResponse({this.nom, this.prenom, this.email, this.telephone, this.adresse});

  factory UserMeResponse.fromJson(Map<String, dynamic> json) {
    return UserMeResponse(
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
    );
  }
}
