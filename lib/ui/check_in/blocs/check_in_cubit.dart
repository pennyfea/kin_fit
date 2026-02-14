import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../utils/logger.dart';
import 'check_in_state.dart';

/// Cubit that manages the check-in creation flow.
class CheckInCubit extends Cubit<CheckInState> {
  CheckInCubit({
    required CheckInRepository checkInRepository,
    required StorageService storageService,
    required String userId,
    String? initialGroupId,
    String? initialPhotoPath,
  })  : _checkInRepository = checkInRepository,
        _storageService = storageService,
        _userId = userId,
        super(CheckInState(
          selectedGroupId: initialGroupId,
          photoPath: initialPhotoPath,
        ));

  static const _log = Logger('CheckInCubit');

  final CheckInRepository _checkInRepository;
  final StorageService _storageService;
  final String _userId;

  void selectGroup(String groupId) {
    emit(state.copyWith(selectedGroupId: groupId));
  }

  void setPhoto(String path) {
    emit(state.copyWith(photoPath: path));
  }

  void setCaption(String caption) {
    emit(state.copyWith(caption: caption));
  }

  void setEffortEmoji(String? emoji) {
    emit(state.copyWith(effortEmoji: emoji));
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: CheckInStatus.uploading));

    try {
      _log.info('Uploading photo...');
      final photoUrl = await _storageService.uploadCheckInPhoto(
        filePath: state.photoPath!,
        userId: _userId,
      );

      _log.info('Creating check-in...');
      await _checkInRepository.createCheckIn(
        groupId: state.selectedGroupId!,
        userId: _userId,
        photoUrl: photoUrl,
        caption: state.caption?.trim().isNotEmpty == true
            ? state.caption!.trim()
            : null,
        effortEmoji: state.effortEmoji,
      );

      _log.info('Check-in created successfully');
      emit(state.copyWith(status: CheckInStatus.success));
    } catch (e) {
      _log.error('Failed to create check-in: $e');
      emit(state.copyWith(
        status: CheckInStatus.failure,
        errorMessage: 'Failed to post check-in. Please try again.',
      ));
    }
  }
}
