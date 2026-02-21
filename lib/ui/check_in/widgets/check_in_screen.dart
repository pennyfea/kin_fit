import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../utils/extensions/context_extensions.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../domain/models/group.dart';
import '../../../routing/routes.dart';
import '../../app/blocs/app_bloc.dart';
import '../../groups/blocs/group_bloc.dart';
import '../blocs/check_in_cubit.dart';
import '../blocs/check_in_state.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({required this.photoPath, this.groupId, super.key});

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
  static const _lottieAsset =
      'assets/animations/fire-raining-emoji-raining.json';

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
          context.go(Routes.feed);
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
            backgroundColor: context.colorScheme.surface,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full-bleed Photo Background
                Image.file(File(state.photoPath!), fit: BoxFit.cover),

                // Optional Lottie overlay
                if (_showLottie && _composition != null)
                  Lottie(
                    composition: _composition!,
                    controller: _lottieController,
                    fit: BoxFit.cover,
                  ),

                // 2. Gradient Overlay for readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          context.colorScheme.surface.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Top Bar (Back button)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface.withValues(
                        alpha: 0.45,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: isUploading
                          ? null
                          : () => context.go(Routes.feed),
                    ),
                  ),
                ),

                // 4. Bottom Input Area
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Group selector (if multiple)
                      if (groups.length > 1) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.selectedGroupId,
                              isExpanded: true,
                              dropdownColor: Colors.grey[900],
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: theme.textTheme.bodyLarge,
                              hint: Text(
                                'Select Group',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              items: groups
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g.id,
                                      child: Text(
                                        g.emoji != null
                                            ? '${g.emoji} ${g.name}'
                                            : g.name,
                                      ),
                                    ),
                                  )
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
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Caption
                      TextField(
                        controller: _captionController,
                        enabled: !isUploading,
                        maxLength: 200,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          context.read<CheckInCubit>().setCaption(value);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Effort emoji
                      Text(
                        'How was the effort?',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.4),
                                shape: BoxShape.circle,
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
                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        height: 64,
                        child: ElevatedButton(
                          onPressed: state.canSubmit && !isUploading
                              ? _submit
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
                          child: isUploading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Post Check-In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
