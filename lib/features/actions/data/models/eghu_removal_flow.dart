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
    this.gasEquipments = const [],
    this.reals = const [],
  });

  final int? id;
  final String? typeName;
  final String? oneFactory;
  final String? twoFactory;
  final List<EghuTargetInfoGasEquipment> gasEquipments;
  final List<EghuTargetInfoReal> reals;

  factory EghuTargetInfoEgxu.fromJson(Map<String, dynamic> json) {
    final type = _asMap(json['egxu_type']);
    final rawGasEquipments =
        json['gas_equipments'] ??
        json['gas_equipment_list'] ??
        json['gas_equipment'];
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
      gasEquipments: rawGasEquipments is List
          ? rawGasEquipments
                .whereType<Map>()
                .map(
                  (item) => EghuTargetInfoGasEquipment.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((item) => item.id != null || item.name != null)
                .toList()
          : const [],
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

class EghuTargetInfoGasEquipment {
  const EghuTargetInfoGasEquipment({
    this.id,
    this.name,
    this.hourlyGasConsumption = 0,
    this.operatingHours,
    this.quantity = 1,
  });

  final int? id;
  final String? name;
  final double hourlyGasConsumption;
  final double? operatingHours;
  final int quantity;

  factory EghuTargetInfoGasEquipment.fromJson(Map<String, dynamic> json) {
    final equipment = _asMap(json['gas_equipment']);
    return EghuTargetInfoGasEquipment(
      id: _asInt([
        json['gas_equipment_id'],
        json['gas_equipment'],
        equipment?['id'],
        json['id'],
      ]),
      name: _asText([json['equipment_name'], json['name'], equipment?['name']]),
      hourlyGasConsumption: _asDouble([
        json['hourly_gas_consumption'],
        equipment?['hourly_gas_consumption'],
      ]),
      operatingHours: _asNullableDouble([
        json['operating_hours'],
        json['hours'],
      ]),
      quantity: _asInt([json['quantity']]) ?? 1,
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
    this.stamp,
    this.regionId,
    this.districtId,
    this.typeOfActivityId,
    this.employeeId,
    this.fullName,
    this.organization,
    this.removalReason = 'for_repair',
    this.gasUsageStatus = 'tagged',
    this.replacementReason = "Tamg'ani yechib olish",
    this.gasEquipments = const [],
    this.realNumbers = const [],
  });

  final DateTime datetime;
  final int documentId;
  final int egxuId;
  final EghuTargetInfoReal? stamp;
  final int? regionId;
  final int? districtId;
  final int? typeOfActivityId;
  final int? employeeId;
  final String? fullName;
  final String? organization;
  final String removalReason;
  final String gasUsageStatus;
  final String replacementReason;
  final List<EghuRemovalGasEquipment> gasEquipments;
  final List<EghuTargetInfoReal> realNumbers;

  Map<String, Object?> toJson() {
    final realNumbersToSend = [...realNumbers, if (stamp != null) stamp!];

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
          'removal_reason': removalReason,
          'gas_usage_status': gasUsageStatus,
          'replacement_reason': replacementReason,
          if (gasEquipments.isNotEmpty)
            'gas_equipments': gasEquipments
                .map((item) => item.toJson())
                .toList(),
          if (realNumbersToSend.isNotEmpty)
            'real_numbers': realNumbersToSend.map(_realToJson).toList(),
        },
      ],
    };
  }

  Map<String, Object?> _realToJson(EghuTargetInfoReal stamp) {
    return {
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
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _asInt(Object? value) {
  if (value is Iterable) {
    for (final item in value) {
      final parsed = _asInt(item);
      if (parsed != null) return parsed;
    }
    return null;
  }
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double _asDouble(Iterable<Object?> values) {
  for (final value in values) {
    final parsed = _asNullableDouble([value]);
    if (parsed != null) return parsed;
  }
  return 0;
}

double? _asNullableDouble(Iterable<Object?> values) {
  for (final value in values) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(
      value?.toString().replaceAll(',', '.') ?? '',
    );
    if (parsed != null) return parsed;
  }
  return null;
}

class EghuRemovalGasEquipment {
  const EghuRemovalGasEquipment({
    required this.id,
    required this.name,
    required this.hourlyGasConsumption,
    required this.operatingHours,
    this.quantity = 1,
  });

  final int id;
  final String name;
  final double hourlyGasConsumption;
  final double operatingHours;
  final int quantity;

  Map<String, Object?> toJson() => {
    'gas_equipment': id,
    'equipment_name': name,
    'hourly_gas_consumption': hourlyGasConsumption,
    'operating_hours': operatingHours,
    'quantity': quantity,
  };
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
