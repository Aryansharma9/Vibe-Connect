import 'prompt_answer.dart';

class DailyQuestion {
  final String id;
  final String promptText;
  final String activeDate;
  final String category;
  final bool hasAnswered;
  final PromptAnswer? myAnswer;

  DailyQuestion({
    required this.id,
    required this.promptText,
    required this.activeDate,
    required this.category,
    required this.hasAnswered,
    this.myAnswer,
  });

  factory DailyQuestion.fromJson(Map<String, dynamic> json) {
    return DailyQuestion(
      id: json['id'] as String,
      promptText: json['promptText'] as String,
      activeDate: json['activeDate'] as String,
      category: json['category'] as String? ?? 'VIBE',
      hasAnswered: json['hasAnswered'] as bool? ?? false,
      myAnswer: json['myAnswer'] != null
          ? PromptAnswer.fromJson(json['myAnswer'] as Map<String, dynamic>)
          : null,
    );
  }
}
