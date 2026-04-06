import '../global/base_model.dart';

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
  final List<ConsumersIndicatorImage>? indicatorImages;
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
    this.indicatorImages,
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
      consumerRelationEgxu:
      ConsumerRelationEgxu.fromJson(json['consumer_relation_egxu']),
      companyInfo: ConsumersCompanyInfo.fromJson(json['company_info']),
      gasEquipmentList: (json['gas_equipment_list'] as List?)
          ?.map((e) => ConsumersGasEquipmentItem.fromJson(e))
          .toList(),
      real: (json['real'] as List?)
          ?.map((e) => ConsumersRealItem.fromJson(e))
          .toList(),
      indicatorImages: (json['indicator_images'] as List?)
          ?.map((e) => ConsumersIndicatorImage.fromJson(e))
          .toList(),
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
      'gas_equipment_list':
      gasEquipmentList?.map((e) => e.toJson()).toList(),
      'real': real?.map((e) => e.toJson()).toList(),
      'indicator_images':
      indicatorImages?.map((e) => e.toJson()).toList(),
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
  final double? additionalGas;
  final double? violationGas;
  final bool? isActive;

  ConsumerRelationEgxu({
    this.id,
    this.additionalGas,
    this.violationGas,
    this.isActive,
  });

  factory ConsumerRelationEgxu.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumerRelationEgxu();
    return ConsumerRelationEgxu(
      id: json['id'],
      additionalGas: (json['additional_gas'] as num?)?.toDouble(),
      violationGas: (json['violation_gas'] as num?)?.toDouble(),
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'additional_gas': additionalGas,
      'violation_gas': violationGas,
      'is_active': isActive,
    };
  }
}

class ConsumersCompanyInfo {
  final int? id;
  final String? accountNumber;
  final String? contractNumber;
  final String? companyDirector;

  ConsumersCompanyInfo({
    this.id,
    this.accountNumber,
    this.contractNumber,
    this.companyDirector,
  });

  factory ConsumersCompanyInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersCompanyInfo();
    return ConsumersCompanyInfo(
      id: json['id'],
      accountNumber: json['account_number'],
      contractNumber: json['contract_number'],
      companyDirector: json['company_director'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_number': accountNumber,
      'contract_number': contractNumber,
      'company_director': companyDirector,
    };
  }
}

class ConsumersGasEquipmentItem {
  final int? id;
  final int? quantity;

  ConsumersGasEquipmentItem({this.id, this.quantity});

  factory ConsumersGasEquipmentItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersGasEquipmentItem();
    return ConsumersGasEquipmentItem(
      id: json['id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
    };
  }
}

class ConsumersRealItem {
  final int? id;
  final String? realNumber;

  ConsumersRealItem({this.id, this.realNumber});

  factory ConsumersRealItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersRealItem();
    return ConsumersRealItem(
      id: json['id'],
      realNumber: json['real_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'real_number': realNumber,
    };
  }
}

class ConsumersIndicatorImage {
  final int? id;
  final String? image;

  ConsumersIndicatorImage({this.id, this.image});

  factory ConsumersIndicatorImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersIndicatorImage();
    return ConsumersIndicatorImage(
      id: json['id'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
    };
  }
}

class ConsumersEgxuType {
  final int? id;
  final String? name;

  ConsumersEgxuType({this.id, this.name});

  factory ConsumersEgxuType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ConsumersEgxuType();
    return ConsumersEgxuType(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}