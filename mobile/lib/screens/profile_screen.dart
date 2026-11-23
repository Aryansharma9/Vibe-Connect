import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final college = user?.college;
    final isLiet = college?.isLiet == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Vibe Profile',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.surface,
                      isLiet ? AppColors.surfaceLight.withOpacity(0.5) : AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isLiet ? AppColors.campusLietGold.withOpacity(0.4) : AppColors.surfaceLight,
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (user?.isStudentVerified == true)
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.surface,
                              child: Icon(Icons.verified, color: AppColors.verifiedBlue, size: 22),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.fullName ?? 'Student',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      college?.name ?? 'Local Area Member',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Intent Tag
                    if (user != null && user.datingIntent.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Seeking: ${user.datingIntent.replaceAll('_', ' ')}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Verification status banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: user?.isStudentVerified == true
                            ? AppColors.successGreen.withOpacity(0.15)
                            : Colors.amber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        user?.isStudentVerified == true ? Icons.check_circle : Icons.pending,
                        color: user?.isStudentVerified == true ? AppColors.successGreen : Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.isStudentVerified == true ? 'Campus Student Verified' : 'Email Verification Pending',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.collegeEmail ?? (user?.isStudentVerified == true ? 'Verified student email' : 'Community Member'),
                            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Safe Dating & Campus Community Guidelines
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'VibeConnect Safety Standard',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Zero tolerance for harassment or fake campus identities.\n'
                      '• Meet in public spots: Popular cafes, libraries, or central meetup points.\n'
                      '• Block & report any student violating community trust immediately.',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout / Switch User Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.errorRed, size: 18),
                  label: Text(
                    'Log Out / Switch Student Account',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.errorRed, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.surfaceLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
