import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Group;
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/group.dart';
import '../../../domain/models/user.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../../app/blocs/app_bloc.dart';
import '../blocs/group_bloc.dart';
import '../blocs/group_detail_bloc.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupDetailBloc(
        groupRepository: context.read<GroupRepository>(),
        checkInRepository: context.read<CheckInRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(GroupDetailSubscriptionRequested(groupId)),
      child: const _GroupDetailView(),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) {
        return switch (state.status) {
          GroupDetailStatus.initial || GroupDetailStatus.loading => Scaffold(
            backgroundColor: context.colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          ),
          GroupDetailStatus.loaded => _LoadedView(state: state),
          GroupDetailStatus.failure => Scaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: AppBar(),
            body: Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ),
        };
      },
    );
  }
}

// ─── Loaded View ──────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final GroupDetailState state;

  Group get group => state.group!;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AppBloc>().state.user.id;

    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, groupState) {
        if (groupState.actionStatus == GroupActionStatus.success) {
          Navigator.of(context).pop();
        } else if (groupState.actionStatus == GroupActionStatus.failure) {
          context.showSnackBar(
            groupState.actionError ?? 'Something went wrong',
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            // Custom app bar
            SliverToBoxAdapter(
              child: _Header(
                group: group,
                checkedInCount: state.checkedInCount,
                userId: userId,
                onInvite: () => _showInviteSheet(context, group),
                onMore: () => _showActionsSheet(context, group, userId),
              ),
            ),

            // Today's progress
            SliverToBoxAdapter(
              child: _TodayProgress(
                total: group.memberCount,
                checkedIn: state.checkedInCount,
              ),
            ),

            // Members roster
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Members',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: state.members.length,
                itemBuilder: (context, index) {
                  final member = state.members[index];
                  final hasCheckedIn =
                      state.checkedInUserIds.contains(member.id);
                  final isCreator = member.id == group.creatorId;
                  return _MemberTile(
                    member: member,
                    hasCheckedIn: hasCheckedIn,
                    isCreator: isCreator,
                  );
                },
              ),
            ),

            // Group stats
            SliverToBoxAdapter(
              child: _GroupStats(group: group),
            ),

            // Invite card
            SliverToBoxAdapter(
              child: _InviteCard(
                group: group,
                onTap: () => _showInviteSheet(context, group),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _showActionsSheet(BuildContext context, Group group, String userId) {
    final theme = Theme.of(context);
    final isCreator = group.creatorId == userId;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: theme.colorScheme.onSurface,
                ),
                title: const Text('Leave Squad'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmLeave(context, group, userId);
                },
              ),
              if (isCreator)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Delete Squad',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(context, group, userId);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLeave(BuildContext context, Group group, String userId) {
    final theme = Theme.of(context);
    final isCreator = group.creatorId == userId;
    final message = isCreator && group.memberCount > 1
        ? 'You are the creator. Ownership will be transferred to another member.'
        : group.memberCount <= 1
            ? 'You are the last member. The group will be deleted.'
            : 'Are you sure you want to leave "${group.name}"?';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).padding.bottom + 24,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app,
                size: 40,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Leave Squad',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        context.read<GroupBloc>().add(
                          GroupLeaveRequested(
                            groupId: group.id,
                            userId: userId,
                          ),
                        );
                      },
                      child: const Text('Leave'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Group group, String userId) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).padding.bottom + 24,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 40, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Delete Squad', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'This will permanently delete "${group.name}" for all '
                '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}. '
                'This cannot be undone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        context.read<GroupBloc>().add(
                          GroupDeleteRequested(
                            groupId: group.id,
                            userId: userId,
                          ),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInviteSheet(BuildContext context, Group group) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).padding.bottom + 24,
            left: 24,
            right: 24,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invite to Squad', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Share this code with your friends to join.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  group.inviteCode,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: group.inviteCode),
                        );
                        context.showSnackBar('Invite code copied!');
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text(
                        'Copy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _pickContactAndSendSms(context, group);
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text(
                        'Send SMS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickContactAndSendSms(
    BuildContext context,
    Group group,
  ) async {
    final hasPermission = await FlutterContacts.requestPermission();
    if (!hasPermission) {
      if (context.mounted) {
        context.showSnackBar(
          'Contact permission is required to send invites.',
        );
      }
      return;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    if (!context.mounted) return;

    final contactsWithPhone =
        contacts.where((c) => c.phones.isNotEmpty).toList();

    if (contactsWithPhone.isEmpty) {
      context.showSnackBar('No contacts with phone numbers found.');
      return;
    }

    final selected = await showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Select a Contact',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: contactsWithPhone.length,
                    itemBuilder: (context, index) {
                      final contact = contactsWithPhone[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            contact.displayName.isNotEmpty
                                ? contact.displayName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(contact.displayName),
                        subtitle: Text(contact.phones.first.number),
                        onTap: () => Navigator.pop(context, contact),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected == null || !context.mounted) return;

    final phone = selected.phones.first.number;
    final message = 'Join my group "${group.name}" on Kin! '
        'Use invite code: ${group.inviteCode}';
    final smsUri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (context.mounted) {
        context.showSnackBar('Could not open SMS app.');
      }
    }
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.group,
    required this.checkedInCount,
    required this.userId,
    required this.onInvite,
    required this.onMore,
  });

  final Group group;
  final int checkedInCount;
  final String userId;
  final VoidCallback onInvite;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Nav row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: onInvite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: onMore,
                  ),
                ],
              ),
            ),

            // Emoji + name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        group.emoji ?? group.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: group.emoji != null ? 40 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    group.name,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (group.groupStreak > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${group.groupStreak} Day Streak',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Today's Progress ─────────────────────────────────────────────────────────

