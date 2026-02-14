import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reaction.g.dart';

/// Represents an emoji reaction on a check-in.
@JsonSerializable(explicitToJson: true)
class Reaction extends Equatable {
  const Reaction({
    required this.id,
    required this.userId,
    required this.emoji,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String emoji;
  final DateTime? createdAt;

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);
  Map<String, dynamic> toJson() => _$ReactionToJson(this);

  factory Reaction.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Reaction(
      id: documentId,
      userId: data['user_id'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'emoji': emoji,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  Reaction copyWith({
    String? id,
    String? userId,
    String? emoji,
    DateTime? createdAt,
  }) {
    return Reaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, emoji, createdAt];
}
