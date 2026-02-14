import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Service for uploading files to Firebase Storage.
class StorageService {
  StorageService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  /// Uploads a check-in photo and returns the download URL.
  ///
  /// Photos are stored at `check_ins/{userId}/{unique_id}.jpg`.
  Future<String> uploadCheckInPhoto({
    required String filePath,
    required String userId,
  }) async {
    final file = File(filePath);
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('check_ins/$userId/$fileName');

    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return ref.getDownloadURL();
  }
}
