import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/space.dart';
import '../models/space_post.dart';

final spacesProvider = FutureProvider.autoDispose<List<Space>>((ref) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/spaces');
    if (res.data != null && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list.map((s) => Space.fromJson(s as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    return [];
  }
  return [];
});

final spacePostsProvider = FutureProvider.family.autoDispose<List<SpacePost>, String>((ref, spaceId) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/spaces/$spaceId/posts');
    if (res.data != null && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list.map((p) => SpacePost.fromJson(p as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    return [];
  }
  return [];
});

class SpaceActionNotifier extends StateNotifier<AsyncValue<void>> {
  SpaceActionNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<bool> createPost(String spaceId, String content) async {
    state = const AsyncValue.loading();
    try {
      final dio = ApiClient().dio;
      final res = await dio.post('/spaces/$spaceId/posts', data: {
        'content': content,
      });

      if (res.data != null && res.data['success'] == true) {
        state = const AsyncValue.data(null);
        ref.invalidate(spacePostsProvider(spaceId));
        ref.invalidate(spacesProvider);
        return true;
      }
      state = AsyncValue.error(res.data['message'] ?? 'Failed to post', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final spaceActionProvider = StateNotifierProvider<SpaceActionNotifier, AsyncValue<void>>((ref) {
  return SpaceActionNotifier(ref);
});
