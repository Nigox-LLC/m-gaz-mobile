import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../global_widget/app_tools.dart';

class GasNetworkItem extends StatelessWidget {
  const GasNetworkItem({super.key, required this.title, required this.subTitle, required this.iconPath, required this.color, required this.onTap});

  final String title;
  final String subTitle;
  final String iconPath;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(0xFFF0F0F0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
                    child: Padding(
                      padding: EdgeInsets.all(7),
                      child: AppTools.svg(iconPath, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                    Text(
                      subTitle,
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202020)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
