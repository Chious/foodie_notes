import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RecognizedItemTile extends StatelessWidget {
  final RecognizedItem item;
  final bool selected;
  final ValueChanged<bool?> onCheckChanged;
  final VoidCallback onTap;

  const RecognizedItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onCheckChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final food = item.foodItem;
    final servingG = food.defaultServingGrams;
    final kcal = (food.kcalPer100g * servingG / 100).round();
    final protein = (food.proteinPer100g * servingG / 100).round();
    final carbs = (food.carbsPer100g * servingG / 100).round();
    final fat = (food.fatPer100g * servingG / 100).round();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Opacity(
          opacity: selected ? 1.0 : 0.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onCheckChanged(!selected),
                child: Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: selected
                        ? null
                        : Border.all(
                            color: AppColors.border,
                            width: 1.8,
                          ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: AppTextStyles.bodyBold(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$kcal KCAL',
                            style: AppTextStyles.unit(fontSize: 12),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '蛋白 ${protein}g · 碳水 ${carbs}g · 脂肪 ${fat}g',
                            style: AppTextStyles.unit(
                              fontSize: 11,
                              color: AppColors.chevron,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${item.quantity.toInt()}',
                                style: AppTextStyles.number(fontSize: 18),
                              ),
                              TextSpan(
                                text: ' 份',
                                style: AppTextStyles.unit(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '≈ $servingG g',
                          style: AppTextStyles.unit(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
