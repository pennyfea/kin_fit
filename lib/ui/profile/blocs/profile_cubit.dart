import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../utils/logger.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required UserRepository userRepository,
    required CheckInRepository checkInRepository,
    required String userId,
  })  : _userRepository = userRepository,
        _checkInRepository = checkInRepository,
        _userId = userId,
        super(const ProfileState());

  static const _log = Logger('ProfileCubit');

  final UserRepository _userRepository;
  final CheckInRepository _checkInRepository;
  final String _userId;
  StreamSubscription<dynamic>? _userSubscription;

  void load() {
    _userSubscription?.cancel();
    _userSubscription = _userRepository.watchUser(_userId).listen(
      (user) {
        if (user != null) {
          emit(state.copyWith(
            user: user,
            status: ProfileStatus.loaded,
          ));
          _refreshStreak(user.groupIds);
        } else {
          emit(state.copyWith(status: ProfileStatus.failure));
        }
      },
      onError: (Object e) {
        _log.error('Failed to load profile: $e');
        emit(state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Failed to load profile.',
        ));
      },
    );
  }

  Future<void> _refreshStreak(List<String> groupIds) async {
    try {
      final streak = await _checkInRepository.calculateStreak(
        _userId,
        groupIds,
      );
      emit(state.copyWith(calculatedStreak: streak));
    } catch (e) {
      _log.error('Failed to calculate streak: $e');
    }
  }

  Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _userRepository.updateUser(_userId, {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
      });
    } catch (e) {
      _log.error('Failed to update name: $e');
      emit(state.copyWith(
        errorMessage: 'Failed to update profile.',
      ));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
