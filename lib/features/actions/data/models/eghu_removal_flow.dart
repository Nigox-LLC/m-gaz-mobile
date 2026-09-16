class EghuTargetInfo {
  const EghuTargetInfo({required this.egxus});

  final List<EghuTargetInfoEgxu> egxus;

  factory EghuTargetInfo.fromJson(Map<String, dynamic> json) {
    final rawList = json['egxu_list'] ?? json['egxus'];
    return EghuTargetInfo(
      egxus: rawList is List
          ? rawList
                .whereType<Map>()
                .map(
                  (item) => EghuTargetInfoEgxu.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.id != null)
                .toList()
          : const [],
    );
  }
}

class EghuTargetInfoEgxu {
  const EghuTargetInfoEgxu({
    required this.id,
    this.typeName,
    this.oneFactory,
    this.twoFactory,
    this.reals = const [],
  });

  final int? id;
  final String? typeName;
  final String? oneFactory;
  final String? twoFactory;
  final List<EghuTargetInfoReal> reals;

  factory EghuTargetInfoEgxu.fromJson(Map<String, dynamic> json) {
    final type = _asMap(json['egxu_type']);
    final rawReals = json['reals'] ?? json['real_numbers'] ?? json['real'];

    return EghuTargetInfoEgxu(
      id: _asInt(json['egxu_id'] ?? json['id']),
      typeName: _asText([
        json['egxu_type_name'],
        type?['name'],
        json['type_name'],
      ]),
      oneFactory: _asText([json['one_factory']]),
      twoFactory: _asText([json['two_factory']]),
      reals: rawReals is List
          ? rawReals
                .whereType<Map>()
                .map(
                  (item) => EghuTargetInfoReal.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class EghuTargetInfoReal {
  const EghuTargetInfoReal({
    required this.id,
    required this.number,
    this.status,
    this.installedDate,
    this.sealLocation,
    this.installedLocation,
    this.installedBy,
  });

  final int? id;
  final String number;
  final String? status;
  final DateTime? installedDate;
  final String? sealLocation;
  final String? installedLocation;
  final String? installedBy;

  factory EghuTargetInfoReal.fromJson(Map<String, dynamic> json) {
    final real = _asMap(json['real']);
    final place = _asMap(
      json['seal_location'] ??
          json['seal_installed_location'] ??
          json['seal_initalled_location'],
    );

    return EghuTargetInfoReal(
      id: _asInt(json['id'] ?? real?['id']),
      number:
          _asText([
            json['real_number'],
            json['real_number_value'],
            real?['real_number'],
          ]) ??
          '-',
      status: _asText([json['seal_status'], json['status']]),
      installedDate: DateTime.tryParse(
        _asText([
              json['installed_date'],
              json['from_date'],
              real?['installed_date'],
            ]) ??
            '',
      ),
      sealLocation: _asText([
        json['seal_location'],
        json['seal_installed_location'],
        place?['name'],
        json['seal_location_name'],
        json['seal_installed_location_name'],
      ]),
      installedLocation: _asText([json['installed_location']]),
      installedBy: _asText([json['installed_by']]),
    );
  }
}

class EghuStampRemovalRequest {
  const EghuStampRemovalRequest({
    required this.datetime,
    required this.documentId,
    required this.egxuId,
    required this.stamp,
    this.regionId,
    this.districtId,
    this.typeOfActivityId,
    this.employeeId,
    this.fullName,
    this.organization,
  });

  final DateTime datetime;
  final int documentId;
  final int egxuId;
  final EghuTargetInfoReal stamp;
  final int? regionId;
  final int? districtId;
  final int? typeOfActivityId;
  final int? employeeId;
  final String? fullName;
  final String? organization;

  Map<String, Object?> toJson() {
    final real = <String, Object?>{
      'real_number': stamp.number.trim(),
      if (stamp.status?.trim().isNotEmpty == true) 'seal_status': stamp.status,
      if (stamp.installedDate != null)
        'from_date': _dateOnly(stamp.installedDate!),
      if (stamp.sealLocation?.trim().isNotEmpty == true)
        'seal_location': stamp.sealLocation,
      if (stamp.installedLocation?.trim().isNotEmpty == true)
        'installed_location': stamp.installedLocation,
      if (stamp.installedBy?.trim().isNotEmpty == true)
        'installed_by': stamp.installedBy,
    };

    return {
      'datetime': datetime.toUtc().toIso8601String(),
      if (regionId != null) 'region': regionId,
      if (districtId != null) 'district': districtId,
      if (typeOfActivityId != null) 'type_of_activity': typeOfActivityId,
      'document_type': 'consumer',
      if (employeeId != null) 'employee': employeeId,
      if (fullName?.trim().isNotEmpty == true) 'full_name': fullName!.trim(),
      if (organization?.trim().isNotEmpty == true)
        'organization': organization!.trim(),
      'document_id': documentId,
      'list': [
        {
          'egxu_id': egxuId,
          'removal_reason': 'for_repair',
          'gas_usage_status': 'tagged',
          'replacement_reason': "Tamg'ani yechib olish",
          'real_numbers': [real],
        },
      ],
    };
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String? _asText(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text != 'null') return text;
  }
  return null;
}

String _dateOnly(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
