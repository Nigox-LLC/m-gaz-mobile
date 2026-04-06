import 'package:equatable/equatable.dart';

class ConsumerCompanyInfo extends Equatable {
  final String accountNumber;
  final String contractNumber;
  final String contractDate;
  final String contractEndDate;
  final String companyDirector;
  final String companyTin;
  final String phone;
  final String email;
  final String address;
  final String typeConsumers;
  final int directionId;
  final int ministryId;
  final int grsId;
  final int egxuIndustrialCollectorId;
  final int grsMeasurementDevicesId;
  final int grpTypesId;
  final int neighborhoodId;
  final String season;

  const ConsumerCompanyInfo({
    required this.accountNumber,
    required this.contractNumber,
    required this.contractDate,
    required this.contractEndDate,
    required this.companyDirector,
    required this.companyTin,
    required this.phone,
    required this.email,
    required this.address,
    required this.typeConsumers,
    required this.directionId,
    required this.ministryId,
    required this.grsId,
    required this.egxuIndustrialCollectorId,
    required this.grsMeasurementDevicesId,
    required this.grpTypesId,
    required this.neighborhoodId,
    required this.season,
  });

  factory ConsumerCompanyInfo.fromJson(Map<String, dynamic> json) {
    return ConsumerCompanyInfo(
      accountNumber: json['account_number'] as String,
      contractNumber: json['contract_number'] as String,
      contractDate: json['contract_date'] as String,
      contractEndDate: json['contract_end_date'] as String,
      companyDirector: json['company_director'] as String,
      companyTin: json['company_tin'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      typeConsumers: json['type_consumers'] as String,
      directionId: json['direction_id'] as int,
      ministryId: json['ministry_id'] as int,
      grsId: json['grs_id'] as int,
      egxuIndustrialCollectorId: json['egxu_industrial_collector_id'] as int,
      grsMeasurementDevicesId: json['grs_measurement_devices_id'] as int,
      grpTypesId: json['grp_types_id'] as int,
      neighborhoodId: json['neighborhood_id'] as int,
      season: json['season'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_number': accountNumber,
      'contract_number': contractNumber,
      'contract_date': contractDate,
      'contract_end_date': contractEndDate,
      'company_director': companyDirector,
      'company_tin': companyTin,
      'phone': phone,
      'email': email,
      'address': address,
      'type_consumers': typeConsumers,
      'direction_id': directionId,
      'ministry_id': ministryId,
      'grs_id': grsId,
      'egxu_industrial_collector_id': egxuIndustrialCollectorId,
      'grs_measurement_devices_id': grsMeasurementDevicesId,
      'grp_types_id': grpTypesId,
      'neighborhood_id': neighborhoodId,
      'season': season,
    };
  }

  @override
  List<Object?> get props => [
    accountNumber,
    contractNumber,
    contractDate,
    contractEndDate,
    companyDirector,
    companyTin,
    phone,
    email,
    address,
    typeConsumers,
    directionId,
    ministryId,
    grsId,
    egxuIndustrialCollectorId,
    grsMeasurementDevicesId,
    grpTypesId,
    neighborhoodId,
    season,
  ];
}