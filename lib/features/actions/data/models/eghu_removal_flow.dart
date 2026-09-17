class EghuTargetInfo {
  const EghuTargetInfo({
    required this.egxus,
    this.targetName,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
    this.hasRemovedEgxu,
    this.canReinstall,
    this.pendingRemovals = const [],
  });

  final List<EghuTargetInfoEgxu> egxus;
  final String? targetName;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;
  final bool? hasRemovedEgxu;
  final bool? canReinstall;
  final List<Map<String, dynamic>> pendingRemovals;

  factory EghuTargetInfo.fromJson(Map<String, dynamic> json) {
    final rawList = json['egxu_list'] ?? json['egxus'];
    return EghuTargetInfo(
      targetName: _asText([json['target_name']]),
      regionId: _asInt(json['region_id'] ?? _asMap(json['region'])?['id']),
      regionName: _asText([
        json['region_name'],
        _asMap(json['region'])?['name'],
      ]),
      districtId: _asInt(
        json['district_id'] ?? _asMap(json['district'])?['id'],
      ),
      districtName: _asText([
        json['district_name'],
        _asMap(json['district'])?['name'],
      ]),
      hasRemovedEgxu: _asBool(json['has_removed_egxu']),
      canReinstall: _asBool(json['can_reinstall']),
      pendingRemovals: json['pending_removals'] is List
          ? (json['pending_removals'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : const [],
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
    this.isRemoved = false,
    this.isActive = true,
    this.status,
    this.statusDisplay,
    this.gasEquipments = const [],
    this.reals = const [],
  });

  final int? id;
  final String? typeName;
  final String? oneFactory;
  final String? twoFactory;
  final bool isRemoved;
  final bool? isActive;
  final String? status;
  final String? statusDisplay;
  final List<EghuTargetInfoGasEquipment> gasEquipments;
  final List<EghuTargetInfoReal> reals;

  /// An EGHU remains a valid removal target even when it has no active seals.
  bool get canBeRemoved => id != null;

  factory EghuTargetInfoEgxu.fromJson(Map<String, dynamic> json) {
    final egxu = _asMap(json['egxu']);
    final type = _asMap(json['egxu_type']);
    final rawGasEquipments =
        json['gas_equipments'] ??
        json['gas_equipment_list'] ??
        json['gas_equipment'] ??
        egxu?['gas_equipments'] ??
        egxu?['gas_equipment_list'];
    final rawReals =
        json['reals'] ??
        json['real_numbers'] ??
        json['real'] ??
        egxu?['reals'] ??
        egxu?['real_numbers'] ??
        egxu?['real'];

    return EghuTargetInfoEgxu(
      id: _asInt([egxu?['id'], json['egxu_id'], json['egxu'], json['id']]),
      typeName: _asText([
        json['egxu_type_name'],
        type?['name'],
        json['type_name'],
        egxu?['egxu_type_name'],
        _asMap(egxu?['egxu_type'])?['name'],
        egxu?['type_name'],
      ]),
      oneFactory: _asText([json['one_factory'], egxu?['one_factory']]),
      twoFactory: _asText([json['two_factory'], egxu?['two_factory']]),
      isRemoved: _asBool(json['is_removed'] ?? egxu?['is_removed']) ?? false,
      isActive: _asBool(json['is_active'] ?? egxu?['is_active']),
      status: _asText([
        json['egxu_status'],
        json['status'],
        egxu?['egxu_status'],
        egxu?['status'],
      ]),
      statusDisplay: _asText([
        json['egxu_status_display'],
        json['status_display'],
        egxu?['egxu_status_display'],
        egxu?['status_display'],
      ]),
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
    this.totalConsumed,
    this.quantity = 1,
  });

  final int? id;
  final String? name;
  final double hourlyGasConsumption;
  final double? operatingHours;
  final double? totalConsumed;
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
      totalConsumed: _asNullableDouble([json['total_consumed']]),
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
    this.removeSeal,
  });

  final int? id;
  final String number;
  final String? status;
  final DateTime? installedDate;
  final String? sealLocation;
  final String? installedLocation;
  final String? installedBy;
  final bool? removeSeal;

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
      removeSeal: _asBool(json['remove_seal'] ?? json['is_removed']),
    );
  }
}

class EghuStampRemovalRequest {
  const EghuStampRemovalRequest({
    required this.datetime,
    required this.documentId,
    required this.egxuId,
    this.regionId,
    this.districtId,
    this.typeOfActivityId,
    this.employeeId,
    this.fullName,
    this.organization,
    this.documentNumber,
    this.removalReason = 'for_repair',
    this.gasUsageStatus = 'tagged',
    this.replacementReason = "Tamg'ani yechib olish",
    this.realNumbers = const [],
  });

  final DateTime datetime;
  final int documentId;
  final int egxuId;
  final int? regionId;
  final int? districtId;
  final int? typeOfActivityId;
  final int? employeeId;
  final String? fullName;
  final String? organization;
  final String? documentNumber;
  final String removalReason;
  final String gasUsageStatus;
  final String replacementReason;
  final List<EghuTargetInfoReal> realNumbers;

  Map<String, Object?> toJson() {
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
      if (documentNumber?.trim().isNotEmpty == true)
        'document_number': documentNumber!.trim(),
      'document_id': documentId,
      'list': [
        {
          'egxu_id': egxuId,
          'removal_reason': removalReason,
          'gas_usage_status': gasUsageStatus,
          'replacement_reason': replacementReason,
        },
      ],
      if (realNumbers.isNotEmpty)
        'real_numbers': realNumbers.map(_realToJson).toList(),
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

class EghuReinstallationRequest {
  const EghuReinstallationRequest({
    required this.removalId,
    required this.datetime,
    required this.consumerDocumentId,
    required this.installedEghuTypeId,
    this.regionId,
    this.districtId,
    this.typeOfActivityId,
    this.removalReason,
    this.documentNumber,
    this.oneFactory,
    this.twoFactory,
    this.employeeId,
    this.organization,
    this.notes,
  });

  final int removalId;
  final DateTime datetime;
  final int consumerDocumentId;
  final int installedEghuTypeId;
  final int? regionId;
  final int? districtId;
  final int? typeOfActivityId;
  final String? removalReason;
  final String? documentNumber;
  final String? oneFactory;
  final String? twoFactory;
  final int? employeeId;
  final String? organization;
  final String? notes;

  Map<String, Object?> toJson() {
    return {
      'removal': removalId,
      'datetime': datetime.toUtc().toIso8601String(),
      if (regionId != null) 'region': regionId,
      if (districtId != null) 'district': districtId,
      if (typeOfActivityId != null) 'type_of_activity': typeOfActivityId,
      'document_type': 'consumer',
      'consumer_document': consumerDocumentId,
      if (removalReason?.trim().isNotEmpty == true)
        'removal_reason': removalReason!.trim(),
      if (documentNumber?.trim().isNotEmpty == true)
        'document_number': documentNumber!.trim(),
      if (oneFactory?.trim().isNotEmpty == true)
        'one_factory': oneFactory!.trim(),
      if (twoFactory?.trim().isNotEmpty == true)
        'two_factory': twoFactory!.trim(),
      'installed_egxu_type': installedEghuTypeId,
      if (employeeId != null) 'employee': employeeId,
      if (organization?.trim().isNotEmpty == true)
        'organization': organization!.trim(),
      if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
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

String? _asText(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text != 'null') return text;
  }
  return null;
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

String _dateOnly(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
