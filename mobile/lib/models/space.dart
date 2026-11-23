class Space {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String description;
  final String category;
  final int memberCount;

  Space({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.description,
    required this.category,
    required this.memberCount,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'CAMPUS',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }
}
