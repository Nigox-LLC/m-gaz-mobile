import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/features/gas_networks/presentation/widgets/gas_network_item.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../../../../core/common/words.dart';
import '../../../../core/extension/navigator_extension.dart';
import 'gts_measurement_devices_pages/gts_measurement_page.dart';
import 'industrial_collectors_page.dart';
import 'technological_measuring_page.dart';

class GasNetworksPage extends StatelessWidget {
  const GasNetworksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        leadingWidth: MediaQuery.of(context).size.width,
        elevation: 0,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Gaz tarmoqlari bo’yicha',
              style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1D2E)),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 16,
          children: [
            GasNetworkItem(
              title: Words.gtsMeasuringDevices.tr(),
              subTitle: Words.gtsDesc.tr(),
              iconPath: AppTools.icRadio,
              color: Color(0xFF47C2FF),
              onTap: () => push(const GtsMeasurementPage()),
            ),
            GasNetworkItem(
              title: Words.industrialCollectors.tr(),
              subTitle: Words.industrialDesc.tr(),
              iconPath: AppTools.icDashboardSpeed02,
              color: Color(0xFF1FC16B),
              onTap: () => push(const IndustrialCollectorsPage()),
            ),
            GasNetworkItem(
              title: Words.technologicalMeasuringDevices.tr(),
              subTitle: Words.technologicalDesc.tr(),
              iconPath: AppTools.icTool,
              color: Color(0xFFFA7319),
              onTap: () => push(const TechnologicalMeasuringPage()),
            ),
          ],
        ),
      ),
    );
  }
}
