import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/college.dart';
import '../models/user.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? phoneNumber;
  final String? devOtp;
  final bool otpSent;
  final bool isNewUser;
  final User? currentUser;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.phoneNumber,
    this.devOtp,
    this.otpSent = false,
    this.isNewUser = false,
    this.currentUser,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? phoneNumber,
    String? devOtp,
    bool? otpSent,
    bool? isNewUser,
    User? currentUser,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      devOtp: devOtp ?? this.devOtp,
      otpSent: otpSent ?? this.otpSent,
      isNewUser: isNewUser ?? this.isNewUser,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final _dio = ApiClient().dio;

  Future<bool> sendPhoneOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _dio.post('/auth/phone/otp', data: {'phoneNumber': phone});
      final devCode = res.data['data'] as String?;
      state = state.copyWith(
        isLoading: false,
        phoneNumber: phone,
        otpSent: true,
        devOtp: devCode,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to send OTP: $e');
      return false;
    }
  }

  Future<bool> verifyPhoneOtp(String otp, {
    String? fullName,
    String? gender,
    String? dob,
    College? college,
    String? datingIntent,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _dio.post('/auth/phone/verify', data: {
        'phoneNumber': state.phoneNumber,
        'otp': otp,
        if (fullName != null) 'fullName': fullName,
        if (gender != null) 'gender': gender,
        if (dob != null) 'dob': dob,
        if (college != null) 'collegeId': college.id,
        if (datingIntent != null) 'datingIntent': datingIntent,
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        final isNew = data['newUser'] == true;
        if (isNew) {
          state = state.copyWith(isLoading: false, isNewUser: true);
          return true;
        }

        final token = data['accessToken'] as String?;
        ApiClient().setAuthToken(token);

        final userMap = data['user'] as Map<String, dynamic>;
        state = state.copyWith(
          isLoading: false,
          isNewUser: false,
          currentUser: User.fromJson(userMap),
        );
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: res.data['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Verification failed: $e');
      return false;
    }
  }

  Future<bool> registerProfile({
    required String fullName,
    required String gender,
    required String dob,
    College? college,
    required String datingIntent,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final phone = state.phoneNumber ?? '9155817519';
      final res = await _dio.post('/auth/register', data: {
        'phoneNumber': phone,
        'fullName': fullName,
        'gender': gender,
        'dob': dob,
        if (college != null) 'collegeId': college.id,
        'datingIntent': datingIntent,
      });

      if (res.data != null && res.data['success'] == true) {
        final data = res.data['data'];
        final token = data['accessToken'] as String?;
        ApiClient().setAuthToken(token);

        final userMap = data['user'] as Map<String, dynamic>;
        state = state.copyWith(
          isLoading: false,
          isNewUser: false,
          currentUser: User.fromJson(userMap),
        );
        return true;
      }
      state = state.copyWith(isLoading: false, errorMessage: res.data['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Registration failed: $e');
      return false;
    }
  }

  Future<String?> sendCollegeEmailOtp(String email) async {
    try {
      final res = await _dio.post('/auth/college-email/otp', data: {'collegeEmail': email});
      return res.data['data'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifyCollegeEmailOtp(String email, String otp) async {
    try {
      final res = await _dio.post('/auth/college-email/verify', data: {
        'collegeEmail': email,
        'otp': otp,
      });
      if (res.data['success'] == true) {
        final updatedUser = User.fromJson(res.data['data']);
        state = state.copyWith(currentUser: updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
