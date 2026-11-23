import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../providers/college_provider.dart';

class CampusVerifyScreen extends ConsumerStatefulWidget {
  const CampusVerifyScreen({super.key});

  @override
  ConsumerState<CampusVerifyScreen> createState() => _CampusVerifyScreenState();
}

class _CampusVerifyScreenState extends ConsumerState<CampusVerifyScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  String? _devCode;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final college = ref.read(selectedCollegeProvider);
    if (college?.emailDomain != null) {
      _emailController.text = '@${college!.emailDomain}';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onRequestCode() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid student email')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final code = await ref.read(authProvider.notifier).sendCollegeEmailOtp(email);
    setState(() {
      _isVerifying = false;
      if (code != null) {
        _otpSent = true;
        _devCode = code;
      }
    });
  }

  void _onVerifyCode() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    setState(() => _isVerifying = true);
    final ok = await ref.read(authProvider.notifier).verifyCollegeEmailOtp(email, otp);
    setState(() => _isVerifying = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Congratulations! Student Badge Activated 🎓')),
      );
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final college = ref.watch(selectedCollegeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: Text(
              'Skip for now',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),

              Text(
                'Get your Verified Student Badge',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Profiles with verified campus emails get 4x more replies and zero scam suspicion.',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              if (!_otpSent) ...[
                Text(
                  'COLLEGE EMAIL (@${college?.emailDomain ?? "college.edu.in"})',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.campusLietGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'e.g. aryan@lloydcollege.in',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'ENTER 6-DIGIT CODE',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 6),
                      border: InputBorder.none,
                      suffixText: _devCode != null ? 'Dev: $_devCode' : null,
                      suffixStyle: const TextStyle(color: AppColors.campusLietGold, fontSize: 12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Spacer(),

              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : (!_otpSent ? _onRequestCode : _onVerifyCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          !_otpSent ? 'Send Verification Code' : 'Verify & Finish',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
