import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// Manages image storage by encoding them as Base64 strings.
///
/// Instead of uploading to Firebase Storage or local filesystem, 
/// images are converted to base64 strings and stored in the PostgreSQL database.
class StorageService {
  /// Upload a profile photo — returns the base64 string.
  Future<String> uploadProfilePhoto(String userId, XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  /// Upload a portfolio image — returns the base64 string.
  Future<String> uploadPortfolioImage(String workerId, XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  /// Delete an image. No-op for base64 URLs.
  Future<void> deleteImage(String path) async {
    // No-op for base64 since deleting the record in DB handles it
  }

  /// Upload multiple portfolio images and return their base64 strings.
  Future<List<String>> uploadMultipleImages(
      String workerId, List<XFile> images) async {
    final paths = <String>[];
    for (final image in images) {
      final path = await uploadPortfolioImage(workerId, image);
      paths.add(path);
    }
    return paths;
  }
}
