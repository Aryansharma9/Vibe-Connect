import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/college.dart';

final collegeSearchQueryProvider = StateProvider<String>((ref) => '');

final collegesFutureProvider = FutureProvider<List<College>>((ref) async {
  final query = ref.watch(collegeSearchQueryProvider);
  final dio = ApiClient().dio;

  final response = await dio.get('/colleges', queryParameters: {
    if (query.isNotEmpty) 'search': query,
  });

  if (response.data != null && response.data['success'] == true) {
    final list = response.data['data'] as List<dynamic>;
    return list.map((c) => College.fromJson(c as Map<String, dynamic>)).toList();
  }
  return [];
});

final selectedCollegeProvider = StateProvider<College?>((ref) => null);
