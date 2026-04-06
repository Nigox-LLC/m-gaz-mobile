import 'package:flutter/material.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import '../core/utils/colors.dart';
import '../core/utils/style.dart';

class CustomGlobalAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final bool showBack;
  final VoidCallback? onBack;
  final double leftPadding;
  final List<Widget>? actions;

  const CustomGlobalAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.showBack = true,
    this.onBack,
    this.leftPadding = 0,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.cF5F5F5,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: AppTextStyles.style600.copyWith(
          fontSize: 16.w,
          color: AppColors.black,
        ),
      ),
      leading:
          showBack
              ? Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.black,
                    size: 24,
                  ),
                  onPressed: onBack ?? () => Navigator.pop(context),
                ),
              )
              : null,
      actions:
          actions
              ?.map(
                (action) => Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  // yoki siz xohlagan padding
                  child: action,
                ),
              )
              .toList(),
    );
  }
}
