import 'college.dart';

class User {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String gender;
  final String dob;
  final College? college;
  final String datingIntent;
  final String? bio;
  final String? collegeEmail;
  final bool isStudentVerified;
  final bool isPhotoVerified;
  final String? avatarUrl;
  final String preferredArea;

  User({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.gender,
    required this.dob,
    this.college,
    required this.datingIntent,
    this.bio,
    this.collegeEmail,
    required this.isStudentVerified,
    required this.isPhotoVerified,
    this.avatarUrl,
    this.preferredArea = 'Knowledge Park II',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String,
      gender: json['gender'] as String,
      dob: json['dob'] as String,
      college: json['college'] != null ? College.fromJson(json['college']) : null,
      datingIntent: json['datingIntent'] as String? ?? 'GO_WITH_THE_FLOW',
      bio: json['bio'] as String?,
      collegeEmail: json['collegeEmail'] as String?,
      isStudentVerified: json['isStudentVerified'] as bool? ?? false,
      isPhotoVerified: json['isPhotoVerified'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      preferredArea: json['preferredArea'] as String? ?? 'Knowledge Park II',
    );
  }
}
