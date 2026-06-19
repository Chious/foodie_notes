import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../models/mock_data.dart';

class MealDetailSheet extends StatelessWidget {
  final StatsMeal meal;

  const MealDetailSheet({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Meal header
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.segmentBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  meal.name,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meal.name} · ${meal.time}',
                      style: AppTextStyles.label(color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.name,
                      style: AppTextStyles.title(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calorie display
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${meal.kcal}',
                  style: AppTextStyles.heroNumber(fontSize: 54),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'KCAL · 佔每日 ${(meal.kcal / MockData.dailyStatsData.goalCalories * 100).round()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Macro split bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: meal.macros.protein,
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: meal.macros.carbs,
                    child: Container(color: AppColors.greenMedium),
                  ),
                  Expanded(
                    flex: meal.macros.fat,
                    child: Container(color: AppColors.greenPale),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Macro legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _macroLabel('蛋白', meal.macros.protein, AppColors.primary),
              _macroLabel('碳水', meal.macros.carbs, AppColors.greenMedium),
              _macroLabel('脂肪', meal.macros.fat, AppColors.greenPale),
            ],
          ),
          const SizedBox(height: 24),

          // Food items
          Text(
            '內容',
            style: AppTextStyles.label(),
          ),
          const SizedBox(height: 4),
          ...meal.summary.split('、').map((item) => Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item,
                      style: GoogleFonts.notoSansTc(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_outlined, size: 16),
                      const SizedBox(width: 7),
                      Text(
                        '編輯',
                        style: GoogleFonts.notoSansTc(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '完成',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroLabel(String name, int grams, Color color) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        RichText(
          text: TextSpan(
            style: GoogleFonts.notoSansTc(fontSize: 13, color: AppColors.dark),
            children: [
              TextSpan(text: '$name '),
              TextSpan(
                text: '${grams}g',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
