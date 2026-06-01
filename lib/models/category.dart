// lib/models/category.dart

class Category {
  final String id;
  String name;
  int colorValue; // Stocker la couleur comme int (Color.value)
  String icon;    // Nom de l'icône MaterialIcons
  String userId;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.icon,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'icon': icon,
      'userId': userId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorValue: map['colorValue'],
      icon: map['icon'],
      userId: map['userId'],
    );
  }

  // Catégories par défaut
  static List<Category> defaultCategories(String userId) {
    return [
      Category(id: 'work', name: 'Travail', colorValue: 0xFF2196F3, icon: 'work', userId: userId),
      Category(id: 'personal', name: 'Personnel', colorValue: 0xFF4CAF50, icon: 'person', userId: userId),
      Category(id: 'school', name: 'École', colorValue: 0xFFFF9800, icon: 'school', userId: userId),
      Category(id: 'health', name: 'Santé', colorValue: 0xFFE91E63, icon: 'favorite', userId: userId),
    ];
  }
}
