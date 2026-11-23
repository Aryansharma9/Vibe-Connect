import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../providers/moderation_provider.dart';

class ReportUserDialog extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const ReportUserDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  static Future<void> show(BuildContext context, {required String userId, required String userName}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ReportUserDialog(userId: userId, userName: userName),
    );
  }

  @override
  ConsumerState<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends ConsumerState<ReportUserDialog> {
  String _selectedReason = 'Harassment or bullying';
  final _detailsController = TextEditingController();
  bool _blockUser = true;
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Harassment or bullying',
    'Scam / Commercial promo',
    'Fake student / Impersonation',
    'Inappropriate messages',
    'Offensive language',
    'Other safety concern',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final details = _detailsController.text.trim();
    final ok = await ref.read(moderationProvider.notifier).reportUser(
      widget.userId,
      _selectedReason,
      details.isNotEmpty ? details : null,
    );

    if (_blockUser && ok) {
      await ref.read(moderationProvider.notifier).blockUser(widget.userId);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface,
          content: Row(
            children: [
              const Icon(Icons.shield, color: AppColors.successGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _blockUser
                      ? 'Report filed and ${widget.userName} has been blocked.'
                      : 'Report filed. Campus safety team will review this.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.errorRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety & Report',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Reporting @${widget.userName}',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'WHY ARE YOU REPORTING THIS STUDENT?',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              ..._reasons.map((reason) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppColors.primary,
                    title: Text(
                      reason,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                    ),
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedReason = val);
                    },
                  )),

              const SizedBox(height: 12),
              TextField(
                controller: _detailsController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.surfaceLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Block toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block, color: AppColors.errorRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Block this student immediately',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: _blockUser,
                      activeColor: AppColors.errorRed,
                      onChanged: (val) => setState(() => _blockUser = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            'Submit Report',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
