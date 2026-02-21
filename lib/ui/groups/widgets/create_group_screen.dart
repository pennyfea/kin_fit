import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/extensions/context_extensions.dart';
import '../../app/blocs/app_bloc.dart';
import '../blocs/group_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  int _maxMembers = 4;
  String? _selectedEmoji;

  static const _minMembers = 2;
  static const _maxMembersLimit = 12;

  static const _emojiOptions = [
    '\u{1F4AA}', // 💪
    '\u{1F525}', // 🔥
    '\u{26A1}', // ⚡
    '\u{1F3C3}', // 🏃
    '\u{1F6B4}', // 🚴
    '\u{1F3CB}', // 🏋️
    '\u{1F9D8}', // 🧘
    '\u{1F3AF}', // 🎯
    '\u{2B50}', // ⭐
    '\u{1F680}', // 🚀
    '\u{1F3C6}', // 🏆
    '\u{1F48E}', // 💎
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createGroup() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final userId = context.read<AppBloc>().state.user.id;
    context.read<GroupBloc>().add(
      GroupCreateRequested(
        name: name,
        userId: userId,
        emoji: _selectedEmoji,
        maxMembers: _maxMembers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == GroupActionStatus.success) {
          context.pop();
        } else if (state.actionStatus == GroupActionStatus.failure) {
          context.showSnackBar(
            state.actionError ?? 'Failed to create group',
          );
        }
      },
      child: BlocSelector<GroupBloc, GroupState, GroupActionStatus>(
        selector: (state) => state.actionStatus,
        builder: (context, actionStatus) {
          final isLoading = actionStatus == GroupActionStatus.loading;

          return Scaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: AppBar(title: const Text('Create Squad')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Emoji picker
                  Text(
                    'Squad Icon',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // "None" option
                      GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = null),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _selectedEmoji == null
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedEmoji == null
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.text_fields,
                              size: 20,
                              color: _selectedEmoji == null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      // Emoji options
                      ..._emojiOptions.map((emoji) {
                        final isSelected = _selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedEmoji = emoji),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Name field
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Squad Name',
                      hintText: 'e.g. Morning Crew',
                    ),
                    onSubmitted: (_) => _createGroup(),
                  ),

                  const SizedBox(height: 28),

                  // Squad size
                  Text(
                    'Squad Size',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant
                            .withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _maxMembers > _minMembers
                                ? () => setState(() => _maxMembers--)
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '$_maxMembers members',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _maxMembers < _maxMembersLimit
                                ? () => setState(() => _maxMembers++)
                                : null,
                            icon: Icon(
                              Icons.add,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Create button
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _createGroup,
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Text('Create Squad'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
