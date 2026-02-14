import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/authentication_repository.dart';
import '../data/repositories/check_in_repository.dart';
import '../data/repositories/group_repository.dart';
import '../data/repositories/user_repository.dart';
import '../ui/app/blocs/app_bloc.dart';
import '../ui/auth/widgets/phone_login_screen.dart';
import '../ui/check_in/widgets/check_in_screen.dart';
import '../ui/groups/widgets/create_group_screen.dart';
import '../ui/groups/widgets/group_detail_screen.dart';
import '../ui/groups/widgets/groups_screen.dart';
import '../ui/groups/widgets/join_group_screen.dart';
import '../ui/home/blocs/feed_cubit.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/profile/widgets/edit_profile_screen.dart';
import '../ui/profile/widgets/profile_screen.dart';
import 'routes.dart';

/// The application router configuration.
class AppRouter {
  AppRouter({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  late final GoRouter router = GoRouter(
    routes: _routes,
    initialLocation: Routes.home,
    redirect: _redirect,
    refreshListenable: GoRouterRefreshStream(
      _authenticationRepository.user,
    ),
  );

  List<RouteBase> get _routes => [
        GoRoute(
          path: Routes.login,
          name: 'login',
          builder: (context, state) => const PhoneLoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) {
            final userId = context.read<AppBloc>().state.user.id;
            return BlocProvider(
              create: (context) => FeedCubit(
                groupRepository: context.read<GroupRepository>(),
                checkInRepository: context.read<CheckInRepository>(),
                userRepository: context.read<UserRepository>(),
                userId: userId,
              )..load(),
              child: const HomeScreen(),
            );
          },
        ),
        GoRoute(
          path: Routes.checkIn,
          name: 'checkIn',
          redirect: (context, state) {
            if (state.uri.queryParameters['photoPath'] == null) {
              return Routes.home;
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
      ];

  String? _redirect(BuildContext context, GoRouterState state) {
    final user = _authenticationRepository.currentUser;
    final isAuthenticated = user.isNotEmpty;
    final isLoggingIn = state.matchedLocation == Routes.login;

    if (!isAuthenticated && !isLoggingIn) {
      return Routes.login;
    }

    if (isAuthenticated && isLoggingIn) {
      return Routes.home;
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
