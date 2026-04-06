import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;

  const PhoneNumberInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [TextFieldMasks.maskPhoneFormatter],
      cursorColor: Colors.black,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Telefon raqami',
        labelStyle: const TextStyle(color: Colors.black),
        hintText: "(00) 000 00 00",
        hintStyle: const TextStyle(color: Colors.black),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "+998",
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      onChanged: (v) {
        final raw = v.replaceAll(RegExp(r'\D'), '');
        if (raw.length >= 9) {
          FocusScope.of(context).unfocus();
        }
      },
    );
  }
}

class TextFieldMasks {
  TextFieldMasks._();

  static final MaskTextInputFormatter maskPhoneFormatter =
      MaskTextInputFormatter(
        mask: '(##) ### ## ##',
        filter: {'#': RegExp(r'\d')}, // faqat raqamlar
        type: MaskAutoCompletionType.eager,
      );

  static String formatPhoneWithoutCountry(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 9) return raw;

    final part1 = cleaned.substring(0, 2);
    final part2 = cleaned.substring(2, 5);
    final part3 = cleaned.substring(5, 7);
    final part4 = cleaned.substring(7);

    return '$part1 $part2 $part3 $part4';
  }

  static String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 12) return phone;

    return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} '
        '${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)} '
        '${cleaned.substring(9)}';
  }
}
