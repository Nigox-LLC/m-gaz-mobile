import 'package:equatable/equatable.dart';

class EghuRemovalDetail extends Equatable {
  const EghuRemovalDetail({
    required this.id,
    required this.documentType,
    this.consumerId,
    this.consumerName,
    this.egxuId,
    this.egxuSerialNumber,
    this.reason,
    this.otherReason,
    this.sealStatus,
    this.gasSupplyStopped,
    this.reals = const [],
    this.akts = const [],
  });

  final int id;
  final String documentType;
  final int? consumerId;
  final String? consumerName;
  final int? egxuId;
  final String? egxuSerialNumber;
  final String? reason;
  final String? otherReason;
  final String? sealStatus;
  final String? gasSupplyStopped;
  final List<EghuRemovalReal> reals;
  final List<EghuRemovalAkt> akts;

  factory EghuRemovalDetail.fromJson(Map<String, dynamic> json) {
    final consumer = _asMap(json['consumer']);
    final egxu = _asMap(json['egxu']);
    final realsRaw = json['reals'];
    final aktsRaw = json['akts'];

    return EghuRemovalDetail(
      id: _parseInt(json['id']) ?? 0,
      documentType: json['document_type']?.toString() ?? '',
      consumerId: _parseInt(consumer?['id']) ?? _parseInt(json['consumer']),
      consumerName: _firstText([
        consumer?['name'],
        consumer?['consumers'],
        consumer?['full_name'],
      ]),
      egxuId: _parseInt(egxu?['id']) ?? _parseInt(json['egxu']),
      egxuSerialNumber: _firstText([
        egxu?['serial_number'],
        egxu?['one_factory'],
        egxu?['two_factory'],
      ]),
      reason: json['reason']?.toString(),
      otherReason: json['other_reason']?.toString(),
      sealStatus: json['seal_status']?.toString(),
      gasSupplyStopped: json['gas_supply_stopped']?.toString(),
      reals: realsRaw is List
          ? realsRaw
                .whereType<Map>()
                .map(
                  (item) =>
                      EghuRemovalReal.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      akts: aktsRaw is List
          ? aktsRaw
                .whereType<Map>()
                .map(
                  (item) =>
                      EghuRemovalAkt.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    documentType,
    consumerId,
    consumerName,
    egxuId,
    egxuSerialNumber,
    reason,
    otherReason,
    sealStatus,
    gasSupplyStopped,
    reals,
    akts,
  ];
}

class EghuRemovalReal extends Equatable {
  const EghuRemovalReal({
    required this.id,
    this.realNumberValue,
    this.installedDate,
    this.installationPlaceId,
    this.installationPlaceName,
  });

  final int? id;
  final String? realNumberValue;
  final String? installedDate;
  final int? installationPlaceId;
  final String? installationPlaceName;

  factory EghuRemovalReal.fromJson(Map<String, dynamic> json) {
    final real = _asMap(json['real']);
    final realNumber = _asMap(real?['real_number']);
    final placeRaw =
        json['seal_initalled_location'] ?? real?['seal_initalled_location'];
    final placeMap = _asMap(placeRaw);

    return EghuRemovalReal(
      id: _parseInt(json['id']),
      realNumberValue: _firstText([
        json['real_number_value'],
        realNumber?['real_number'],
        real?['real_number'],
      ]),
      installedDate: _firstText([
        json['installed_date'],
        real?['installed_date'],
      ]),
      installationPlaceId: placeMap != null
          ? _parseInt(placeMap['id'])
          : _parseInt(placeRaw),
      installationPlaceName: _firstText([
        placeMap?['name'],
        json['seal_initalled_location_name'],
        json['seal_initalled_location_display'],
      ]),
    );
  }

  @override
  List<Object?> get props => [
    id,
    realNumberValue,
    installedDate,
    installationPlaceId,
    installationPlaceName,
  ];
}

class EghuRemovalAkt extends Equatable {
  const EghuRemovalAkt({required this.id, this.fileUrl, this.aktFileType});

  final int? id;
  final String? fileUrl;
  final String? aktFileType;

  factory EghuRemovalAkt.fromJson(Map<String, dynamic> json) {
    return EghuRemovalAkt(
      id: _parseInt(json['id']),
      fileUrl: json['file']?.toString(),
      aktFileType: json['akt_file_type']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, fileUrl, aktFileType];
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _firstText(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text != 'null') return text;
  }
  return null;
}
