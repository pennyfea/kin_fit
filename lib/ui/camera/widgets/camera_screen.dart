import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../utils/extensions/context_extensions.dart';
import '../../../routing/routes.dart';
import '../../../utils/logger.dart';

/// Full-screen camera screen for taking check-in photos.
///
/// Lives outside the ShellRoute so the bottom nav is hidden.
/// After capture, navigates to the check-in screen.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  static const _log = Logger('CameraScreen');

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _isInitializing = false;
  String? _error;

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
      var photoPath = file.path;

      // Mirror front camera photos to match the preview
      final isFrontCamera =
          _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;
      if (isFrontCamera) {
        final bytes = await File(photoPath).readAsBytes();
        final original = img.decodeImage(bytes);
        if (original != null) {
          final flipped = img.flipHorizontal(original);
          final outputPath = photoPath.replaceAll('.jpg', '_flipped.jpg');
          await File(outputPath).writeAsBytes(img.encodeJpg(flipped));
          photoPath = outputPath;
        }
      }

      if (mounted) {
        context.go(
          '${Routes.checkIn}?photoPath=${Uri.encodeComponent(photoPath)}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera viewfinder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
            child: _buildViewfinder(),
          ),

          // Dark gradient at bottom for controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    context.colorScheme.surface.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top bar with back button
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface.withValues(
                          alpha: 0.45,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Camera controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery
                Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _pickFromGallery,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Shutter button
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 6,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // Flip camera
                Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _cameras.length > 1 ? _flipCamera : null,
                    icon: const Icon(
                      Icons.cameraswitch_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder() {
    if (_error != null) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
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
