import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../utils/app_style.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: AppStyle.inputText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppStyle.labelText,
          prefixIcon: icon != null ? Icon(icon, color: AppColor.primary) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColor.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
