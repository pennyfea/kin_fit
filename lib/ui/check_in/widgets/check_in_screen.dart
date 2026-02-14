import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../domain/models/group.dart';
import '../../../routing/routes.dart';
import '../../app/blocs/app_bloc.dart';
import '../../groups/blocs/group_bloc.dart';
import '../blocs/check_in_cubit.dart';
import '../blocs/check_in_state.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({
    required this.photoPath,
    this.groupId,
    super.key,
  });

  final String photoPath;
  final String? groupId;

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AppBloc, String>(
      (bloc) => bloc.state.user.id,
    );

    return BlocProvider(
      create: (context) => CheckInCubit(
        checkInRepository: context.read<CheckInRepository>(),
        storageService: context.read<StorageService>(),
        userId: userId,
        initialGroupId: groupId,
        initialPhotoPath: photoPath,
      ),
      child: const _CheckInView(),
    );
  }
}

class _CheckInView extends StatefulWidget {
  const _CheckInView();

  @override
  State<_CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<_CheckInView>
    with SingleTickerProviderStateMixin {
  final _captionController = TextEditingController();
  late final AnimationController _lottieController;
  LottieComposition? _composition;
  bool _showLottie = false;

  static const _effortEmojis = ['😤', '💪', '😊', '😅', '🔥'];
  static const _lottieAsset = 'assets/animations/fire-raining-emoji-raining.json';

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showLottie = false);
      }
    });
    _loadComposition();
  }

  Future<void> _loadComposition() async {
    final composition = await AssetLottie(_lottieAsset).load();
    if (!mounted) return;
    _composition = composition;
    _lottieController.duration = composition.duration;
  }

  void _onEmojiTap(String emoji, bool wasSelected) {
    final cubit = context.read<CheckInCubit>();
    cubit.setEffortEmoji(wasSelected ? null : emoji);

    if (!wasSelected && _composition != null) {
      setState(() => _showLottie = true);
      _lottieController.reset();
      _lottieController.forward();
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CheckInCubit, CheckInState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CheckInStatus.success) {
          context.go(Routes.home);
        } else if (state.status == CheckInStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }
      },
      child: BlocBuilder<CheckInCubit, CheckInState>(
        builder: (context, state) {
          final isUploading = state.status == CheckInStatus.uploading;
          final groups = context.select<GroupBloc, List<Group>>(
            (bloc) => bloc.state.groups,
          );

          // Auto-select the only group
          if (groups.length == 1 && state.selectedGroupId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<CheckInCubit>().selectGroup(groups.first.id);
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Check In'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isUploading ? null : () => context.go(Routes.home),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group selector
                  if (groups.length > 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: state.selectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Group',
                        border: OutlineInputBorder(),
                      ),
                      items: groups
                          .map((g) => DropdownMenuItem(
                                value: g.id,
                                child: Text(
                                  g.emoji != null
                                      ? '${g.emoji} ${g.name}'
                                      : g.name,
                                ),
                              ))
                          .toList(),
                      onChanged: isUploading
                          ? null
                          : (value) {
                              if (value != null) {
                                context
                                    .read<CheckInCubit>()
                                    .selectGroup(value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Photo preview with Lottie overlay
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(state.photoPath!),
                            fit: BoxFit.cover,
                          ),
                          if (_showLottie && _composition != null)
                            Lottie(
                              composition: _composition!,
                              controller: _lottieController,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Caption
                  TextField(
                    controller: _captionController,
                    enabled: !isUploading,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Caption (optional)',
                      hintText: "What'd you do today?",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<CheckInCubit>().setCaption(value);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Effort emoji
                  Text(
                    'How was the effort?',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _effortEmojis.map((emoji) {
                      final isSelected = state.effortEmoji == emoji;
                      return GestureDetector(
                        onTap: isUploading
                            ? null
                            : () => _onEmojiTap(emoji, isSelected),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Text(
                            emoji,
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 28,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  FilledButton(
                    onPressed:
                        state.canSubmit && !isUploading ? _submit : null,
                    child: isUploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Post Check-In'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<CheckInCubit>().submit();
  }
}
