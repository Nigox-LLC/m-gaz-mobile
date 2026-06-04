import 'package:flutter/material.dart';
import 'package:m_gaz/core/extension/size_extension.dart';

class CustomRadioWidget extends StatelessWidget {
  const CustomRadioWidget({super.key, required this.isCheck});
  final bool isCheck;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.w,
      height: 20.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isCheck? Color(0x720034DC) :Color(0xFFEDF2FE), width: isCheck? 4:2),
        ),
      ),
    );
  }
}
