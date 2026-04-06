import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumer_create_get/consumer_certificate.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumer_create_get/consumer_company_info.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumer_create_get/consumer_first_certificate.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumer_create_get/consumer_hourly_list_indicator.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumer_create_get/consumer_real_item.dart';
import 'consumer_relation_egxu.dart';
import 'consumer_hourly_file.dart';
import 'consumer_indicator_image.dart';


/// Asosiy EGXU yaratish modeli
class ConsumerCreateModel extends Equatable {
  final int region;
  final int district;
  final int employee;
  final int consumers;
  final List<ConsumerItemcreateModel> egxuList;

  const ConsumerCreateModel({
    required this.region,
    required this.district,
    required this.employee,
    required this.consumers,
    required this.egxuList,
  });

  factory ConsumerCreateModel.fromJson(Map<String, dynamic> json) {
    return ConsumerCreateModel(
      region: json['region'] as int,
      district: json['district'] as int,
      employee: json['employee'] as int,
      consumers: json['consumers'] as int,
      egxuList: (json['egxu_list'] as List)
          .map((item) => ConsumerItemcreateModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'district': district,
      'employee': employee,
      'consumers': consumers,
      'egxu_list': egxuList.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [region, district, employee, consumers, egxuList];
}

class ConsumerItemcreateModel extends Equatable {
  final String fromDate;
  final String toDate;
  final String oneFactory;
  final String twoFactory;
  final int egxuTypeId;
  final List<ConsumerRealItem> real;
  final ConsumerRelationEgxu consumerRelationEgxu;
  final ConsumerCompanyInfo companyInfo;
  final ConsumerFirstCertificate firstCertificate;
  final List<ConsumerIndicatorImage> indicatorImages;
  final List<ConsumerHourlyFile> hourlyFiles;
  final List<ConsumerCertificate> certificates;
  final List<ConsumerHourlyListIndicator> hourlyListIndicator;

  const ConsumerItemcreateModel({
    required this.fromDate,
    required this.toDate,
    required this.oneFactory,
    required this.twoFactory,
    required this.egxuTypeId,
    required this.real,
    required this.consumerRelationEgxu,
    required this.companyInfo,
    required this.firstCertificate,
    required this.indicatorImages,
    required this.hourlyFiles,
    required this.certificates,
    required this.hourlyListIndicator,
  });

  factory ConsumerItemcreateModel.fromJson(Map<String, dynamic> json) {
    return ConsumerItemcreateModel(
      fromDate: json['from_date'] as String,
      toDate: json['to_date'] as String,
      oneFactory: json['one_factory'] as String,
      twoFactory: json['two_factory'] as String,
      egxuTypeId: json['egxu_type_id'] as int,
      real: (json['real'] as List)
          .map((item) => ConsumerRealItem.fromJson(item))
          .toList(),
      consumerRelationEgxu:
      ConsumerRelationEgxu.fromJson(json['consumer_relation_egxu']),
      companyInfo: ConsumerCompanyInfo.fromJson(json['company_info']),
      firstCertificate: ConsumerFirstCertificate.fromJson(json['first_certificate']),
      indicatorImages: (json['indicator_images'] as List)
          .map((item) => ConsumerIndicatorImage.fromJson(item))
          .toList(),
      hourlyFiles: (json['hourly_files'] as List)
          .map((item) => ConsumerHourlyFile.fromJson(item))
          .toList(),
      certificates: (json['certificates'] as List)
          .map((item) => ConsumerCertificate.fromJson(item))
          .toList(),
      hourlyListIndicator: (json['hourly_list_indicator'] as List)
          .map((item) => ConsumerHourlyListIndicator.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_date': fromDate,
      'to_date': toDate,
      'one_factory': oneFactory,
      'two_factory': twoFactory,
      'egxu_type_id': egxuTypeId,
      'real': real.map((e) => e.toJson()).toList(),
      'consumer_relation_egxu': consumerRelationEgxu.toJson(),
      'company_info': companyInfo.toJson(),
      'first_certificate': firstCertificate.toJson(),
      'indicator_images': indicatorImages.map((e) => e.toJson()).toList(),
      'hourly_files': hourlyFiles.map((e) => e.toJson()).toList(),
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'hourly_list_indicator': hourlyListIndicator.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    fromDate,
    toDate,
    oneFactory,
    twoFactory,
    egxuTypeId,
    real,
    consumerRelationEgxu,
    companyInfo,
    firstCertificate,
    indicatorImages,
    hourlyFiles,
    certificates,
    hourlyListIndicator,
  ];
}