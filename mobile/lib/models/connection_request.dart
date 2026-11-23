import 'user.dart';

class ConnectionRequest {
  final String id;
  final User? sender;
  final User? receiver;
  final String contextType;
  final String? contextId;
  final String? contextSnippet;
  final String? initialNote;
  final String status;
  final DateTime createdAt;

  ConnectionRequest({
    required this.id,
    this.sender,
    this.receiver,
    required this.contextType,
    this.contextId,
    this.contextSnippet,
    this.initialNote,
    required this.status,
    required this.createdAt,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id'] as String,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      contextType: json['contextType'] as String? ?? 'PROMPT_ANSWER',
      contextId: json['contextId'] as String?,
      contextSnippet: json['contextSnippet'] as String?,
      initialNote: json['initialNote'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
