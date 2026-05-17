import 'dart:io';
import 'package:flutter/material.dart';

/// Resolves a stored image path/URL to the correct Flutter [ImageProvider].
///
/// - Empty / null  → returns `null` (show placeholder icon instead)
/// - Starts with "http" → [NetworkImage] (e.g., Google profile photos)
/// - Otherwise → [FileImage] pointing to a local file path
ImageProvider? resolveImageProvider(String? pathOrUrl) {
  if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
  if (pathOrUrl.startsWith('http')) return NetworkImage(pathOrUrl);
  final file = File(pathOrUrl);
  if (file.existsSync()) return FileImage(file);
  return null;
}
