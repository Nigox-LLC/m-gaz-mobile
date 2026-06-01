import '../global/base_model.dart';

List<T>? _mapList<T>(
  Object? value,
  T Function(Map<String, dynamic>? json) fromJson,
) {
  if (value is! List) return null;
  return value
      .whereType<Map>()
      .map((item) => fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

class WorkingWithConsumersDetailModel {
  final int? id;
  final List<ConsumersEgxuItem>? egxuList;
  final Region? region;
  final District? district;
  final Employee? employee;
  final Consumers? consumers;
  final String? facial;
  final String? datetime;
  final int? excelId;

  WorkingWithConsumersDetailModel({
    this.id,
    this.egxuList,
    this.region,
    this.district,
    this.employee,
    this.consumers,
    this.facial,
    this.datetime,
    this.excelId,
  });

  factory WorkingWithConsumersDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WorkingWithConsumersDetailModel();

    return WorkingWithConsumersDetailModel(
      id: json['id'],
      egxuList: (json['egxu_list'] as List?)
          ?.map((e) => ConsumersEgxuItem.fromJson(e))
          .toList(),
      region: Region.fromJson(json['region']),
      district: District.fromJson(json['district']),
      employee: Employee.fromJson(json['employee']),
      consumers: Consumers.fromJson(json['consumers']),
      facial: json['facial'],
      datetime: json['datetime'],
      excelId: json['excel_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'egxu_list': egxuList?.map((e) => e.toJson()).toList(),
      'region': region?.toJson(),
      'district': district?.toJson(),
      'employee': employee?.toJson(),
      'consumers': consumers?.toJson(),
      'facial': facial,
      'datetime': datetime,
      'excel_id': excelId,
    };
  }
}

class ConsumersEgxuItem {
  final int? id;
  final ConsumerRelationEgxu? consumerRelationEgxu;
  final ConsumersCompanyInfo? companyInfo;
  final List<ConsumersGasEquipmentItem>? gasEquipmentList;
  final List<ConsumersRealItem>? real;
  final String? realRaw;
  final String? hourlyListIndicator;
  final List<ConsumersIndicatorImage>? indicatorImages;
  final String? indicatorImagesRaw;
  final String? hourlyFiles;
  final String? certificates;
  final ConsumersEgxuType? egxuType;
  final String? oneFactory;
  final String? twoFactory;
  final String? fromDate;
  final String? toDate;
  final bool? isActive;

  ConsumersEgxuItem({
    this.id,
    this.consumerRelationEgxu,
    this.companyInfo,
    this.gasEquipmentList,
    this.real,
    this.realRaw,
    this.hourlyListIndicator,
    this.indicatorImages,
    this.indicatorImagesRaw,
    this.hourlyFiles,
    this.certificates,
    this.egxuType,
    this.oneFactory,
    this.twoFactory,
    this.fromDate,
    this.toDate,
    this.isActive,
  });

  factory ConsumersEgxuItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersEgxuItem();

    return ConsumersEgxuItem(
      id: json['id'],
      consumerRelationEgxu: ConsumerRelationEgxu.fromJson(
        json['consumer_relation_egxu'],
      ),
      companyInfo: ConsumersCompanyInfo.fromJson(json['company_info']),
      gasEquipmentList: (json['gas_equipment_list'] as List?)
          ?.map((e) => ConsumersGasEquipmentItem.fromJson(e))
          .toList(),
      real: _mapList(json['real'], ConsumersRealItem.fromJson),
      realRaw: json['real'] is List ? null : json['real']?.toString(),
      hourlyListIndicator: json['hourly_list_indicator']?.toString(),
      indicatorImages: _mapList(
        json['indicator_images'],
        ConsumersIndicatorImage.fromJson,
      ),
      indicatorImagesRaw: json['indicator_images'] is List
          ? null
          : json['indicator_images']?.toString(),
      hourlyFiles: json['hourly_files'] is List
          ? null
          : json['hourly_files']?.toString(),
      certificates: json['certificates'] is List
          ? null
          : json['certificates']?.toString(),
      egxuType: ConsumersEgxuType.fromJson(json['egxu_type']),
      oneFactory: json['one_factory'],
      twoFactory: json['two_factory'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_relation_egxu': consumerRelationEgxu?.toJson(),
      'company_info': companyInfo?.toJson(),
      'gas_equipment_list': gasEquipmentList?.map((e) => e.toJson()).toList(),
      'real': real?.map((e) => e.toJson()).toList() ?? realRaw,
      'hourly_list_indicator': hourlyListIndicator,
      'indicator_images':
          indicatorImages?.map((e) => e.toJson()).toList() ??
          indicatorImagesRaw,
      'hourly_files': hourlyFiles,
      'certificates': certificates,
      'egxu_type': egxuType?.toJson(),
      'one_factory': oneFactory,
      'two_factory': twoFactory,
      'from_date': fromDate,
      'to_date': toDate,
      'is_active': isActive,
    };
  }
}

class ConsumerRelationEgxu {
  final int? id;
  final String? typeOfActivity;
  final int? typeOfActivityId;
  final String? gasNetworks;
  final int? gasNetworksId;
  final String? egxuConnectionPoint;
  final int? egxuConnectionPointId;
  final double? monthStartReading;
  final double? additionalGas;
  final double? violationGas;
  final double? additionalBalance;
  final double? monthEndReading;
  final double? readingDifference;
  final double? totalGas;
  final String? reasonsForViolations;
  final bool? grpExists;
  final double? grpLoss;
  final int? ghuIdNumber;
  final String? movGrpAfterEgxu;
  final String? gaz;
  final String? counterStatus;
  final bool? workActivity;
  final bool? isActive;

  ConsumerRelationEgxu({
    this.id,
    this.typeOfActivity,
    this.typeOfActivityId,
    this.gasNetworks,
    this.gasNetworksId,
    this.egxuConnectionPoint,
    this.egxuConnectionPointId,
    this.monthStartReading,
    this.additionalGas,
    this.violationGas,
    this.additionalBalance,
    this.monthEndReading,
    this.readingDifference,
    this.totalGas,
    this.reasonsForViolations,
    this.grpExists,
    this.grpLoss,
    this.ghuIdNumber,
    this.movGrpAfterEgxu,
    this.gaz,
    this.counterStatus,
    this.workActivity,
    this.isActive,
  });

  factory ConsumerRelationEgxu.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumerRelationEgxu();
    final typeOfActivityRaw = json['type_of_activity'];
    final gasNetworksRaw = json['gas_networks'];
    final egxuConnectionPointRaw = json['egxu_connection_point'];
    return ConsumerRelationEgxu(
      id: json['id'],
      typeOfActivity: _nameOrString(typeOfActivityRaw),
      typeOfActivityId:
          _intOrNull(json['type_of_activity_id']) ??
          (typeOfActivityRaw is Map
              ? _intOrNull(typeOfActivityRaw['id'])
              : null),
      gasNetworks: _nameOrString(gasNetworksRaw),
      gasNetworksId:
          _intOrNull(json['gas_networks_id']) ??
          (gasNetworksRaw is Map ? _intOrNull(gasNetworksRaw['id']) : null),
      egxuConnectionPoint: _nameOrString(egxuConnectionPointRaw),
      egxuConnectionPointId:
          _intOrNull(json['egxu_connection_point_id']) ??
          (egxuConnectionPointRaw is Map
              ? _intOrNull(egxuConnectionPointRaw['id'])
              : null),
      monthStartReading: (json['month_start_reading'] as num?)?.toDouble(),
      additionalGas: (json['additional_gas'] as num?)?.toDouble(),
      violationGas: (json['violation_gas'] as num?)?.toDouble(),
      additionalBalance: (json['additional_balance'] as num?)?.toDouble(),
      monthEndReading: (json['month_end_reading'] as num?)?.toDouble(),
      readingDifference: (json['reading_difference'] as num?)?.toDouble(),
      totalGas: (json['total_gas'] as num?)?.toDouble(),
      reasonsForViolations: json['reasons_for_violations'],
      grpExists: json['grp_exists'],
      grpLoss: (json['grp_loss'] as num?)?.toDouble(),
      ghuIdNumber: json['ghu_id_number'],
      movGrpAfterEgxu: json['mov_grp_after_egxu'],
      gaz: json['gaz'],
      counterStatus: json['counter_status'],
      workActivity: json['work_activity'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_of_activity': typeOfActivity,
      'type_of_activity_id': typeOfActivityId,
      'gas_networks': gasNetworks,
      'gas_networks_id': gasNetworksId,
      'egxu_connection_point': egxuConnectionPoint,
      'egxu_connection_point_id': egxuConnectionPointId,
      'month_start_reading': monthStartReading,
      'additional_gas': additionalGas,
      'violation_gas': violationGas,
      'additional_balance': additionalBalance,
      'month_end_reading': monthEndReading,
      'reading_difference': readingDifference,
      'total_gas': totalGas,
      'reasons_for_violations': reasonsForViolations,
      'grp_exists': grpExists,
      'grp_loss': grpLoss,
      'ghu_id_number': ghuIdNumber,
      'mov_grp_after_egxu': movGrpAfterEgxu,
      'gaz': gaz,
      'counter_status': counterStatus,
      'work_activity': workActivity,
      'is_active': isActive,
    };
  }

  static int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _nameOrString(Object? value) {
    if (value is Map) return value['name']?.toString();
    return value?.toString();
  }
}

class ConsumersLookup {
  final int? id;
  final String? name;

  ConsumersLookup({this.id, this.name});

  factory ConsumersLookup.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersLookup();
    return ConsumersLookup(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

typedef Ministry = ConsumersLookup;

class ConsumersCompanyInfo {
  final int? id;
  final ConsumersLookup? direction;
  final ConsumersLookup? grs;
  final ConsumersLookup? egxuIndustrialCollector;
  final ConsumersLookup? grsMeasurementDevices;
  final ConsumersLookup? grpTypes;
  final ConsumersLookup? neighborhood;
  final String? accountNumber;
  final String? contractNumber;
  final String? companyDirector;
  final Ministry? ministry;
  final String? contractDate;
  final String? contractEndDate;
  final String? companyTin;
  final String? phone;
  final String? email;
  final String? address;
  final String? typeConsumers;
  final String? season;
  final bool? isActive;
  final int? directionId;
  final int? ministryId;
  final int? grsId;
  final int? egxuIndustrialCollectorId;
  final int? grsMeasurementDevicesId;
  final int? grpTypesId;
  final int? neighborhoodId;

  ConsumersCompanyInfo({
    this.id,
    this.direction,
    this.grs,
    this.egxuIndustrialCollector,
    this.grsMeasurementDevices,
    this.grpTypes,
    this.neighborhood,
    this.accountNumber,
    this.contractNumber,
    this.companyDirector,
    this.ministry,
    this.contractDate,
    this.contractEndDate,
    this.companyTin,
    this.phone,
    this.email,
    this.address,
    this.typeConsumers,
    this.season,
    this.isActive,
    this.directionId,
    this.ministryId,
    this.grsId,
    this.egxuIndustrialCollectorId,
    this.grsMeasurementDevicesId,
    this.grpTypesId,
    this.neighborhoodId,
  });

  factory ConsumersCompanyInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersCompanyInfo();
    return ConsumersCompanyInfo(
      id: json['id'],
      direction: ConsumersLookup.fromJson(json['direction']),
      grs: ConsumersLookup.fromJson(json['grs']),
      egxuIndustrialCollector: ConsumersLookup.fromJson(
        json['egxu_industrial_collector'],
      ),
      grsMeasurementDevices: ConsumersLookup.fromJson(
        json['grs_measurement_devices'],
      ),
      grpTypes: ConsumersLookup.fromJson(json['grp_types']),
      neighborhood: ConsumersLookup.fromJson(json['neighborhood']),
      accountNumber: json['account_number'],
      contractNumber: json['contract_number'],
      companyDirector: json['company_director'],
      ministry: Ministry.fromJson(json['ministry']),
      contractDate: json['contract_date'],
      contractEndDate: json['contract_end_date'],
      companyTin: json['company_tin'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      typeConsumers: json['type_consumers'],
      season: json['season'],
      isActive: json['is_active'],
      directionId: ConsumerRelationEgxu._intOrNull(json['direction_id']),
      ministryId: ConsumerRelationEgxu._intOrNull(json['ministry_id']),
      grsId: ConsumerRelationEgxu._intOrNull(json['grs_id']),
      egxuIndustrialCollectorId: ConsumerRelationEgxu._intOrNull(
        json['egxu_industrial_collector_id'],
      ),
      grsMeasurementDevicesId: ConsumerRelationEgxu._intOrNull(
        json['grs_measurement_devices_id'],
      ),
      grpTypesId: ConsumerRelationEgxu._intOrNull(json['grp_types_id']),
      neighborhoodId: ConsumerRelationEgxu._intOrNull(json['neighborhood_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direction': direction?.toJson(),
      'grs': grs?.toJson(),
      'egxu_industrial_collector': egxuIndustrialCollector?.toJson(),
      'grs_measurement_devices': grsMeasurementDevices?.toJson(),
      'grp_types': grpTypes?.toJson(),
      'neighborhood': neighborhood?.toJson(),
      'account_number': accountNumber,
      'contract_number': contractNumber,
      'company_director': companyDirector,
      'ministry': ministry?.toJson(),
      'contract_date': contractDate,
      'contract_end_date': contractEndDate,
      'company_tin': companyTin,
      'phone': phone,
      'email': email,
      'address': address,
      'type_consumers': typeConsumers,
      'season': season,
      'is_active': isActive,
      'direction_id': directionId,
      'ministry_id': ministryId,
      'grs_id': grsId,
      'egxu_industrial_collector_id': egxuIndustrialCollectorId,
      'grs_measurement_devices_id': grsMeasurementDevicesId,
      'grp_types_id': grpTypesId,
      'neighborhood_id': neighborhoodId,
    };
  }
}

class ConsumersGasEquipment {
  final int? id;
  final String? name;
  final double? hourlyGasConsumption;

  ConsumersGasEquipment({this.id, this.name, this.hourlyGasConsumption});

  factory ConsumersGasEquipment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersGasEquipment();
    return ConsumersGasEquipment(
      id: json['id'],
      name: json['name'],
      hourlyGasConsumption: (json['hourly_gas_consumption'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hourly_gas_consumption': hourlyGasConsumption,
    };
  }
}

class ConsumersGasEquipmentItem {
  final int? id;
  final int? quantity;
  final double? hourlyGasConsumption;
  final ConsumersGasEquipment? gasEquipment;

  ConsumersGasEquipmentItem({
    this.id,
    this.quantity,
    this.hourlyGasConsumption,
    this.gasEquipment,
  });

  factory ConsumersGasEquipmentItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersGasEquipmentItem();
    return ConsumersGasEquipmentItem(
      id: json['id'],
      quantity: json['quantity'],
      hourlyGasConsumption: (json['hourly_gas_consumption'] as num?)
          ?.toDouble(),
      gasEquipment: ConsumersGasEquipment.fromJson(json['gas_equipment']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'hourly_gas_consumption': hourlyGasConsumption,
      'gas_equipment': gasEquipment?.toJson(),
    };
  }
}

class ConnectionPoint {
  final int? id;
  final String? name;

  ConnectionPoint({this.id, this.name});

  factory ConnectionPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConnectionPoint();
    return ConnectionPoint(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ConsumersRealItem {
  final int? id;
  final Employee? employee;
  final ConnectionPoint? connectionPoint;
  final String? realNumber;
  final String? installedDate;
  final String? sealInstalledLocation;
  final String? qrCode;
  final bool? removeSeal;
  final String? realReasonRemoval;
  final String? realRemovalDate;
  final double? latitude;
  final double? longitude;
  final String? created;
  final bool? isActive;
  final String? realRemovalUser;

  ConsumersRealItem({
    this.id,
    this.employee,
    this.connectionPoint,
    this.realNumber,
    this.installedDate,
    this.sealInstalledLocation,
    this.qrCode,
    this.removeSeal,
    this.realReasonRemoval,
    this.realRemovalDate,
    this.latitude,
    this.longitude,
    this.created,
    this.isActive,
    this.realRemovalUser,
  });

  factory ConsumersRealItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersRealItem();
    return ConsumersRealItem(
      id: json['id'],
      employee: Employee.fromJson(json['employee']),
      connectionPoint: ConnectionPoint.fromJson(json['connection_point']),
      realNumber: json['real_number'],
      installedDate: json['installed_date'],
      sealInstalledLocation: json['seal_installed_location'],
      qrCode: json['qr_code'],
      removeSeal: json['remove_seal'],
      realReasonRemoval: json['real_reason_removal'],
      realRemovalDate: json['real_removal_date'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      created: json['created'],
      isActive: json['is_active'],
      realRemovalUser: json['real_removal_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee': employee?.toJson(),
      'connection_point': connectionPoint?.toJson(),
      'real_number': realNumber,
      'installed_date': installedDate,
      'seal_installed_location': sealInstalledLocation,
      'qr_code': qrCode,
      'remove_seal': removeSeal,
      'real_reason_removal': realReasonRemoval,
      'real_removal_date': realRemovalDate,
      'latitude': latitude,
      'longitude': longitude,
      'created': created,
      'is_active': isActive,
      'real_removal_user': realRemovalUser,
    };
  }
}

class ConsumersIndicatorImage {
  final int? id;
  final String? image;

  ConsumersIndicatorImage({this.id, this.image});

  factory ConsumersIndicatorImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersIndicatorImage();
    return ConsumersIndicatorImage(id: json['id'], image: json['image']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'image': image};
  }
}

class ConsumersEgxuType {
  final int? id;
  final String? name;
  final String? photo;
  final String? code;

  ConsumersEgxuType({this.id, this.name, this.photo, this.code});

  factory ConsumersEgxuType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersEgxuType();
    return ConsumersEgxuType(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'photo': photo, 'code': code};
  }
}
