import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FoodSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const FoodSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = '搜尋食物或品牌',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.search, size: 18, color: AppColors.dark),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTextStyles.body(fontSize: 18),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.body(
                fontSize: 18,
                color: AppColors.mutedText,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.dark, width: 1.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.dark, width: 1.5),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.dark, width: 1.5),
              ),
              contentPadding: const EdgeInsets.only(bottom: 12),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
