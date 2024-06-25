import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  bool showHint;
  TextAlign textAlign;

  MyTextField(
      {required this.label,
      required this.controller,
      this.validator,
      this.keyboardType,
      this.inputFormatters,
      this.textAlign = TextAlign.start,
      this.showHint = false});

  @override
  Widget build(BuildContext context) {
    final commonDecoration = InputDecoration(
      hintStyle: TextStyle(color: Colors.grey.shade600),
      labelStyle:
          TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          width: 2,
          color: Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          width: 2,
          color: Colors.red,
        ),
      ),
      errorStyle: const TextStyle(color: Colors.red),
    );

    return TextFormField(
      textAlign: textAlign,
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: showHint
          ? commonDecoration.copyWith(hintText: label)
          : commonDecoration.copyWith(labelText: label),
    );
  }
}
