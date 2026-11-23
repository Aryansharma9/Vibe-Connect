import 'user.dart';

class PromptAnswer {
  final String id;
  final String questionId;
  final User? user;
  final String answerText;
  final String? mediaUrl;
  final DateTime createdAt;

  PromptAnswer({
    required this.id,
    required this.questionId,
    this.user,
    required this.answerText,
    this.mediaUrl,
    required this.createdAt,
  });

  factory PromptAnswer.fromJson(Map<String, dynamic> json) {
    return PromptAnswer(
      id: json['id'] as String,
      questionId: json['questionId'] as String? ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      answerText: json['answerText'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
