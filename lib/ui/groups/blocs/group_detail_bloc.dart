import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/group.dart';
import '../../../utils/logger.dart';

part 'group_detail_event.dart';
part 'group_detail_state.dart';

/// BLoC that manages the detail view for a single group.
class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  GroupDetailBloc({
    required GroupRepository groupRepository,
    required CheckInRepository checkInRepository,
  })  : _groupRepository = groupRepository,
        _checkInRepository = checkInRepository,
        super(const GroupDetailState()) {
    on<GroupDetailSubscriptionRequested>(_onSubscriptionRequested);
    on<GroupDetailRefreshRequested>(_onRefreshRequested);
  }

  static const _log = Logger('GroupDetailBloc');

  final GroupRepository _groupRepository;
  final CheckInRepository _checkInRepository;

  Future<void> _onSubscriptionRequested(
    GroupDetailSubscriptionRequested event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(state.copyWith(status: GroupDetailStatus.loading));

    try {
      final group = await _groupRepository.getGroup(event.groupId);
      if (group == null) {
        emit(state.copyWith(
          status: GroupDetailStatus.failure,
          errorMessage: 'Group not found.',
        ));
        return;
      }

      await emit.forEach(
        _checkInRepository.watchTodayCheckIns(event.groupId),
        onData: (checkIns) {
          return state.copyWith(
            status: GroupDetailStatus.loaded,
            group: group,
            todayCheckIns: checkIns,
          );
        },
        onError: (error, _) {
          return state.copyWith(
            status: GroupDetailStatus.failure,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: GroupDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    GroupDetailRefreshRequested event,
    Emitter<GroupDetailState> emit,
  ) async {
    if (state.status != GroupDetailStatus.loaded) return;

    try {
      final group = await _groupRepository.getGroup(event.groupId);
      if (group == null) return;

      emit(state.copyWith(group: group));
    } catch (_) {
      // Silently fail on refresh — keep showing existing data
    }
  }

  @override
  void onEvent(GroupDetailEvent event) {
    _log.info('Event: ${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<GroupDetailState> change) {
    _log.info(
      'State: ${change.currentState.status} → ${change.nextState.status}',
    );
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _log.error('Error: $error', error, stackTrace);
    super.onError(error, stackTrace);
  }
}
