import 'package:flutter/material.dart';
import 'package:m_gaz/core/extension/navigator_extension.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:m_gaz/ui/home/measurement_devices/grs_measurement_devices/grs_measurement_devices_screen.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/technological_measuring_screen.dart';
import '../../../../core/common/words.dart';
import 'industrial_collectors/industrial_collectors_screen.dart';

class MeasurementDevicesScreen extends StatelessWidget {
  const MeasurementDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGlobalAppBar(
        title: Words.measuringDevices.tr(),
        showBack: false,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 380 ? 16 : 24,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPremiumCard(
                    context,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[400]!, Colors.blue[900]!],
                    ),
                    icon: Icons.satellite_alt_outlined,
                    iconColor: Colors.white,
                    title: Words.gtsMeasuringDevices.tr(),
                    subtitle: Words.gtsDesc.tr(),
                    onTap: () {
                      push(GRSMeasurementDevicesScreen());
                    },
                  ),
                  const SizedBox(height: 24),

                  _buildPremiumCard(
                    context,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green[400]!, Colors.green[800]!],
                    ),
                    icon: Icons.precision_manufacturing_outlined,
                    iconColor: Colors.white,
                    title: Words.industrialCollectors.tr(),
                    subtitle: Words.industrialDesc.tr(),
                    onTap: () => push(IndustrialCollectorsScreen()),
                  ),
                  const SizedBox(height: 24),

                  _buildPremiumCard(
                    context,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange[400]!, Colors.deepOrange[800]!],
                    ),
                    icon: Icons.analytics_outlined,
                    iconColor: Colors.white,
                    title: Words.technologicalMeasuringDevices.tr(),
                    subtitle: Words.technologicalDesc.tr(),
                    onTap: () => push(TechMeasureScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium card dizayni
  Widget _buildPremiumCard(
    BuildContext context, {
    required LinearGradient gradient,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;
    final iconSize = compact ? 34.0 : 42.0;
    final iconPadding = compact ? 13.0 : 16.0;
    final horizontalPadding = compact ? 18.0 : 22.0;
    final verticalPadding = compact ? 16.0 : 18.0;
    final titleSize = compact ? 18.0 : 20.0;
    final subtitleSize = compact ? 13.0 : 14.0;

    return Hero(
      tag: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withValues(alpha: 0.3),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: compact ? 142 : 150),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(75),
                    ),
                  ),
                ),

                // Asosiy kontent
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon qutisi
                        Container(
                          padding: EdgeInsets.all(iconPadding),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, size: iconSize, color: iconColor),
                        ),
                        SizedBox(width: compact ? 14 : 20),

                        // Matn qismi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.28,
                                ),
                                maxLines: compact ? 4 : 3,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: compact ? 8 : 12),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: compact ? 18 : 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
