import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';

class SearchSpecificationScreen extends ConsumerStatefulWidget {
  const SearchSpecificationScreen({super.key});

  @override
  ConsumerState<SearchSpecificationScreen> createState() => _SearchSpecificationScreenState();
}

class _SearchSpecificationScreenState extends ConsumerState<SearchSpecificationScreen> {
  String _selectedArea = 'Knowledge Park II';
  String _lookingForGender = 'ALL';
  String _targetIntent = 'ALL';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _areas = [
    {
      'name': 'Knowledge Park II',
      'icon': '🏛️',
      'highlight': 'LIET & GL Bajaj Hub',
      'desc': 'Hostels, college canteens & Nescafe spots',
      'matches': '40+ students',
    },
    {
      'name': 'Pari Chowk',
      'icon': '🚇',
      'highlight': 'Metro & Central Hub',
      'desc': 'Late-night chai, roll points & central transit',
      'matches': '25 students',
    },
    {
      'name': 'Knowledge Park III',
      'icon': '🎓',
      'highlight': 'Sharda Campus Hub',
      'desc': 'International students & campus food street',
      'matches': '20 students',
    },
    {
      'name': 'Tech Zone II',
      'icon': '💻',
      'highlight': 'Bennett Tech Hub',
      'desc': 'Hackathon builders & green campus lawns',
      'matches': '20 students',
    },
    {
      'name': 'Sector 62 Noida',
      'icon': '🏙️',
      'highlight': 'JIIT & Noida IT Corridor',
      'desc': 'Tech students & Sector 62 food joints',
      'matches': '15 students',
    },
    {
      'name': 'Sector 125 Noida',
      'icon': '✨',
      'highlight': 'Amity Hub',
      'desc': 'Sector 104 cafes & student chillouts',
      'matches': '15 students',
    },
    {
      'name': 'Alpha 1 & Jagat Farm',
      'icon': '🍜',
      'highlight': 'Student Market & Food',
      'desc': 'Maggi spots, study libraries & market bites',
      'matches': '10 students',
    },
    {
      'name': 'Yamuna Expressway',
      'icon': '🛣️',
      'highlight': 'Galgotias & GBU Zone',
      'desc': 'Highway cafes & sprawling campuses',
      'matches': '10 students',
    },
  ];

  void _onConfirm() async {
    setState(() => _isSaving = true);
    // Update local provider so match feed re-fetches immediately
    ref.read(selectedAreaProvider.notifier).state = _selectedArea;
    // Persist to backend database
    await ref.read(authProvider.notifier).updatePreferredArea(_selectedArea);
    setState(() => _isSaving = false);

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: Text(
              'Skip',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Area & Place Matching',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Where are you hanging out?',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose your preferred area. When another student chooses this same place, you will match and see each other!',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Area Selector
              Text(
                'SELECT PLACE / CAMPUS AREA',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              ..._areas.map((area) {
                final isSelected = _selectedArea == area['name'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedArea = area['name']);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.18) : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                          width: isSelected ? 1.6 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.25)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(area['icon'], style: const TextStyle(fontSize: 20)),
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
                                        area['name'],
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        area['matches'],
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.campusLietGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  area['highlight'],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Match specifications: Gender & Intent
              Text(
                'LOOKING TO CONNECT WITH',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildFilterChip('ALL', 'Everyone', _lookingForGender, (val) {
                    setState(() => _lookingForGender = val);
                  }),
                  const SizedBox(width: 10),
                  _buildFilterChip('FEMALE', 'Women', _lookingForGender, (val) {
                    setState(() => _lookingForGender = val);
                  }),
                  const SizedBox(width: 10),
                  _buildFilterChip('MALE', 'Men', _lookingForGender, (val) {
                    setState(() => _lookingForGender = val);
                  }),
                ],
              ),

              const SizedBox(height: 28),

              // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Show Matches in $_selectedArea ➔',
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

  Widget _buildFilterChip(
      String key, String label, String currentVal, Function(String) onSelect) {
    final isSelected = currentVal == key;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(key),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            ),
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
