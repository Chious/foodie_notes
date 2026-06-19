import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FoodSearchResultTile extends StatelessWidget {
  final FoodItem food;
  final VoidCallback? onTap;

  const FoodSearchResultTile({
    super.key,
    required this.food,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: AppTextStyles.bodyBold(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    '每 100g · 蛋白 ${food.proteinPer100g.toInt()} · '
                    '碳水 ${food.carbsPer100g.toInt()} · '
                    '脂肪 ${food.fatPer100g.toInt()}',
                    style: AppTextStyles.unit(fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.kcalPer100g}',
                  style: AppTextStyles.number(fontSize: 18),
                ),
                Text('KCAL', style: AppTextStyles.unit(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
