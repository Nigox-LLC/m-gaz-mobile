import '../../domain/entities/measuring_device_page.dart';
import 'measuring_device_document_model.dart';

/// Data-layer model for a paginated page of measuring-device documents.
/// Mirrors the DRF pagination envelope (`count` / `next` / `previous` /
/// `results`).
class MeasuringDevicePageModel extends MeasuringDevicePage {
  const MeasuringDevicePageModel({required super.items, super.nextUrl});

  factory MeasuringDevicePageModel.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? <dynamic>[])
        .map((e) =>
            MeasuringDeviceDocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return MeasuringDevicePageModel(
      items: results,
      nextUrl: json['next'] as String?,
    );
  }
}
