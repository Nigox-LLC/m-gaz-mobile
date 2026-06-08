import 'package:equatable/equatable.dart';

/// A single measuring-device document row shared by all three gas-network
/// lists (GTS, industrial collectors, technological). The lists differ only by
/// one type-specific label, captured here as [deviceLabel].
class MeasuringDeviceDocument extends Equatable {
  final int id;
  final String region;
  final String district;
  final String employee;
  final String gtsh;
  final DateTime datetime;

  /// Type-specific value: `industrial_collectors` for industrial collectors,
  /// `techno_measuring_devices` for technological devices, `null` for GTS.
  final String? deviceLabel;

  const MeasuringDeviceDocument({
    required this.id,
    required this.region,
    required this.district,
    required this.employee,
    required this.gtsh,
    required this.datetime,
    this.deviceLabel,
  });

  @override
  List<Object?> get props => [
        id,
        region,
        district,
        employee,
        gtsh,
        datetime,
        deviceLabel,
      ];
}
