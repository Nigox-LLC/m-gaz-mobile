import 'package:m_gaz/core/models/grs/grs_detail_model/grs_connetction_point.dart';

class GrsEgxuData {
  final int? id;
  final GrsConnectionPoint? egxuConnectionPoint;
  final double? monthStartReading;
  final double? additionalGas;
  final double? violationGas;
  final double? additionalBalance;
  final double? monthEndReading;
  final double? readingDifference;
  final bool? grpExists;
  final double? grpLoss;
  final double? totalGas;
  final double? outerDiametrNode;
  final double? outerDiametrDiaphragm;
  final double? workingGasPressure;
  final int? ghuIdNumber;
  final String? movGrpAfterEgxu;
  final double? minimumGasConsumption;
  final double? maximumGasConsumption;
  final double? diameterMeasuringComplex;
  final String? reasonsForViolations;

  GrsEgxuData({
    this.id,
    this.egxuConnectionPoint,
    this.monthStartReading,
    this.additionalGas,
    this.violationGas,
    this.additionalBalance,
    this.monthEndReading,
    this.readingDifference,
    this.grpExists,
    this.grpLoss,
    this.totalGas,
    this.outerDiametrNode,
    this.outerDiametrDiaphragm,
    this.workingGasPressure,
    this.ghuIdNumber,
    this.movGrpAfterEgxu,
    this.minimumGasConsumption,
    this.maximumGasConsumption,
    this.diameterMeasuringComplex,
    this.reasonsForViolations,
  });

  factory GrsEgxuData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsEgxuData();
    return GrsEgxuData(
      id: json['id'],
      egxuConnectionPoint: json['egxu_connection_point'] != null ? GrsConnectionPoint.fromJson(json['egxu_connection_point']) : null,
      monthStartReading: (json['month_start_reading'] as num?)?.toDouble(),
      additionalGas: (json['additional_gas'] as num?)?.toDouble(),
      violationGas: (json['violation_gas'] as num?)?.toDouble(),
      additionalBalance: (json['additional_balance'] as num?)?.toDouble(),
      monthEndReading: (json['month_end_reading'] as num?)?.toDouble(),
      readingDifference: (json['reading_difference'] as num?)?.toDouble(),
      grpExists: json['grp_exists'],
      grpLoss: (json['grp_loss'] as num?)?.toDouble(),
      totalGas: (json['total_gas'] as num?)?.toDouble(),
      outerDiametrNode: (json['outer_diametr_node'] as num?)?.toDouble(),
      outerDiametrDiaphragm: (json['outer_diametr_diaphragm'] as num?)?.toDouble(),
      workingGasPressure: (json['working_gas_pressure'] as num?)?.toDouble(),
      ghuIdNumber: json['ghu_id_number'],
      movGrpAfterEgxu: json['mov_grp_after_egxu'],
      minimumGasConsumption: (json['minimum_gas_consumption'] as num?)?.toDouble(),
      maximumGasConsumption: (json['maximum_gas_consumption'] as num?)?.toDouble(),
      diameterMeasuringComplex: (json['diameter_measuring_complex'] as num?)?.toDouble(),
      reasonsForViolations: json['reasons_for_violations'],
    );
  }
}