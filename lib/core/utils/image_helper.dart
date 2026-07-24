import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

/// Resolves a stored image path/URL to the correct Flutter [ImageProvider].
///
/// - Empty / null  → returns `null` (show placeholder icon instead)
/// - Starts with "http" → [NetworkImage] (e.g., Google profile photos)
/// - Starts with "data:image" → [MemoryImage] (e.g., base64 string from DB)
/// - Otherwise → [FileImage] pointing to a local file path
ImageProvider? resolveImageProvider(String? pathOrUrl) {
  if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
  if (pathOrUrl.startsWith('http')) return NetworkImage(pathOrUrl);
  if (pathOrUrl.startsWith('data:image')) {
    final base64Str = pathOrUrl.split(',').last;
    try {
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return null;
    }
  }
  final file = File(pathOrUrl);
  if (file.existsSync()) return FileImage(file);
  return null;
}
