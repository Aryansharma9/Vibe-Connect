import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../models/space.dart';
import '../models/space_post.dart';
import '../providers/space_provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/report_user_dialog.dart';

class SpacesScreen extends ConsumerStatefulWidget {
  const SpacesScreen({super.key});

  @override
  ConsumerState<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends ConsumerState<SpacesScreen> {
  Space? _selectedSpace;

  @override
  Widget build(BuildContext context) {
    if (_selectedSpace != null) {
      return _SpaceDetailView(
        space: _selectedSpace!,
        onBack: () => setState(() => _selectedSpace = null),
      );
    }

    final spacesAsync = ref.watch(spacesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(spacesProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus Spaces',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect over shared interests across LIET & Gr. Noida hubs',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              spacesAsync.when(
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No campus spaces found yet',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final space = spaces[index];
                          return _buildSpaceCard(space);
                        },
                        childCount: spaces.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Text('Failed to load spaces: $e', style: const TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceCard(Space space) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedSpace = space),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.3), AppColors.secondary.withOpacity(0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(space.icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              space.name,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${space.memberCount} vibing',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        space.description,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceDetailView extends ConsumerStatefulWidget {
  final Space space;
  final VoidCallback onBack;

  const _SpaceDetailView({required this.space, required this.onBack});

  @override
  ConsumerState<_SpaceDetailView> createState() => _SpaceDetailViewState();
}

class _SpaceDetailViewState extends ConsumerState<_SpaceDetailView> {
  final _postController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _onPublishPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    final ok = await ref.read(spaceActionProvider.notifier).createPost(widget.space.id, text);
    if (mounted) {
      setState(() => _isPosting = false);
      if (ok) {
        _postController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Text('🎉 Post shared with the space!'),
          ),
        );
      }
    }
  }

  void _openConnectModal(SpacePost post) {
    final targetUser = post.user;
    if (targetUser == null) return;

    final noteController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    targetUser.fullName.isNotEmpty ? targetUser.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect with ${targetUser.fullName}',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        targetUser.college?.name ?? 'Campus peer',
                        style: GoogleFonts.plusJakartaSans(color: AppColors.campusLietGold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${post.content}"',
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLength: 140,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add a personal note to break the ice...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final note = noteController.text.trim();
                  final ok = await ref.read(connectionActionProvider.notifier).sendRequest(
                    targetUserId: targetUser.id,
                    contextType: 'SPACE_POST',
                    contextId: post.id,
                    contextSnippet: post.content,
                    initialNote: note.isNotEmpty ? note : null,
                  );
                  if (ok && ctx.mounted) {
                    Navigator.pop(ctx);
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.successGreen,
                        content: Text('✨ Connection note sent to ${targetUser.fullName}!'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Send Connection Note',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(spacePostsProvider(widget.space.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            Text(widget.space.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.space.name,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Space Info Banner & Post Composer
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.space.description,
                    style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _postController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Share a thought with ${widget.space.name}...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.surfaceLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isPosting ? null : _onPublishPost,
                        icon: _isPosting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                            : const Icon(Icons.send_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Posts Feed
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(spacePostsProvider(widget.space.id)),
                color: AppColors.primary,
                child: postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.space.icon, style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'Be the first to post here!',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Share a thought or start a campus conversation.',
                              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostCard(post);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (e, _) => Center(child: Text('Error loading posts: $e', style: const TextStyle(color: Colors.redAccent))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(SpacePost post) {
    final user = post.user;
    final college = user?.college;
    final isLiet = college?.isLiet == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLiet ? AppColors.campusLietGold.withOpacity(0.35) : AppColors.surfaceLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isLiet ? AppColors.primary : AppColors.secondary,
                child: Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?.fullName ?? 'Student',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        if (user?.isStudentVerified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 14),
                        ],
                      ],
                    ),
                    Text(
                      college?.name ?? 'Campus peer',
                      style: GoogleFonts.plusJakartaSans(
                        color: isLiet ? AppColors.campusLietGold : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isLiet ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('h:mm a').format(post.createdAt),
                style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 11),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18),
                color: AppColors.surface,
                onSelected: (val) {
                  if (val == 'report' && user != null) {
                    ReportUserDialog.show(context, userId: user.id, userName: user.fullName);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.errorRed, size: 16),
                        SizedBox(width: 8),
                        Text('Report & Block', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _openConnectModal(post),
                icon: const Icon(Icons.favorite_border, color: AppColors.primary, size: 16),
                label: Text(
                  'Connect with Note',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
