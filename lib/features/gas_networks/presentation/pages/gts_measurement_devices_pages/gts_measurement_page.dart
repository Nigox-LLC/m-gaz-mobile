import 'package:flutter/material.dart';

import '../../../../../core/common/words.dart';
import '../../../domain/entities/measurement_device_type.dart';
import '../../widgets/measurement_devices_scaffold.dart';

/// GTS measuring-devices list. Backed by `grs-measuring-devices-documents/`.
class GtsMeasurementPage extends StatelessWidget {
  const GtsMeasurementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MeasurementDevicesScaffold(
      title: Words.gtsMeasuringDevices.tr(),
      type: MeasurementDeviceType.gts,
    );
  }
}
