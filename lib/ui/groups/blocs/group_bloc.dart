import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/group.dart';
import '../../../utils/logger.dart';

part 'group_event.dart';
part 'group_state.dart';

/// BLoC that manages the user's groups, including listing, creating, and joining.
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc({
    required GroupRepository groupRepository,
    required UserRepository userRepository,
  })  : _groupRepository = groupRepository,
        _userRepository = userRepository,
        super(const GroupState()) {
    on<GroupsSubscriptionRequested>(_onSubscriptionRequested);
    on<GroupCreateRequested>(_onCreateRequested);
    on<GroupJoinRequested>(_onJoinRequested);
    on<GroupLeaveRequested>(_onLeaveRequested);
    on<GroupDeleteRequested>(_onDeleteRequested);
  }

  static const _log = Logger('GroupBloc');

  final GroupRepository _groupRepository;
  final UserRepository _userRepository;

  Future<void> _onSubscriptionRequested(
    GroupsSubscriptionRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(status: GroupStatus.loading));

    await emit.forEach(
      _groupRepository.watchUserGroups(event.userId),
      onData: (groups) {
        if (groups.isEmpty) {
          return state.copyWith(
            status: GroupStatus.empty,
            groups: [],
          );
        }
        return state.copyWith(
          status: GroupStatus.loaded,
          groups: groups,
        );
      },
      onError: (error, _) {
        return state.copyWith(
          status: GroupStatus.failure,
          actionError: error.toString(),
        );
      },
    );
  }

  Future<void> _onCreateRequested(
    GroupCreateRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(actionStatus: GroupActionStatus.loading));

    try {
      final group = await _groupRepository.createGroup(
        name: event.name,
        creatorId: event.userId,
        maxMembers: event.maxMembers,
      );
      _log.info('Create: group created ${group.id}');

      try {
        await _userRepository.addGroupToUser(event.userId, group.id);
        _log.info('Create: added group to user doc');
      } catch (e) {
        // Non-critical — user is already a member via group.memberIds.
        _log.warning('Create: addGroupToUser failed: $e');
      }

      _log.info('Create: emitting success');
      emit(state.copyWith(actionStatus: GroupActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: GroupActionStatus.failure,
        actionError: 'Failed to create group: $e',
      ));
    }
  }

  Future<void> _onJoinRequested(
    GroupJoinRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(actionStatus: GroupActionStatus.loading));

    try {
      final group = await _groupRepository.getGroupByInviteCode(
        event.inviteCode,
      );

      if (group == null) {
        emit(state.copyWith(
          actionStatus: GroupActionStatus.failure,
          actionError: 'No group found with that invite code.',
        ));
        return;
      }

      if (group.memberIds.contains(event.userId)) {
        emit(state.copyWith(
          actionStatus: GroupActionStatus.failure,
          actionError: 'You are already a member of this group.',
        ));
        return;
      }

      if (group.isFull) {
        emit(state.copyWith(
          actionStatus: GroupActionStatus.failure,
          actionError: 'This group is full.',
        ));
        return;
      }

      await _groupRepository.addMember(group.id, event.userId);

      try {
        await _userRepository.addGroupToUser(event.userId, group.id);
      } catch (e) {
        _log.warning('Join: addGroupToUser failed: $e');
      }

      emit(state.copyWith(actionStatus: GroupActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: GroupActionStatus.failure,
        actionError: 'Failed to join group. Please try again.',
      ));
    }
  }

  Future<void> _onLeaveRequested(
    GroupLeaveRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(actionStatus: GroupActionStatus.loading));

    try {
      final group = await _groupRepository.getGroup(event.groupId);
      if (group == null) {
        emit(state.copyWith(
          actionStatus: GroupActionStatus.failure,
          actionError: 'Group not found.',
        ));
        return;
      }

      final isLastMember = group.memberIds.length <= 1;

      if (isLastMember) {
        // Auto-delete when the last member leaves
        await _groupRepository.deleteGroup(event.groupId);
        _log.info('Leave: last member left, group deleted');
      } else {
        // Remove member
        await _groupRepository.removeMember(event.groupId, event.userId);

        // Transfer ownership if creator is leaving
        if (group.creatorId == event.userId) {
          final newCreator = group.memberIds
              .firstWhere((id) => id != event.userId);
          await _groupRepository.updateCreator(event.groupId, newCreator);
          _log.info('Leave: ownership transferred to $newCreator');
        }
      }

      try {
        await _userRepository.removeGroupFromUser(
          event.userId,
          event.groupId,
        );
      } catch (e) {
        _log.warning('Leave: removeGroupFromUser failed: $e');
      }

      emit(state.copyWith(actionStatus: GroupActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: GroupActionStatus.failure,
        actionError: 'Failed to leave group. Please try again.',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    GroupDeleteRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(actionStatus: GroupActionStatus.loading));

    try {
      final group = await _groupRepository.getGroup(event.groupId);
      if (group == null) {
        emit(state.copyWith(
          actionStatus: GroupActionStatus.failure,
          actionError: 'Group not found.',
        ));
        return;
      }

      if (group.creatorId != event.userId) {
        emit(state.copyWith(
          actionStatus: GroupActionStatus.failure,
          actionError: 'Only the group creator can delete this group.',
        ));
        return;
      }

      await _groupRepository.deleteGroup(event.groupId);
      _log.info('Delete: group ${event.groupId} deleted');

      // Clean up group reference for the current user
      try {
        await _userRepository.removeGroupFromUser(
          event.userId,
          event.groupId,
        );
      } catch (e) {
        _log.warning('Delete: removeGroupFromUser failed: $e');
      }

      emit(state.copyWith(actionStatus: GroupActionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        actionStatus: GroupActionStatus.failure,
        actionError: 'Failed to delete group. Please try again.',
      ));
    }
  }

  @override
  void onEvent(GroupEvent event) {
    _log.info('Event: ${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<GroupState> change) {
    _log.info(
      'State: ${change.currentState.status}/${change.currentState.actionStatus}'
      ' → ${change.nextState.status}/${change.nextState.actionStatus}',
    );
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    _log.error('Error: $error', error, stackTrace);
    super.onError(error, stackTrace);
  }
}
