import 'package:equatable/equatable.dart';

class ConsumerRelationEgxu extends Equatable {
  final String monthStartReading;
  final String additionalGas;
  final String violationGas;
  final String additionalBalance;
  final String monthEndReading;
  final String readingDifference;
  final bool grpExists;
  final String grpLoss;
  final String totalGas;
  final int typeOfActivityId;
  final int gasNetworksId;
  final int egxuConnectionPointId;
  final int ghuIdNumber;
  final String movGrpAfterEgxu;
  final String gaz;
  final String counterStatus;
  final String reasonsForViolations;

  const ConsumerRelationEgxu({
    required this.monthStartReading,
    required this.additionalGas,
    required this.violationGas,
    required this.additionalBalance,
    required this.monthEndReading,
    required this.readingDifference,
    required this.grpExists,
    required this.grpLoss,
    required this.totalGas,
    required this.typeOfActivityId,
    required this.gasNetworksId,
    required this.egxuConnectionPointId,
    required this.ghuIdNumber,
    required this.movGrpAfterEgxu,
    required this.gaz,
    required this.counterStatus,
    required this.reasonsForViolations,
  });

  factory ConsumerRelationEgxu.fromJson(Map<String, dynamic> json) {
    return ConsumerRelationEgxu(
      monthStartReading: json['month_start_reading'] as String,
      additionalGas: json['additional_gas'] as String,
      violationGas: json['violation_gas'] as String,
      additionalBalance: json['additional_balance'] as String,
      monthEndReading: json['month_end_reading'] as String,
      readingDifference: json['reading_difference'] as String,
      grpExists: json['grp_exists'] as bool,
      grpLoss: json['grp_loss'] as String,
      totalGas: json['total_gas'] as String,
      typeOfActivityId: json['type_of_activity_id'] as int,
      gasNetworksId: json['gas_networks_id'] as int,
      egxuConnectionPointId: json['egxu_connection_point_id'] as int,
      ghuIdNumber: json['ghu_id_number'] as int,
      movGrpAfterEgxu: json['mov_grp_after_egxu'] as String,
      gaz: json['gaz'] as String,
      counterStatus: json['counter_status'] as String,
      reasonsForViolations: json['reasons_for_violations'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_start_reading': monthStartReading,
      'additional_gas': additionalGas,
      'violation_gas': violationGas,
      'additional_balance': additionalBalance,
      'month_end_reading': monthEndReading,
      'reading_difference': readingDifference,
      'grp_exists': grpExists,
      'grp_loss': grpLoss,
      'total_gas': totalGas,
      'type_of_activity_id': typeOfActivityId,
      'gas_networks_id': gasNetworksId,
      'egxu_connection_point_id': egxuConnectionPointId,
      'ghu_id_number': ghuIdNumber,
      'mov_grp_after_egxu': movGrpAfterEgxu,
      'gaz': gaz,
      'counter_status': counterStatus,
      'reasons_for_violations': reasonsForViolations,
    };
  }

  @override
  List<Object?> get props => [
    monthStartReading,
    additionalGas,
    violationGas,
    additionalBalance,
    monthEndReading,
    readingDifference,
    grpExists,
    grpLoss,
    totalGas,
    typeOfActivityId,
    gasNetworksId,
    egxuConnectionPointId,
    ghuIdNumber,
    movGrpAfterEgxu,
    gaz,
    counterStatus,
    reasonsForViolations,
  ];
}