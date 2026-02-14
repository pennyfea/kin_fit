import 'package:equatable/equatable.dart';

import '../../../domain/models/user.dart';

enum ProfileStatus { loading, loaded, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.user = User.empty,
    this.status = ProfileStatus.loading,
    this.calculatedStreak = 0,
    this.errorMessage,
  });

  final User user;
  final ProfileStatus status;
  final int calculatedStreak;
  final String? errorMessage;

  ProfileState copyWith({
    User? user,
    ProfileStatus? status,
    int? calculatedStreak,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      calculatedStreak: calculatedStreak ?? this.calculatedStreak,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [user, status, calculatedStreak, errorMessage];
}
