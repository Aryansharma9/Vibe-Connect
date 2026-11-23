import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';

class ModerationNotifier extends StateNotifier<AsyncValue<void>> {
  ModerationNotifier() : super(const AsyncValue.data(null));

  final _dio = ApiClient().dio;

  Future<bool> reportUser(String reportedUserId, String reason, String? details) async {
    state = const AsyncValue.loading();
    try {
      final res = await _dio.post('/moderation/report', data: {
        'reportedUserId': reportedUserId,
        'reason': reason,
        if (details != null) 'details': details,
      });
      state = const AsyncValue.data(null);
      return res.data != null && res.data['success'] == true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> blockUser(String targetUserId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _dio.post('/moderation/block', data: {
        'targetUserId': targetUserId,
      });
      state = const AsyncValue.data(null);
      return res.data != null && res.data['success'] == true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final moderationProvider = StateNotifierProvider<ModerationNotifier, AsyncValue<void>>((ref) {
  return ModerationNotifier();
});
