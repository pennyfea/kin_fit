import 'package:equatable/equatable.dart';

enum CheckInStatus { initial, uploading, success, failure }

class CheckInState extends Equatable {
  const CheckInState({
    this.status = CheckInStatus.initial,
    this.selectedGroupId,
    this.photoPath,
    this.caption,
    this.effortEmoji,
    this.errorMessage,
  });

  final CheckInStatus status;
  final String? selectedGroupId;
  final String? photoPath;
  final String? caption;
  final String? effortEmoji;
  final String? errorMessage;

  bool get canSubmit =>
      selectedGroupId != null &&
      photoPath != null &&
      status != CheckInStatus.uploading;

  CheckInState copyWith({
    CheckInStatus? status,
    String? selectedGroupId,
    String? photoPath,
    String? caption,
    String? effortEmoji,
    String? errorMessage,
  }) {
    return CheckInState(
      status: status ?? this.status,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      photoPath: photoPath ?? this.photoPath,
      caption: caption ?? this.caption,
      effortEmoji: effortEmoji ?? this.effortEmoji,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedGroupId,
        photoPath,
        caption,
        effortEmoji,
        errorMessage,
      ];
}
