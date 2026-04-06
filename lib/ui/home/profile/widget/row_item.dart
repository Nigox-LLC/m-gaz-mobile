import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/style.dart';
import '../../../../global_widget/app_tools.dart';

class ProfileRowItem extends StatelessWidget {
  const ProfileRowItem({
    super.key,
    required this.iconPath,
    required this.title,
    required this.callback,
    this.isColor = false,
  });

  final String iconPath;
  final bool isColor;
  final String title;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        borderRadius: BorderRadius.circular(12.w),
        color: AppColors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.w),
          onTap: callback,
          child: Container(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h, left: 6.w),
            decoration: BoxDecoration(color: AppColors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                !isColor
                    ? SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    AppColors.c717680,
                    BlendMode.srcIn,
                  ),
                  height: 24.h,
                )
                    : SvgPicture.asset(iconPath, height: 24.h),
                12.getW(),
                Text(
                  title,
                  style: AppTextStyles.style500.copyWith(
                    fontSize: 16.w,
                    color: AppColors.c414651,
                    letterSpacing: 0,
                  ),
                ),
                Expanded(child: SizedBox()),
                AppTools.svg(
                  AppTools.forward,
                  colorFilter: ColorFilter.mode(
                    AppColors.c717680,
                    BlendMode.srcIn,
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
