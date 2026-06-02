import 'dart:io';

import 'package:equatable/equatable.dart';

/// Iste'molchi fayli (Loyiha texnik hujjati / Shartnoma).
/// Manba: GET /api/directory/consumers/files/
class ConsumerFile {
  final int? id;
  final String? file;
  final String? fileType; // TECHNICAL | CONTRACT
  final String? createdAt;

  const ConsumerFile({this.id, this.file, this.fileType, this.createdAt});

  factory ConsumerFile.fromJson(Map<String, dynamic> json) {
    return ConsumerFile(
      id: json['id'],
      file: json['file'],
      fileType: json['file_type'],
      createdAt: json['created_at'],
    );
  }
}

/// EGHU sertifikat fayli.
/// Manba: GET /api/consumer-relations-documents/egxu/certificates/
class EgxuCertificate {
  final int? id;
  final String? file;
  final String? createdAt;

  const EgxuCertificate({this.id, this.file, this.createdAt});

  factory EgxuCertificate.fromJson(Map<String, dynamic> json) {
    return EgxuCertificate(
      id: json['id'],
      file: json['file'],
      createdAt: json['created_at'],
    );
  }
}

/// UI uchun yagona fayl modeli — mavjud (remote) yoki yangi tanlangan (local).
class ConsumerUploadFile extends Equatable {
  const ConsumerUploadFile({
    required this.name,
    required this.isImage,
    required this.createdAt,
    this.id,
    this.remoteUrl,
    this.localPath,
    this.sizeBytes = 0,
  });

  final int? id;
  final String? remoteUrl;
  final String? localPath;
  final String name;
  final bool isImage;
  final int sizeBytes;
  final DateTime createdAt;

  bool get isRemote => remoteUrl != null;

  /// To'liq ekranda ko'rsatish / ochish uchun manba.
  String? get viewSource => remoteUrl ?? localPath;

  bool get existsLocal =>
      localPath != null && localPath!.isNotEmpty && File(localPath!).existsSync();

  String get formattedSize {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (sizeBytes <= 0) return '';
    return '${(sizeBytes / 1024).clamp(0.1, double.infinity).toStringAsFixed(1)} KB';
  }

  factory ConsumerUploadFile.local({
    required String path,
    required String name,
    required int sizeBytes,
  }) {
    return ConsumerUploadFile(
      name: name,
      isImage: isImagePath(name) || isImagePath(path),
      createdAt: DateTime.now(),
      localPath: path,
      sizeBytes: sizeBytes,
    );
  }

  factory ConsumerUploadFile.fromConsumerFile(ConsumerFile file) {
    final url = file.file ?? '';
    return ConsumerUploadFile(
      id: file.id,
      remoteUrl: url,
      name: fileNameFromUrl(url),
      isImage: isImagePath(url),
      createdAt: DateTime.tryParse(file.createdAt ?? '') ?? DateTime.now(),
    );
  }

  factory ConsumerUploadFile.fromCertificate(EgxuCertificate cert) {
    final url = cert.file ?? '';
    return ConsumerUploadFile(
      id: cert.id,
      remoteUrl: url,
      name: fileNameFromUrl(url),
      isImage: isImagePath(url),
      createdAt: DateTime.tryParse(cert.createdAt ?? '') ?? DateTime.now(),
    );
  }

  static bool isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('.png') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.webp');
  }

  static String fileNameFromUrl(String url) {
    if (url.isEmpty) return '-';
    try {
      final segments = Uri.parse(url).pathSegments;
      if (segments.isNotEmpty && segments.last.isNotEmpty) {
        return segments.last;
      }
    } catch (_) {}
    final cleaned = url.split('?').first;
    final parts = cleaned.split('/');
    return parts.isNotEmpty ? parts.last : url;
  }

  @override
  List<Object?> get props => [id, remoteUrl, localPath, name, isImage, sizeBytes, createdAt];
}
