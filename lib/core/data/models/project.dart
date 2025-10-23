

class Project {
  final String id;
  final String title;
  final String imageUrl;
  final String currentStep;
  final String nextStep;
  final String status; // Ex: 'En cours', 'Terminé'

  Project({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.currentStep,
    required this.nextStep,
    required this.status,
  });

  // Méthode de 'factory' pour simuler la désérialisation JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      currentStep: json['currentStep'] as String,
      nextStep: json['nextStep'] as String,
      status: json['status'] as String,
    );
  }
}