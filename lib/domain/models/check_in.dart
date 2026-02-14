import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'check_in.g.dart';

/// Represents a daily fitness check-in within a group.
@JsonSerializable(explicitToJson: true)
class CheckIn extends Equatable {
  const CheckIn({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.photoUrl,
    this.caption,
    this.effortEmoji,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String groupId;
  final String photoUrl;
  final String? caption;
  final String? effortEmoji;
  final DateTime? createdAt;

  factory CheckIn.fromJson(Map<String, dynamic> json) =>
      _$CheckInFromJson(json);
  Map<String, dynamic> toJson() => _$CheckInToJson(this);

  factory CheckIn.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
    String groupId,
  ) {
    return CheckIn(
      id: documentId,
      userId: data['user_id'] as String? ?? '',
      groupId: groupId,
      photoUrl: data['photo_url'] as String? ?? '',
      caption: data['caption'] as String?,
      effortEmoji: data['effort_emoji'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'photo_url': photoUrl,
      'caption': caption,
      'effort_emoji': effortEmoji,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  CheckIn copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? photoUrl,
    String? caption,
    String? effortEmoji,
    DateTime? createdAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      photoUrl: photoUrl ?? this.photoUrl,
      caption: caption ?? this.caption,
      effortEmoji: effortEmoji ?? this.effortEmoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        groupId,
        photoUrl,
        caption,
        effortEmoji,
        createdAt,
      ];
}
