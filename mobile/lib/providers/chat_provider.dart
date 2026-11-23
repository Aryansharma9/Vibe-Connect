import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/chat_message.dart';

final chatMessagesProvider = FutureProvider.family.autoDispose<List<ChatMessage>, String>((ref, conversationId) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/chat/$conversationId/messages');
    if (res.data != null && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    return [];
  }
  return [];
});

class ChatActionNotifier extends StateNotifier<AsyncValue<void>> {
  ChatActionNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<bool> sendMessage(String conversationId, String content) async {
    state = const AsyncValue.loading();
    try {
      final dio = ApiClient().dio;
      final res = await dio.post('/chat/send', data: {
        'conversationId': conversationId,
        'content': content,
      });

      if (res.data != null && res.data['success'] == true) {
        state = const AsyncValue.data(null);
        ref.invalidate(chatMessagesProvider(conversationId));
        return true;
      }
      state = AsyncValue.error(res.data['message'] ?? 'Failed', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final chatActionProvider = StateNotifierProvider<ChatActionNotifier, AsyncValue<void>>((ref) {
  return ChatActionNotifier(ref);
});
