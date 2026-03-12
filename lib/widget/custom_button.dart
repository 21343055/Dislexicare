import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../utils/app_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon; // opsional

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isOutlined ? 0 : 3,
          backgroundColor: isOutlined ? Colors.white : AppColor.primary,
          foregroundColor: isOutlined ? AppColor.primary : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined
                ? const BorderSide(color: AppColor.primary, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppStyle.button.copyWith(
                color: isOutlined ? AppColor.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
