import 'package:flutter/material.dart';

import '../../../../core/common/words.dart';
import '../../domain/entities/measurement_device_type.dart';
import '../widgets/measurement_devices_scaffold.dart';

/// Industrial collectors list. Backed by `grs-industrial-collectors-documents/`.
class IndustrialCollectorsPage extends StatelessWidget {
  const IndustrialCollectorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MeasurementDevicesScaffold(
      title: Words.industrialCollectors.tr(),
      type: MeasurementDeviceType.industrialCollectors,
    );
  }
}
