class College {
  final String id;
  final String name;
  final String shortCode;
  final String? emailDomain;
  final String? city;
  final String? locality;

  College({
    required this.id,
    required this.name,
    required this.shortCode,
    this.emailDomain,
    this.city,
    this.locality,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'] as String,
      name: json['name'] as String,
      shortCode: json['shortCode'] as String,
      emailDomain: json['emailDomain'] as String?,
      city: json['city'] as String?,
      locality: json['locality'] as String?,
    );
  }

  bool get isLiet => shortCode.toUpperCase() == 'LIET';
}
