import 'package:flutter/material.dart';

import '../../../../core/common/words.dart';
import '../../domain/entities/measurement_device_type.dart';
import '../widgets/measurement_devices_scaffold.dart';

/// Technological measuring-devices list. Backed by
/// `technological-measuring-devices-documents/`.
class TechnologicalMeasuringPage extends StatelessWidget {
  const TechnologicalMeasuringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MeasurementDevicesScaffold(
      title: Words.technologicalMeasuringDevices.tr(),
      type: MeasurementDeviceType.technological,
    );
  }
}
