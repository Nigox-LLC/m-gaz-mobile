import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/core/utils/app_date_formatter.dart';
import '../core/utils/colors.dart';
import '../core/utils/style.dart';

class CustomDateFormField extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final bool readOnly;

  const CustomDateFormField({
    super.key,
    required this.controller,
    required this.title,
    this.readOnly = false,
  });

  @override
  State<CustomDateFormField> createState() => _CustomDateFormFieldState();
}

class _CustomDateFormFieldState extends State<CustomDateFormField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    _focusNode.unfocus();

    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.c1570EF,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      widget.controller.text = AppDateFormatter.date(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppTextStyles.style600.copyWith(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        6.getH(),
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,

          enabled: !widget.readOnly,
          // 👈 ASOSIY BLOK
          readOnly: true,
          // 👈 text yozib bo‘lmaydi
          enableInteractiveSelection: !widget.readOnly,

          onTap: widget.readOnly ? null : _selectDate,
          keyboardType: TextInputType.none,
          style: AppTextStyles.style500.copyWith(
            fontSize: 15,
            color: AppColors.black,
          ),

          inputFormatters: widget.readOnly
              ? []
              : [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
          validator: widget.readOnly
              ? null
              : (value) {
                  if (value == null || value.trim().isEmpty) {
                    return Words.selectDate.tr();
                  }

                  final regex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
                  if (!regex.hasMatch(value)) {
                    return Words.dateFormatInvalid.tr();
                  }

                  try {
                    final parts = value.split('.');
                    final date = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );

                    if (date.isAfter(DateTime.now())) {
                      return Words.dateFutureInvalid.tr();
                    }
                  } catch (_) {
                    return Words.dateFormatInvalid.tr();
                  }

                  return null;
                },

          decoration: InputDecoration(
            hintText: "dd.MM.yyyy",
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month_outlined, size: 28),
              color: AppColors.c1570EF,
              onPressed: widget.readOnly ? null : _selectDate,
            ),
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.cF5F5F5, width: 2),
              borderRadius: BorderRadius.circular(28),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.c1570EF, width: 2),
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        20.getH(),
      ],
    );
  }
}
