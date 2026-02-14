import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/user.dart';
import '../../../routing/routes.dart';
import '../../../utils/logger.dart';
import '../../app/blocs/app_bloc.dart';
import '../../groups/blocs/group_bloc.dart';
import '../blocs/feed_cubit.dart';
import '../blocs/feed_state.dart';
import 'check_in_card.dart';
import 'check_in_wall.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const _log = Logger('HomeScreen');

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _isInitializing = false;
  String? _error;

  /// true = showing feed, false = showing camera
  bool _showFeed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'No cameras found');
        return;
      }

      _cameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_cameraIndex == -1) _cameraIndex = 0;

      await _setupController(_cameras[_cameraIndex]);
    } catch (e) {
      _log.error('Failed to init camera: $e');
      setState(() => _error = 'Camera unavailable');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    final previous = _controller;
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await previous?.dispose();
    if (!mounted) return;

    _controller = controller;

    try {
      await controller.initialize();
    } catch (e) {
      _log.error('Failed to initialize camera controller: $e');
      setState(() => _error = 'Camera permission denied');
      return;
    }

    if (mounted) setState(() {});
  }

  void _flipCamera() {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    _setupController(_cameras[_cameraIndex]);
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    try {
      final file = await controller.takePicture();
      if (mounted) {
        context.go(
          '${Routes.checkIn}?photoPath=${Uri.encodeComponent(file.path)}',
        );
      }
    } catch (e) {
      _log.error('Failed to take picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      context.go(
        '${Routes.checkIn}?photoPath=${Uri.encodeComponent(image.path)}',
      );
    }
  }

  void _toggleFeed() {
    setState(() => _showFeed = !_showFeed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocListener<FeedCubit, FeedState>(
          listenWhen: (prev, curr) =>
              !prev.hasCheckedIn && curr.hasCheckedIn,
          listener: (context, state) {
            // Auto-show wall when user checks in
            setState(() => _showFeed = true);
          },
          child: BlocBuilder<FeedCubit, FeedState>(
          builder: (context, feedState) {
            return Stack(
              children: [
                // Main content area (camera or feed)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 72,
                  bottom: _showFeed ? 80 : 128,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _showFeed && feedState.hasCheckedIn
                          ? _buildFeed(feedState)
                          : _buildViewfinder(),
                    ),
                  ),
                ),

                // Top bar: Profile, Groups pill, (future: messages)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 8,
                  child: _buildTopBar(theme, feedState),
                ),

                // Camera controls (hidden when wall is showing)
                if (!_showFeed || !feedState.hasCheckedIn) ...[
                  // Gallery picker (bottom-left)
                  Positioned(
                    left: 16,
                    bottom: 32,
                    child: IconButton(
                      onPressed: _pickFromGallery,
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Shutter button (bottom-center)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Center(
                      child: GestureDetector(
                        onTap: _takePhoto,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 4,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flip camera (bottom-right)
                  Positioned(
                    right: 32,
                    bottom: 24,
                    child: IconButton(
                      onPressed: _cameras.length > 1 ? _flipCamera : null,
                      icon: const Icon(
                        Icons.cameraswitch_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Prompt (not checked in yet)
                  if (!feedState.hasCheckedIn &&
                      feedState.status != FeedStatus.initial &&
                      feedState.status != FeedStatus.loading)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          'Check in to see your friends',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, FeedState feedState) {
    return Row(
      children: [
        // Profile button
        IconButton(
          onPressed: () => context.push(Routes.profile),
          icon: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 28,
          ),
        ),

        const Spacer(),

        // Groups pill
        BlocSelector<GroupBloc, GroupState, int>(
          selector: (state) => state.groups.length,
          builder: (context, count) {
            return OutlinedButton.icon(
              onPressed: () => context.push(Routes.groups),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.people, size: 18),
              label: Text(
                _showFeed ? 'Everyone' : 'Groups ($count)',
                style: const TextStyle(fontSize: 14),
              ),
            );
          },
        ),

        const Spacer(),

        // Wall toggle (only when checked in)
        if (feedState.hasCheckedIn)
          IconButton(
            onPressed: _toggleFeed,
            icon: Icon(
              _showFeed ? Icons.camera_alt_outlined : Icons.grid_view_rounded,
              color: Colors.white,
              size: 24,
            ),
          )
        else
          const SizedBox(width: 44),
      ],
    );
  }

  String get _currentUserId {
    return context.read<AppBloc>().state.user.id;
  }

  Widget _buildFeed(FeedState feedState) {
    return CheckInWall(
      feedState: feedState,
      currentUserId: _currentUserId,
      onTapCheckIn: _onTapCheckIn,
      onReact: (checkIn, emoji) => _onReact(checkIn, emoji),
    );
  }

  void _onTapCheckIn(CheckIn checkIn, User? user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: CheckInCard(
            checkIn: checkIn,
            user: user,
            onReact: (emoji) => _onReact(checkIn, emoji),
          ),
        ),
      ),
    );
  }

  void _onReact(CheckIn checkIn, String emoji) {
    final userId = context.read<AppBloc>().state.user.id;
    context.read<CheckInRepository>().addReaction(
          groupId: checkIn.groupId,
          checkInId: checkIn.id,
          userId: userId,
          emoji: emoji,
        );
  }

  Widget _buildViewfinder() {
    if (_error != null) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: controller.value.previewSize!.height,
        height: controller.value.previewSize!.width,
        child: CameraPreview(controller),
      ),
    );
  }
}
