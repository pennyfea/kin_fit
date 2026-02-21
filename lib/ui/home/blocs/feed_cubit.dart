import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/group.dart';
import '../../../domain/models/user.dart';
import '../../../utils/logger.dart';
import 'feed_state.dart';

/// Cubit that manages the home feed — today's check-ins across all groups.
///
/// Tracks whether the current user has checked in today (gates feed access),
/// and collects all group member IDs for the wall of shame.
class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    required GroupRepository groupRepository,
    required CheckInRepository checkInRepository,
    required UserRepository userRepository,
  })  : _groupRepository = groupRepository,
        _checkInRepository = checkInRepository,
        _userRepository = userRepository,
        super(const FeedState());

  static const _log = Logger('FeedCubit');

  final GroupRepository _groupRepository;
  final CheckInRepository _checkInRepository;
  final UserRepository _userRepository;
  String _userId = '';

  StreamSubscription<List<Group>>? _groupsSubscription;
  final Map<String, StreamSubscription<List<CheckIn>>> _checkInSubscriptions =
      {};
  final Map<String, List<CheckIn>> _checkInsByGroup = {};
  final Map<String, User> _usersCache = {};

  /// All unique member IDs across all groups.
  Set<String> _allMemberIds = {};

  /// Start watching the user's groups and their check-ins.
  void load(String userId) {
    _userId = userId;
    emit(state.copyWith(status: FeedStatus.loading));

    // Clear previous subscriptions
    _groupsSubscription?.cancel();
    for (final sub in _checkInSubscriptions.values) {
      sub.cancel();
    }
    _checkInSubscriptions.clear();
    _checkInsByGroup.clear();

    _groupsSubscription = _groupRepository.watchUserGroups(_userId).listen(
      _onGroupsChanged,
      onError: (Object error) {
        _log.error('Failed to watch groups: $error');
        emit(state.copyWith(
          status: FeedStatus.failure,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  void _onGroupsChanged(List<Group> groups) {
    // Collect all member IDs across all groups
    _allMemberIds = {};
    for (final group in groups) {
      _allMemberIds.addAll(group.memberIds);
    }

    // Fetch profiles for all members (not just those who checked in)
    _fetchMemberProfiles();

    final currentGroupIds = _checkInSubscriptions.keys.toSet();
    final newGroupIds = groups.map((g) => g.id).toSet();

    // Cancel subscriptions for groups we left
    for (final id in currentGroupIds.difference(newGroupIds)) {
      _checkInSubscriptions.remove(id)?.cancel();
      _checkInsByGroup.remove(id);
    }

    // Subscribe to new groups
    for (final id in newGroupIds.difference(currentGroupIds)) {
      _checkInSubscriptions[id] =
          _checkInRepository.watchTodayCheckIns(id).listen(
        (checkIns) {
          _checkInsByGroup[id] = checkIns;
          _emitMerged();
        },
        onError: (Object error) {
          _log.error('Failed to watch check-ins for group $id: $error');
        },
      );
    }

    if (groups.isEmpty) {
      emit(state.copyWith(
        status: FeedStatus.empty,
        hasCheckedIn: false,
        allMemberIds: _allMemberIds,
      ));
    }
  }

  Future<void> _fetchMemberProfiles() async {
    final unknownIds = _allMemberIds.difference(_usersCache.keys.toSet());
    for (final uid in unknownIds) {
      try {
        final user = await _userRepository.getUser(uid);
        if (user != null) {
          _usersCache[uid] = user;
        }
      } catch (e) {
        _log.error('Failed to fetch user $uid: $e');
      }
    }
  }

  Future<void> _emitMerged() async {
    final all = _checkInsByGroup.values.expand((list) => list).toList()
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime(0);
        final bTime = b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

    // Check if current user has posted today
    final hasCheckedIn = all.any((c) => c.userId == _userId);

    // Fetch profiles for any new check-in authors not yet cached
    final unknownUserIds =
        all.map((c) => c.userId).toSet().difference(_usersCache.keys.toSet());
    for (final uid in unknownUserIds) {
      try {
        final user = await _userRepository.getUser(uid);
        if (user != null) {
          _usersCache[uid] = user;
        }
      } catch (e) {
        _log.error('Failed to fetch user $uid: $e');
      }
    }

    if (all.isEmpty) {
      emit(state.copyWith(
        status: FeedStatus.empty,
        checkIns: const [],
        hasCheckedIn: hasCheckedIn,
        users: Map.unmodifiable(_usersCache),
        allMemberIds: _allMemberIds,
      ));
    } else {
      emit(state.copyWith(
        status: FeedStatus.loaded,
        checkIns: all,
        hasCheckedIn: hasCheckedIn,
        users: Map.unmodifiable(_usersCache),
        allMemberIds: _allMemberIds,
      ));
    }
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    for (final sub in _checkInSubscriptions.values) {
      sub.cancel();
    }
    return super.close();
  }
}
