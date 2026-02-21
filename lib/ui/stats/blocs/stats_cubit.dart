import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../utils/logger.dart';
import 'stats_state.dart';

/// Cubit that manages personal stats — streaks, group count, weekly activity.
class StatsCubit extends Cubit<StatsState> {
  StatsCubit({
    required UserRepository userRepository,
    required CheckInRepository checkInRepository,
    required String userId,
  })  : _userRepository = userRepository,
        _checkInRepository = checkInRepository,
        _userId = userId,
        super(const StatsState());

  static const _log = Logger('StatsCubit');

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
            status: StatsStatus.loaded,
            longestStreak: user.longestStreak,
            groupCount: user.groupIds.length,
            memberSince: user.createdAt,
          ));
          _refreshDetailedStats(user.groupIds);
        }
      },
      onError: (Object e) {
        _log.error('Failed to load stats: $e');
        emit(state.copyWith(
          status: StatsStatus.failure,
          errorMessage: 'Failed to load stats.',
        ));
      },
    );
  }

  Future<void> _refreshDetailedStats(List<String> groupIds) async {
    try {
      final streak = await _checkInRepository.calculateStreak(
        _userId,
        groupIds,
      );

      // Gather all check-in dates for total count + weekly activity
      var totalCheckIns = 0;
      final allDates = <DateTime>[];

      for (final groupId in groupIds) {
        final checkIns = await _checkInRepository.getUserCheckIns(
          groupId,
          _userId,
          limit: 90,
        );
        totalCheckIns += checkIns.length;
        for (final checkIn in checkIns) {
          if (checkIn.createdAt != null) {
            allDates.add(checkIn.createdAt!);
          }
        }
      }

      // Compute this week's activity (Mon=0 ... Sun=6)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monday = today.subtract(Duration(days: today.weekday - 1));

      final weekly = List.filled(7, false);
      for (final date in allDates) {
        final d = DateTime(date.year, date.month, date.day);
        final diff = d.difference(monday).inDays;
        if (diff >= 0 && diff < 7) {
          weekly[diff] = true;
        }
      }

      if (!isClosed) {
        emit(state.copyWith(
          currentStreak: streak,
          totalCheckIns: totalCheckIns,
          weeklyActivity: weekly,
        ));
      }
    } catch (e) {
      _log.error('Failed to calculate detailed stats: $e');
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
