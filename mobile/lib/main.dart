import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'screens/welcome_screen.dart';
import 'screens/phone_auth_screen.dart';
import 'screens/college_picker_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/campus_verify_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/connections_inbox_screen.dart';
import 'screens/chat_room_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VibeConnectApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/college-picker',
      builder: (context, state) => const CollegePickerScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/campus-verify',
      builder: (context, state) => const CampusVerifyScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    GoRoute(
      path: '/inbox',
      builder: (context, state) => const ConnectionsInboxScreen(),
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final convId = state.pathParameters['conversationId'] ?? '';
        final name = state.uri.queryParameters['name'] ?? 'Student';
        final college = state.uri.queryParameters['college'] ?? 'Campus';
        final verified = state.uri.queryParameters['verified'] == 'true';
        return ChatRoomScreen(
          conversationId: convId,
          peerName: name,
          peerCollege: college,
          isVerified: verified,
        );
      },
    ),
  ],
);

class VibeConnectApp extends StatelessWidget {
  const VibeConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VibeConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: mediaQuery.textScaler.clamp(
                  minScaleFactor: 0.85,
                  maxScaleFactor: 1.25,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      routerConfig: _router,
    );
  }
}
