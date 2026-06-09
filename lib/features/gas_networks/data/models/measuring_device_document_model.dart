import '../../domain/entities/measuring_device_document.dart';

/// Data-layer model for a measuring-device document. Extends the domain entity
/// and adds JSON parsing. Handles all three list shapes — the type-specific
/// label is read from whichever key the endpoint provides.
class MeasuringDeviceDocumentModel extends MeasuringDeviceDocument {
  const MeasuringDeviceDocumentModel({
    required super.id,
    required super.region,
    required super.district,
    required super.employee,
    required super.gtsh,
    required super.datetime,
    super.deviceLabel,
  });

  factory MeasuringDeviceDocumentModel.fromJson(Map<String, dynamic> json) {
    return MeasuringDeviceDocumentModel(
      id: json['id'] as int,
      region: json['region']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
      gtsh: json['gtsh']?.toString() ?? '',
      datetime: DateTime.parse(json['datetime'] as String),
      deviceLabel:
          (json['industrial_collectors'] ?? json['techno_measuring_devices'])
              ?.toString(),
    );
  }
}
