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
    this.remoteUrl,
    this.remoteAktId,
  });

  factory EghuActionAttachment.remote({
    required String url,
    required String name,
    required bool isImage,
    int? aktId,
    DateTime? createdAt,
  }) {
    return EghuActionAttachment(
      path: '',
      name: name,
      sizeBytes: 0,
      isImage: isImage,
      sourceLabel: '',
      createdAt: createdAt ?? DateTime.now(),
      remoteUrl: url,
      remoteAktId: aktId,
    );
  }

  final String path;
  final String name;
  final int sizeBytes;
  final bool isImage;
  final String sourceLabel;
  final DateTime createdAt;
  final String? remoteUrl;
  final int? remoteAktId;

  bool get isRemote => remoteUrl != null;

  String get formattedSize {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1024).clamp(0.1, double.infinity).toStringAsFixed(1)} KB';
  }

  bool get exists => !isRemote && File(path).existsSync();

  @override
  List<Object?> get props => [
    path,
    name,
    sizeBytes,
    isImage,
    sourceLabel,
    createdAt,
    remoteUrl,
    remoteAktId,
  ];
}
