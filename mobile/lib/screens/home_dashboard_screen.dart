import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../models/prompt_answer.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/prompt_provider.dart';
import '../providers/connection_provider.dart';
import '../widgets/send_connection_dialog.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final _answerController = TextEditingController();
  bool _isEditing = false;
  int _currentTab = 0; // 0 = Area Matches, 1 = Daily Moments
  String _selectedGenderFilter = 'ALL';
  String? _selectedMatchIntent;

  static const List<Map<String, String>> _allAreas = [
    {'name': 'Knowledge Park II', 'icon': '🏛️', 'hub': 'LIET & GL Bajaj Hub', 'count': '40'},
    {'name': 'Pari Chowk', 'icon': '🚇', 'hub': 'Metro & Central Hub', 'count': '25'},
    {'name': 'Knowledge Park III', 'icon': '🎓', 'hub': 'Sharda Campus Hub', 'count': '20'},
    {'name': 'Tech Zone II', 'icon': '💻', 'hub': 'Bennett Tech Hub', 'count': '20'},
    {'name': 'Sector 62 Noida', 'icon': '🏙️', 'hub': 'JIIT & IT Corridor', 'count': '15'},
    {'name': 'Sector 125 Noida', 'icon': '✨', 'hub': 'Amity Hub', 'count': '15'},
    {'name': 'Alpha 1 & Jagat Farm', 'icon': '🍜', 'hub': 'Student Market & Food', 'count': '10'},
    {'name': 'Yamuna Expressway', 'icon': '🛣️', 'hub': 'Galgotias & GBU Zone', 'count': '10'},
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  int _calculateAge(String dob) {
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 21;
    }
  }

  void _onSubmitAnswer(String questionId) async {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a quick answer to unlock the feed!")),
      );
      return;
    }

    final ok = await ref.read(promptActionProvider.notifier).submitAnswer(questionId, text);
    if (ok && mounted) {
      setState(() => _isEditing = false);
      _answerController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successGreen,
          content: Text("🎉 Moment shared! Campus feed unlocked!"),
        ),
      );
    }
  }

  void _showAreaPickerModal(String currentArea) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Place / Area',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Match with students who selected the same area',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: _allAreas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _allAreas[index];
                    final isSelected = item['name'] == currentArea;
                    return InkWell(
                      onTap: () async {
                        final areaName = item['name']!;
                        ref.read(selectedAreaProvider.notifier).state = areaName;
                        await ref.read(authProvider.notifier).updatePreferredArea(areaName);
                        if (mounted) Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(item['icon'] ?? '📍', style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    item['hub']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${item['count']} students',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of VibeConnect?',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Log Out', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final currentArea = ref.watch(selectedAreaProvider);
    final matchesAsync = ref.watch(areaMatchesProvider);

    final promptAsync = ref.watch(todayPromptProvider);
    final myCampusOnly = ref.watch(myCampusOnlyFilterProvider);
    final selectedIntent = ref.watch(intentFilterProvider);

    final matchCount = matchesAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(areaMatchesProvider);
            ref.invalidate(todayPromptProvider);
          },
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            slivers: [
              // Top App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VibeConnect',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          InkWell(
                            onTap: () => _showAreaPickerModal(currentArea),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.primary, size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  currentArea,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white60, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Inbox button with badge
                          Consumer(
                            builder: (context, ref, _) {
                              final countAsync = ref.watch(pendingCountProvider);
                              final count = countAsync.value ?? 0;
                              return Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 24),
                                    onPressed: () => context.push('/inbox'),
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: user?.isStudentVerified == true
                                  ? AppColors.verifiedBlue.withOpacity(0.15)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: user?.isStudentVerified == true
                                    ? AppColors.verifiedBlue
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  user?.isStudentVerified == true ? Icons.verified : Icons.person_pin_circle,
                                  color: user?.isStudentVerified == true
                                      ? AppColors.verifiedBlue
                                      : AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  user?.college?.shortCode ?? (user?.isStudentVerified == true ? 'Verified' : 'Member'),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Log Out',
                            onPressed: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Segmented Tab Switcher (Area Matches vs Daily Moments)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _currentTab = 0),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _currentTab == 0 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.people_alt_outlined, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '📍 Area Matches',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: _currentTab == 0 ? FontWeight.w800 : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (matchCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: _currentTab == 0 ? Colors.white.withOpacity(0.25) : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$matchCount',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _currentTab = 1),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _currentTab == 1 ? AppColors.secondary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.flash_on, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '⚡ Daily Moments',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: _currentTab == 1 ? FontWeight.w800 : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // TAB 0: Area Matches Feed
              if (_currentTab == 0) ...[
                // Area Match Hero Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.18),
                            AppColors.secondary.withOpacity(0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('📍', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        currentArea,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Matched with students who also chose this area',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAreaPickerModal(currentArea),
                            icon: const Icon(Icons.tune, size: 14),
                            label: const Text('Change Area'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Intent & Gender Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Genders', 'ALL', _selectedGenderFilter, (val) {
                            setState(() => _selectedGenderFilter = val ?? 'ALL');
                          }),
                          _buildFilterChip('Women', 'FEMALE', _selectedGenderFilter, (val) {
                            setState(() => _selectedGenderFilter = val ?? 'ALL');
                          }),
                          _buildFilterChip('Men', 'MALE', _selectedGenderFilter, (val) {
                            setState(() => _selectedGenderFilter = val ?? 'ALL');
                          }),
                          const SizedBox(width: 12),
                          _buildFilterChip('All Vibes', null, _selectedMatchIntent, (val) {
                            setState(() => _selectedMatchIntent = val);
                          }),
                          _buildFilterChip('Go With Flow', 'GO_WITH_THE_FLOW', _selectedMatchIntent, (val) {
                            setState(() => _selectedMatchIntent = val);
                          }),
                          _buildFilterChip('Long-Term', 'LONG_TERM', _selectedMatchIntent, (val) {
                            setState(() => _selectedMatchIntent = val);
                          }),
                          _buildFilterChip('Study Buddy', 'STUDY_BUDDY', _selectedMatchIntent, (val) {
                            setState(() => _selectedMatchIntent = val);
                          }),
                          _buildFilterChip('Casual', 'CASUAL', _selectedMatchIntent, (val) {
                            setState(() => _selectedMatchIntent = val);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                // Matched Students List
                _buildAreaMatchesList(matchesAsync),
              ],

              // TAB 1: Daily Moments Feed
              if (_currentTab == 1) ...[
                // The Daily Prompt Hero Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: promptAsync.when(
                      data: (prompt) {
                        if (prompt == null) {
                          return const SizedBox.shrink();
                        }
                        return _buildDailyPromptCard(prompt);
                      },
                      loading: () => Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Feed Filter Bar (Only visible once today's prompt is answered)
                if (promptAsync.value?.hasAnswered == true) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campus Switcher
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceLight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => ref.read(myCampusOnlyFilterProvider.notifier).state = true,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: myCampusOnly ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '📍 Nearby In Area',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: myCampusOnly ? FontWeight.w700 : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => ref.read(myCampusOnlyFilterProvider.notifier).state = false,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !myCampusOnly ? AppColors.secondary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '🌐 All Greater Noida',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: !myCampusOnly ? FontWeight.w700 : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Intent Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildIntentChip('All Vibes', null, selectedIntent),
                                _buildIntentChip('Go With Flow', 'GO_WITH_THE_FLOW', selectedIntent),
                                _buildIntentChip('Long-Term', 'LONG_TERM', selectedIntent),
                                _buildIntentChip('Study Buddy', 'STUDY_BUDDY', selectedIntent),
                                _buildIntentChip('Casual', 'CASUAL', selectedIntent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Peer Answers Feed List
                  _buildAnswersFeedList(promptAsync.value!.id),
                ] else ...[
                  // Locked Notice
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.lock_clock, color: AppColors.textMuted, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              "Campus Moments Feed is Locked",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Answer today's moment above to see what other students from LIET and Greater Noida said!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, String? currentSelected, ValueChanged<String?> onChanged) {
    final isSelected = currentSelected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onChanged(value),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.25),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildAreaMatchesList(AsyncValue<List<User>> matchesAsync) {
    return matchesAsync.when(
      data: (users) {
        var filtered = users;
        if (_selectedGenderFilter != 'ALL') {
          filtered = filtered.where((u) => u.gender.toUpperCase() == _selectedGenderFilter).toList();
        }
        if (_selectedMatchIntent != null) {
          filtered = filtered.where((u) => u.datingIntent == _selectedMatchIntent).toList();
        }

        if (filtered.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.search_off, color: AppColors.textMuted, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No students match the current filters in this area.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try resetting gender or intent filters, or switch to another nearby place!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final matchUser = filtered[index];
                return _buildUserMatchCard(matchUser);
              },
              childCount: filtered.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text('Error loading matches: $e', style: const TextStyle(color: Colors.redAccent)),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMatchCard(User matchUser) {
    final age = _calculateAge(matchUser.dob);
    final college = matchUser.college;
    final isLiet = college?.isLiet == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLiet ? AppColors.campusLietGold.withOpacity(0.4) : AppColors.surfaceLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Age, Verification & Intent Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: matchUser.gender.toUpperCase() == 'FEMALE' ? AppColors.primary : AppColors.secondary,
                child: Text(
                  matchUser.fullName.isNotEmpty ? matchUser.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                            '${matchUser.fullName}, $age',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (matchUser.isStudentVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.school, color: AppColors.campusLietGold, size: 13),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            college?.name ?? 'Greater Noida Campus',
                            style: GoogleFonts.plusJakartaSans(
                              color: isLiet ? AppColors.campusLietGold : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isLiet ? FontWeight.w600 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Intent pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  matchUser.datingIntent.replaceAll('_', ' '),
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Area badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place, color: AppColors.primary, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      matchUser.preferredArea,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${matchUser.gender == 'FEMALE' ? 'Female' : 'Male'} Student',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bio Snippet
          if (matchUser.bio != null && matchUser.bio!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                matchUser.bio!,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Connect Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => SendUserConnectionModal.show(context, matchUser),
                icon: const Icon(Icons.favorite_outline, size: 16),
                label: Text(
                  'Connect with Note',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPromptCard(dynamic prompt) {
    final hasAnswered = prompt.hasAnswered == true;
    final actionState = ref.watch(promptActionProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '12:00 PM Daily Drop',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: AppColors.successGreen, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"${prompt.promptText}"',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          if (!hasAnswered || _isEditing) ...[
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _answerController,
                maxLength: 280,
                maxLines: 3,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Share your genuine moment... (max 280 chars)',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: actionState.isLoading ? null : () => _onSubmitAnswer(prompt.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: actionState.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        hasAnswered ? 'Update My Answer' : 'Answer to Unlock Campus Feed 🔓',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ),
          ] else ...[
            // Display User's own answer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prompt.myAnswer?.answerText ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                    onPressed: () {
                      _answerController.text = prompt.myAnswer?.answerText ?? '';
                      setState(() => _isEditing = true);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswersFeedList(String questionId) {
    final feedAsync = ref.watch(answersFeedProvider(questionId));

    return feedAsync.when(
      data: (answers) {
        if (answers.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No moments in this filter yet. Be the first to share!',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final answer = answers[index];
                return _buildAnswerCard(answer);
              },
              childCount: answers.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(child: Text('Error loading moments: $e', style: const TextStyle(color: Colors.redAccent))),
        ),
      ),
    );
  }

  Widget _buildAnswerCard(PromptAnswer answer) {
    final user = answer.user;
    final college = user?.college;
    final isLiet = college?.isLiet == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLiet ? AppColors.campusLietGold.withOpacity(0.4) : AppColors.surfaceLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isLiet ? AppColors.primary : AppColors.secondary,
                child: Text(
                  (user?.fullName.isNotEmpty == true) ? user!.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.fullName ?? 'Student',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (user?.isStudentVerified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.verifiedBlue, size: 14),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      college?.name ?? 'Greater Noida',
                      style: GoogleFonts.plusJakartaSans(
                        color: isLiet ? AppColors.campusLietGold : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isLiet ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Intent pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user?.datingIntent.replaceAll('_', ' ') ?? 'VIBE',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Answer Quote
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              answer.answerText,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Connect CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => SendConnectionModal.show(context, answer),
                icon: const Icon(Icons.favorite_border, color: AppColors.primary, size: 18),
                label: Text(
                  'Connect with Note',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntentChip(String label, String? key, String? selected) {
    final isSelected = selected == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref.read(intentFilterProvider.notifier).state = isSelected ? null : key;
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.25),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
