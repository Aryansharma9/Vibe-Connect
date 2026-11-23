import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/connection_request.dart';
import '../models/conversation.dart';

final incomingRequestsProvider = FutureProvider.autoDispose<List<ConnectionRequest>>((ref) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/connections/incoming');
    if (res.data != null && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list.map((item) => ConnectionRequest.fromJson(item as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    return [];
  }
  return [];
});

final pendingCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/connections/count');
    if (res.data != null && res.data['success'] == true) {
      return (res.data['data'] as num).toInt();
    }
  } catch (e) {
    return 0;
  }
  return 0;
});

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/connections/conversations');
    if (res.data != null && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list.map((c) => Conversation.fromJson(c as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    return [];
  }
  return [];
});

class ConnectionActionNotifier extends StateNotifier<AsyncValue<void>> {
  ConnectionActionNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<bool> sendRequest({
    required String targetUserId,
    String? contextType,
    String? contextId,
    String? contextSnippet,
    String? initialNote,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ApiClient().dio;
      final res = await dio.post('/connections/send', data: {
        'targetUserId': targetUserId,
        'contextType': contextType ?? 'PROMPT_ANSWER',
        if (contextId != null) 'contextId': contextId,
        if (contextSnippet != null) 'contextSnippet': contextSnippet,
        if (initialNote != null) 'initialNote': initialNote,
      });

      if (res.data != null && res.data['success'] == true) {
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error(res.data['message'] ?? 'Failed to send request', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> respondToRequest(String requestId, bool accept) async {
    state = const AsyncValue.loading();
    try {
      final dio = ApiClient().dio;
      final res = await dio.post('/connections/$requestId/respond', data: {
        'accept': accept,
      });

      if (res.data != null && res.data['success'] == true) {
        state = const AsyncValue.data(null);
        ref.invalidate(incomingRequestsProvider);
        ref.invalidate(pendingCountProvider);
        ref.invalidate(conversationsProvider);
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

final connectionActionProvider = StateNotifierProvider<ConnectionActionNotifier, AsyncValue<void>>((ref) {
  return ConnectionActionNotifier(ref);
});
