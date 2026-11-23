import 'user.dart';

class Conversation {
  final String id;
  final User? otherUser;
  final DateTime lastMessageAt;
  final bool isActive;
  final DateTime createdAt;

  Conversation({
    required this.id,
    this.otherUser,
    required this.lastMessageAt,
    required this.isActive,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      otherUser: json['otherUser'] != null ? User.fromJson(json['otherUser']) : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
