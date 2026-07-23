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
  final String? localId;
  final String? certificateType;
  final String? certificateNumber;
  final String? issuedDate;
  final String? expiryDate;
  final String? warningLetter;
  final String? warningDate;
  final String? warningReason;
  final bool isActive;
  final List<ConsumerUploadFile> files;

  const EgxuCertificate({
    this.id,
    this.localId,
    this.certificateType,
    this.certificateNumber,
    this.issuedDate,
    this.expiryDate,
    this.warningLetter,
    this.warningDate,
    this.warningReason,
    this.isActive = true,
    this.files = const [],
  });

  factory EgxuCertificate.draft() {
    return EgxuCertificate(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      certificateType: 'first_certificate',
    );
  }

  factory EgxuCertificate.fromJson(Map<String, dynamic> json) {
    final files =
        (json['files'] as List?)
            ?.whereType<Map>()
            .map(
              (file) => ConsumerUploadFile.fromCertificateFile(
                Map<String, dynamic>.from(file),
              ),
            )
            .toList() ??
        <ConsumerUploadFile>[];
    final legacyUrl = json['file'] ?? json['egxu_image'];
    if (files.isEmpty && legacyUrl is String && legacyUrl.isNotEmpty) {
      files.add(
        ConsumerUploadFile.remote(
          id: json['id'],
          url: legacyUrl,
          createdAt: json['created_at'] ?? json['created_add'],
        ),
      );
    }
    return EgxuCertificate(
      id: json['id'],
      certificateType: json['certificate_type']?.toString(),
      certificateNumber: json['certificate_number']?.toString(),
      issuedDate: json['issued_date']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
      warningLetter: json['warning_letter']?.toString(),
      warningDate: json['warning_date']?.toString(),
      warningReason: json['warning_reason']?.toString(),
      isActive: json['is_active'] ?? true,
      files: files,
    );
  }

  EgxuCertificate copyWith({
    int? id,
    String? localId,
    String? certificateType,
    String? certificateNumber,
    String? issuedDate,
    String? expiryDate,
    String? warningLetter,
    String? warningDate,
    String? warningReason,
    bool? isActive,
    List<ConsumerUploadFile>? files,
  }) {
    return EgxuCertificate(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      certificateType: certificateType ?? this.certificateType,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      warningLetter: warningLetter ?? this.warningLetter,
      warningDate: warningDate ?? this.warningDate,
      warningReason: warningReason ?? this.warningReason,
      isActive: isActive ?? this.isActive,
      files: files ?? this.files,
    );
  }

  bool get hasMetadata => [
    certificateNumber,
    issuedDate,
    expiryDate,
    warningLetter,
    warningDate,
    warningReason,
  ].any((value) => value?.trim().isNotEmpty == true);
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
      localPath != null &&
      localPath!.isNotEmpty &&
      File(localPath!).existsSync();

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

  factory ConsumerUploadFile.remote({
    int? id,
    required String url,
    String? createdAt,
  }) {
    return ConsumerUploadFile(
      id: id,
      remoteUrl: url,
      name: fileNameFromUrl(url),
      isImage: isImagePath(url),
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
    );
  }

  factory ConsumerUploadFile.fromCertificateFile(Map<String, dynamic> json) {
    final url = json['file']?.toString() ?? '';
    return ConsumerUploadFile(
      id: json['id'],
      remoteUrl: url,
      name: fileNameFromUrl(url),
      isImage: isImagePath(url),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ConsumerUploadFile copyWith({
    int? id,
    String? remoteUrl,
    String? localPath,
    String? name,
    bool? isImage,
    int? sizeBytes,
    DateTime? createdAt,
  }) {
    return ConsumerUploadFile(
      id: id ?? this.id,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      localPath: localPath ?? this.localPath,
      name: name ?? this.name,
      isImage: isImage ?? this.isImage,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
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
  List<Object?> get props => [
    id,
    remoteUrl,
    localPath,
    name,
    isImage,
    sizeBytes,
    createdAt,
  ];
}
