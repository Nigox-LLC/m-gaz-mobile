class GrsHourlyFile {
  final int? id;
  final String? file;
  final bool? isActive;

  GrsHourlyFile({this.id, this.file, this.isActive});

  factory GrsHourlyFile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsHourlyFile();
    return GrsHourlyFile(id: json['id'], file: json['file'], isActive: json['is_active']);
  }
}