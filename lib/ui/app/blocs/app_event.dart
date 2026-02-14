import 'package:equatable/equatable.dart';

import '../../../domain/models/user.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to the auth state stream.
final class AppUserSubscriptionRequested extends AppEvent {
  const AppUserSubscriptionRequested();
}

/// The auth state changed.
final class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);
  final User user;

  @override
  List<Object?> get props => [user];
}

/// The user requested to log out.
final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}
