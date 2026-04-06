import 'package:flutter/material.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import '../core/utils/colors.dart';
import '../core/utils/style.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Color? labelColor;
  final bool obscure;
  final IconData? icon;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool upperCase;
  final bool readOnly;
  final Color? fillColor;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool autocorrect;
  final bool enableSuggestions;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.labelColor,
    this.obscure = false,
    this.icon,
    this.keyboardType,
    this.suffixIcon,
    this.upperCase = false,
    this.readOnly = false,
    this.fillColor,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.enabled,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;

    if (widget.upperCase) {
      widget.controller.addListener(_handleUpperCase);
    }
  }

  void _handleUpperCase() {
    final text = widget.controller.text;
    final upperText = text.toUpperCase();
    if (text != upperText) {
      widget.controller.value = widget.controller.value.copyWith(
        text: upperText,
        selection: TextSelection.collapsed(offset: upperText.length),
      );
    }
  }

  @override
  void dispose() {
    if (widget.upperCase) {
      widget.controller.removeListener(_handleUpperCase);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 TITLE
        Text(
          widget.label,
          style: AppTextStyles.style600.copyWith(
            fontSize: 14.w,
            color: widget.labelColor ?? AppColors.black,
          ),
        ),
        SizedBox(height: 6.h),

        /// 🔹 TEXT FIELD
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          cursorColor: AppColors.black,
          textInputAction: widget.textInputAction ?? TextInputAction.next,

          onFieldSubmitted: (value) {
            widget.onSubmitted != null
                ? widget.onSubmitted!(value)
                : FocusScope.of(context).nextFocus();
          },

          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,

          style: AppTextStyles.style500.copyWith(
            fontSize: 15.w,
            color: AppColors.black,
          ),

          decoration: InputDecoration(
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, size: 20.w)
                : null,

            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon,

            filled: true,
            fillColor: widget.fillColor ?? Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.w),
              borderSide: BorderSide(color: AppColors.white, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.w),
              borderSide: BorderSide(color: AppColors.white, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.w),
              borderSide: BorderSide(color: AppColors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.w),
              borderSide: BorderSide(color: AppColors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.w),
              borderSide: BorderSide(color: AppColors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
