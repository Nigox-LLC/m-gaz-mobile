import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/size_extension.dart';

class CustomListTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailingIcon;

  const CustomListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Icon(leadingIcon, size: 24, color: Colors.black87),
          leadingIcon,
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF202020)),
            ),
          ),
          // Icon(trailingIcon, size: 16, color: Colors.black54),
          ?trailingIcon
        ],
      ),
    );
  }
}