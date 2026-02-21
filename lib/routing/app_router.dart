import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/authentication_repository.dart';
import '../ui/auth/widgets/onboarding_screen.dart';
import '../ui/auth/widgets/phone_login_screen.dart';
import '../ui/camera/widgets/camera_screen.dart';
import '../ui/check_in/widgets/check_in_screen.dart';
import '../ui/core/widgets/app_shell.dart';
import '../ui/groups/widgets/create_group_screen.dart';
import '../ui/groups/widgets/group_detail_screen.dart';
import '../ui/groups/widgets/groups_screen.dart';
import '../ui/groups/widgets/join_group_screen.dart';
import '../ui/home/widgets/feed_screen.dart';
import '../ui/profile/widgets/edit_profile_screen.dart';
import '../ui/profile/widgets/profile_screen.dart';
import '../ui/stats/widgets/stats_screen.dart';
import 'routes.dart';

/// The application router configuration.
class AppRouter {
  AppRouter({required AuthenticationRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  late final GoRouter router = GoRouter(
    routes: _routes,
    initialLocation: Routes.feed,
    redirect: _redirect,
    refreshListenable: GoRouterRefreshStream(_authenticationRepository.user),
  );

  List<RouteBase> get _routes => [
    // Auth routes (outside shell — no bottom nav)
    GoRoute(
      path: Routes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: Routes.login,
      name: 'login',
      builder: (context, state) => const PhoneLoginScreen(),
    ),

    // Camera route (outside shell — full-screen, no bottom nav)
    GoRoute(
      path: Routes.camera,
      name: 'camera',
      builder: (context, state) => const CameraScreen(),
    ),

    // Check-in route (outside shell — full-screen, no bottom nav)
    GoRoute(
      path: Routes.checkIn,
      name: 'checkIn',
      redirect: (context, state) {
        if (state.uri.queryParameters['photoPath'] == null) {
          return Routes.feed;
        }
        return null;
      },
      builder: (context, state) {
        final photoPath = Uri.decodeComponent(
          state.uri.queryParameters['photoPath']!,
        );
        final groupId = state.uri.queryParameters['groupId'];
        return CheckInScreen(photoPath: photoPath, groupId: groupId);
      },
    ),

    // Main shell with bottom navigation (4 branches)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Feed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.feed,
              name: 'feed',
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),

        // Branch 1: Groups
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.groups,
              name: 'groups',
              builder: (context, state) => const GroupsScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createGroup',
                  builder: (context, state) => const CreateGroupScreen(),
                ),
                GoRoute(
                  path: 'join',
                  name: 'joinGroup',
                  builder: (context, state) => const JoinGroupScreen(),
                ),
                GoRoute(
                  path: Routes.groupDetail,
                  name: 'groupDetail',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    return GroupDetailScreen(groupId: groupId);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 2: Stats
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.stats,
              name: 'stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),

        // Branch 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile,
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'editProfile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  String? _redirect(BuildContext context, GoRouterState state) {
    final user = _authenticationRepository.currentUser;
    final isAuthenticated = user.isNotEmpty;
    final isLoggingIn = state.matchedLocation == Routes.login;
    final isOnboarding = state.matchedLocation == Routes.onboarding;

    // If not authenticated and trying to access a secure page
    if (!isAuthenticated && !isLoggingIn && !isOnboarding) {
      return Routes.onboarding;
    }

    // If authenticated and trying to access auth pages
    if (isAuthenticated && (isLoggingIn || isOnboarding)) {
      return Routes.feed;
    }

    return null;
  }
}

/// A listenable that notifies listeners when a stream emits a new value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
