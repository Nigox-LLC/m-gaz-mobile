import 'dart:io';

import 'package:equatable/equatable.dart';

class EghuActionAttachment extends Equatable {
  const EghuActionAttachment({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.isImage,
    required this.sourceLabel,
    required this.createdAt,
  });

  final String path;
  final String name;
  final int sizeBytes;
  final bool isImage;
  final String sourceLabel;
  final DateTime createdAt;

  String get formattedSize {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1024).clamp(0.1, double.infinity).toStringAsFixed(1)} KB';
  }

  bool get exists => File(path).existsSync();

  @override
  List<Object?> get props => [
    path,
    name,
    sizeBytes,
    isImage,
    sourceLabel,
    createdAt,
  ];
}
