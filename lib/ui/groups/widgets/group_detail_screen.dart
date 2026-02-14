import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Group;
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/group.dart';
import '../../app/blocs/app_bloc.dart';
import '../../home/widgets/check_in_card.dart';
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
          GroupDetailStatus.initial || GroupDetailStatus.loading =>
            const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          GroupDetailStatus.loaded => _LoadedView(
              group: state.group!,
              todayCheckIns: state.todayCheckIns,
            ),
          GroupDetailStatus.failure => Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            ),
        };
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.group,
    required this.todayCheckIns,
  });

  final Group group;
  final List<CheckIn> todayCheckIns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = context.read<AppBloc>().state.user.id;
    final isCreator = group.creatorId == userId;

    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == GroupActionStatus.success) {
          Navigator.of(context).pop();
        } else if (state.actionStatus == GroupActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError ?? 'Something went wrong'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _showInviteCode(context, group),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'leave':
                    _confirmLeave(context, group, userId);
                  case 'delete':
                    _confirmDelete(context, group, userId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'leave',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Leave Group'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (isCreator)
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Delete Group',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            // Group info header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (group.emoji != null)
                      Text(
                        group.emoji!,
                        style: const TextStyle(fontSize: 32),
                      ),
                    if (group.emoji != null) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                            style: theme.textTheme.bodyLarge,
                          ),
                          if (group.groupStreak > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${group.groupStreak} day streak',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: Divider(height: 1)),

            // Today's check-ins header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "Today's Check-ins",
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),

            // Check-ins list
            if (todayCheckIns.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No check-ins yet today. Be the first!'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: todayCheckIns.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CheckInCard(checkIn: todayCheckIns[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context, Group group, String userId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final isCreator = group.creatorId == userId;
        final message = isCreator && group.memberCount > 1
            ? 'You are the creator. Ownership will be transferred to another member.'
            : group.memberCount <= 1
                ? 'You are the last member. The group will be deleted.'
                : 'Are you sure you want to leave "${group.name}"?';

        return AlertDialog(
          title: const Text('Leave Group'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<GroupBloc>().add(
                      GroupLeaveRequested(
                        groupId: group.id,
                        userId: userId,
                      ),
                    );
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Group group, String userId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text(
            'This will permanently delete "${group.name}" for all '
            '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}. '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<GroupBloc>().add(
                      GroupDeleteRequested(
                        groupId: group.id,
                        userId: userId,
                      ),
                    );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showInviteCode(BuildContext context, Group group) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invite Code', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  group.inviteCode,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: group.inviteCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invite code copied!'),
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _pickContactAndSendSms(context, group);
                      },
                      icon: const Icon(Icons.contacts),
                      label: const Text('Invite'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact permission is required to send invites.'),
          ),
        );
      }
      return;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    if (!context.mounted) return;

    // Filter to contacts that have a phone number
    final contactsWithPhone =
        contacts.where((c) => c.phones.isNotEmpty).toList();

    if (contactsWithPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contacts with phone numbers found.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app.')),
        );
      }
    }
  }
}
