import 'user.dart';

class SpacePost {
  final String id;
  final String spaceId;
  final User? user;
  final String content;
  final DateTime createdAt;

  SpacePost({
    required this.id,
    required this.spaceId,
    this.user,
    required this.content,
    required this.createdAt,
  });

  factory SpacePost.fromJson(Map<String, dynamic> json) {
    return SpacePost(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String? ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      content: json['content'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
