class PostCategory {
  final String id;
  final String name;
  final String? description;
  final String colorCode;
  final bool isSystemCategory;
  final DateTime createdAt;

  PostCategory({
    required this.id,
    required this.name,
    this.description,
    required this.colorCode,
    required this.isSystemCategory,
    required this.createdAt,
  });

  factory PostCategory.fromJson(Map<String, dynamic> json) {
    return PostCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorCode: json['color_code'] as String? ?? '#3B82F6',
      isSystemCategory: json['is_system_category'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_code': colorCode,
      'is_system_category': isSystemCategory,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PostCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? colorCode,
    bool? isSystemCategory,
    DateTime? createdAt,
  }) {
    return PostCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorCode: colorCode ?? this.colorCode,
      isSystemCategory: isSystemCategory ?? this.isSystemCategory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
