import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Manages local image storage on the device.
///
/// Instead of uploading to Firebase Storage, images are copied into the app's
/// permanent documents directory. The returned path is stored in Firestore.
class StorageService {
  final _uuid = const Uuid();

  /// Returns the base directory for all Workzy images.
  Future<Directory> _baseDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/workzy');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Upload a profile photo — copies the file locally and returns the path.
  Future<String> uploadProfilePhoto(String userId, XFile imageFile) async {
    final base = await _baseDir();
    final ext = imageFile.path.split('.').last;
    final dest = Directory('${base.path}/profile_photos');
    if (!await dest.exists()) await dest.create(recursive: true);

    final targetPath = '${dest.path}/$userId.$ext';
    await File(imageFile.path).copy(targetPath);
    return targetPath;
  }

  /// Upload a portfolio image — copies the file locally and returns the path.
  Future<String> uploadPortfolioImage(String workerId, XFile imageFile) async {
    final base = await _baseDir();
    final ext = imageFile.path.split('.').last;
    final dest = Directory('${base.path}/portfolio/$workerId');
    if (!await dest.exists()) await dest.create(recursive: true);

    final fileName = '${_uuid.v4()}.$ext';
    final targetPath = '${dest.path}/$fileName';
    await File(imageFile.path).copy(targetPath);
    return targetPath;
  }

  /// Delete an image by its local path. No-op if the file doesn't exist.
  Future<void> deleteImage(String path) async {
    try {
      if (path.startsWith('http')) return; // Remote URL — skip
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Ignore deletion errors
    }
  }

  /// Upload multiple portfolio images and return their local paths.
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
