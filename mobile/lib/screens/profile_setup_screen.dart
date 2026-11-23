import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../models/college.dart';
import '../providers/auth_provider.dart';
import '../providers/college_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedGender = 'FEMALE';
  String _selectedIntent = 'GO_WITH_THE_FLOW';
  College? _chosenCollege; // Defaults to null (Optional choice)
  final DateTime _dob = DateTime(2003, 5, 14);

  final List<Map<String, String>> _intentOptions = [
    {'key': 'LONG_TERM', 'title': 'Long-term vibe', 'desc': 'Looking for something meaningful'},
    {'key': 'GO_WITH_THE_FLOW', 'title': 'Go with the flow', 'desc': 'Open to seeing where it goes'},
    {'key': 'CASUAL', 'title': 'Casual & hangout', 'desc': 'Coffee, chai & friendly hangouts'},
    {'key': 'STUDY_BUDDY', 'title': 'Study & Jam buddy', 'desc': 'Tech projects, deep talks & chilling'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onCompleteSetup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    // Save chosen college to provider
    ref.read(selectedCollegeProvider.notifier).state = _chosenCollege;

    final ok = await ref.read(authProvider.notifier).registerProfile(
      fullName: name,
      gender: _selectedGender,
      dob: _dob.toIso8601String().split('T').first,
      college: _chosenCollege,
      datingIntent: _selectedIntent,
    );

    if (ok && mounted) {
      context.push('/search-specification');
    } else if (mounted) {
      final err = ref.read(authProvider).errorMessage ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final collegesAsync = ref.watch(collegesFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Your Profile',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
            tooltip: 'Log Out',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about yourself',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Set up your details to match with people around your area',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              Text('FULL NAME',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Aryan Sharma',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gender Selector
              Text('GENDER',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderChip('FEMALE', 'Woman'),
                  const SizedBox(width: 12),
                  _buildGenderChip('MALE', 'Man'),
                  const SizedBox(width: 12),
                  _buildGenderChip('NON_BINARY', 'Non-binary'),
                ],
              ),
              const SizedBox(height: 24),

              // College / Campus (Optional Choice)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'COLLEGE / CAMPUS (OPTIONAL)',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  if (_chosenCollege != null)
                    GestureDetector(
                      onTap: () => setState(() => _chosenCollege = null),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              collegesAsync.when(
                data: (colleges) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<College?>(
                        value: _chosenCollege,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        hint: Text(
                          'Select your college (Optional - or leave blank)',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white60),
                        items: [
                          DropdownMenuItem<College?>(
                            value: null,
                            child: Text(
                              'None / Not a student (General User)',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                          ...colleges.map((c) => DropdownMenuItem<College?>(
                                value: c,
                                child: Text(
                                  c.name,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                        ],
                        onChanged: (College? val) {
                          setState(() => _chosenCollege = val);
                        },
                      ),
                    ),
                  );
                },
                loading: () => Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                ),
                error: (_, __) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'No college required - connect freely by area',
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bio / About (Optional)
              Text('ABOUT YOU / BIO (OPTIONAL)',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLength: 160,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Exploring cafes, tech enthusiast, love music...',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dating Intent
              Text('WHAT ARE YOU LOOKING FOR?',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ..._intentOptions.map((opt) {
                final isSelected = _selectedIntent == opt['key'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedIntent = opt['key']!),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(opt['title']!,
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(opt['desc']!,
                                    style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
              // Submit
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _onCompleteSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Next: Choose Search Area & Place ➔',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String key, String label) {
    final isSelected = _selectedGender == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = key),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceLight),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
