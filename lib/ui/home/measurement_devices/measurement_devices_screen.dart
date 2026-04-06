import 'package:flutter/material.dart';
import 'package:m_gaz/core/extension/navigator_extension.dart';
import 'package:m_gaz/global_widget/global_app_bar.dart';
import 'package:m_gaz/ui/home/measurement_devices/grs_measurement_devices/grs_measurement_devices_screen.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/technological_measuring_screen.dart';
import '../../../../core/common/words.dart';

class MeasurementDevicesScreen extends StatelessWidget {
  const MeasurementDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGlobalAppBar(title: Words.measuringDevices.tr(), showBack: false),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                    title: Words.grsMeasuringDevices.tr(),
                    subtitle: Words.grsDesc.tr(),
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
                    onTap: () {

                    },
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
    return Hero(
      tag: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.white.withValues(alpha: 0.3),
          child: Container(
            height: 180,
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
                // Orqa fon uchun dekorativ element
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
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    children: [
                      // Icon qutisi
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, size: 48, color: iconColor),
                      ),
                      const SizedBox(width: 24),

                      // Matn qismi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
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
