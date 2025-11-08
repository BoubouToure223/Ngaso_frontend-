class AppNotification {
  final int id;
  final String type;
  final String contenu;
  final DateTime date;
  final bool estVu;

  AppNotification({
    required this.id,
    required this.type,
    required this.contenu,
    required this.date,
    required this.estVu,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      estVu: json['estVu'] == true || json['estVu']?.toString() == 'true',
    );
  }
}
