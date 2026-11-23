import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../models/prompt_answer.dart';
import '../models/user.dart';
import '../providers/connection_provider.dart';

class SendConnectionModal extends ConsumerStatefulWidget {
  final PromptAnswer answer;

  const SendConnectionModal({super.key, required this.answer});

  static Future<void> show(BuildContext context, PromptAnswer answer) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SendConnectionModal(answer: answer),
    );
  }

  @override
  ConsumerState<SendConnectionModal> createState() => _SendConnectionModalState();
}

class _SendConnectionModalState extends ConsumerState<SendConnectionModal> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSend() async {
    final note = _noteController.text.trim();
    final targetUser = widget.answer.user;
    if (targetUser == null) return;

    final ok = await ref.read(connectionActionProvider.notifier).sendRequest(
      targetUserId: targetUser.id,
      contextType: 'PROMPT_ANSWER',
      contextId: widget.answer.id,
      contextSnippet: widget.answer.answerText,
      initialNote: note.isNotEmpty ? note : null,
    );

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text("✨ Connection request sent to ${targetUser.fullName}!"),
        ),
      );
    } else if (mounted) {
      final err = ref.read(connectionActionProvider).error?.toString() ?? 'Could not send request';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.answer.user;
    final college = user?.college;
    final actionState = ref.watch(connectionActionProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect with ${user?.fullName ?? "Student"}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      college?.name ?? 'Greater Noida Campus',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.campusLietGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Quoted Moment Snippet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPLYING TO THEIR MOMENT:',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${widget.answer.answerText}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Opening Note Input
          Text(
            'ADD A PERSONAL OPENING NOTE (OPTIONAL)',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _noteController,
              maxLength: 140,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Say something real, not just "hey"... (max 140 chars)',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Action Button
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: actionState.isLoading ? null : _onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: actionState.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Send Connection Request 💌',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class SendUserConnectionModal extends ConsumerStatefulWidget {
  final User user;

  const SendUserConnectionModal({super.key, required this.user});

  static Future<void> show(BuildContext context, User user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SendUserConnectionModal(user: user),
    );
  }

  @override
  ConsumerState<SendUserConnectionModal> createState() => _SendUserConnectionModalState();
}

class _SendUserConnectionModalState extends ConsumerState<SendUserConnectionModal> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSend() async {
    final note = _noteController.text.trim();
    final ok = await ref.read(connectionActionProvider.notifier).sendRequest(
      targetUserId: widget.user.id,
      contextType: 'AREA_MATCH',
      contextSnippet: 'Matched in ${widget.user.preferredArea}',
      initialNote: note.isNotEmpty ? note : null,
    );

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text("✨ Connection request sent to ${widget.user.fullName}!"),
        ),
      );
    } else if (mounted) {
      final err = ref.read(connectionActionProvider).error?.toString() ?? 'Could not send request';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(err)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final college = user.college;
    final actionState = ref.watch(connectionActionProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Connect with ${user.fullName}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (user.isStudentVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      college?.name ?? 'Greater Noida Campus',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.campusLietGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Matched in ${user.preferredArea}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ADD A PERSONAL OPENING NOTE (OPTIONAL)',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _noteController,
              maxLength: 140,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Say something real, e.g. "Hey, saw you are also in KP2!"',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: actionState.isLoading ? null : _onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: actionState.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Send Connection Request 💌',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