class _TodayProgress extends StatelessWidget {
  const _TodayProgress({required this.total, required this.checkedIn});

  final int total;
  final int checkedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? checkedIn / total : 0.0;
    final allDone = checkedIn == total && total > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: allDone
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: allDone
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Progress ring
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(
                        allDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Text(
                    allDone ? '!' : '$checkedIn',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: allDone
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allDone ? 'Everyone checked in!' : "Today's Activity",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    allDone
                        ? 'The whole squad showed up today'
                        : '$checkedIn of $total members checked in',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Member Tile ──────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.hasCheckedIn,
    required this.isCreator,
  });

  final User member;
  final bool hasCheckedIn;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                image: member.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(member.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: member.photoUrl == null
                  ? Center(
                      child: Text(
                        member.displayName[0].toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Name + badge
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      member.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCreator) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Admin',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Check-in status
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasCheckedIn
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
              child: Icon(
                hasCheckedIn ? Icons.check : Icons.remove,
                size: 18,
                color: hasCheckedIn
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Group Stats ──────────────────────────────────────────────────────────────

class _GroupStats extends StatelessWidget {
  const _GroupStats({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            _StatItem(
              icon: Icons.local_fire_department,
              value: '${group.groupStreak}',
              label: 'Streak',
              color: theme.colorScheme.primary,
            ),
            _divider(theme),
            _StatItem(
              icon: Icons.emoji_events_outlined,
              value: '${group.longestGroupStreak}',
              label: 'Best',
              color: Colors.amber,
            ),
            _divider(theme),
            _StatItem(
              icon: Icons.people_outline,
              value: '${group.memberCount}',
              label: 'Members',
              color: Colors.purpleAccent,
            ),
            if (group.maxMembers != null) ...[
              _divider(theme),
              _StatItem(
                icon: Icons.group_outlined,
                value: '${group.maxMembers}',
                label: 'Max',
                color: Colors.cyanAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Invite Card ──────────────────────────────────────────────────────────────

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.group, required this.onTap});

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.08),
                theme.colorScheme.primary.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite Friends',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.isFull
                          ? 'Squad is full'
                          : 'Share your invite code to grow the squad',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
