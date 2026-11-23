import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/daily_question.dart';
import '../models/prompt_answer.dart';

final myCampusOnlyFilterProvider = StateProvider<bool>((ref) => true);
final intentFilterProvider = StateProvider<String?>((ref) => null);

final todayPromptProvider = FutureProvider.autoDispose<DailyQuestion?>((ref) async {
  final dio = ApiClient().dio;
  try {
    final res = await dio.get('/prompts/today');
    if (res.data != null && res.data['success'] == true) {
      return DailyQuestion.fromJson(res.data['data']);
    }
  } catch (e) {
    return null;
  }
  return null;
});

final answersFeedProvider = FutureProvider.family.autoDispose<List<PromptAnswer>, String>((ref, questionId) async {
  final myCampusOnly = ref.watch(myCampusOnlyFilterProvider);
  final intent = ref.watch(intentFilterProvider);
  final dio = ApiClient().dio;

  try {
    final res = await dio.get('/prompts/$questionId/answers', queryParameters: {
      'myCampusOnly': myCampusOnly,
      if (intent != null) 'intent': intent,
    });

    if (res.data != null && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list.map((a) => PromptAnswer.fromJson(a as Map<String, dynamic>)).toList();
    }
  } catch (e) {
    return [];
  }
  return [];
});

class PromptActionNotifier extends StateNotifier<AsyncValue<void>> {
  PromptActionNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<bool> submitAnswer(String questionId, String text) async {
    state = const AsyncValue.loading();
    try {
      final dio = ApiClient().dio;
      final res = await dio.post('/prompts/answer', data: {
        'questionId': questionId,
        'answerText': text,
      });

      if (res.data != null && res.data['success'] == true) {
        state = const AsyncValue.data(null);
        ref.invalidate(todayPromptProvider);
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

final promptActionProvider = StateNotifierProvider<PromptActionNotifier, AsyncValue<void>>((ref) {
  return PromptActionNotifier(ref);
});
