import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../models/mock_data.dart';
import '../../widgets/calorie_header.dart';
import '../../widgets/macro_progress_bar.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/section_header.dart';

class DailyOverviewScreen extends StatelessWidget {
  const DailyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockData.dailyData;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.dateLabel, style: AppTextStyles.sectionLabel()),
            const SizedBox(height: 2),
            Text(data.dayLabel, style: AppTextStyles.title()),
            const SizedBox(height: 24),

            CalorieHeader(
              current: data.totalCalories,
              goal: data.goalCalories,
            ),
            const SizedBox(height: 28),

            // Macro bars
            MacroProgressBar(
              label: '蛋白質',
              current: data.macros.proteinCurrent,
              goal: data.macros.proteinGoal,
            ),
            const SizedBox(height: 15),
            MacroProgressBar(
              label: '碳水',
              current: data.macros.carbsCurrent,
              goal: data.macros.carbsGoal,
            ),
            const SizedBox(height: 15),
            MacroProgressBar(
              label: '脂肪',
              current: data.macros.fatCurrent,
              goal: data.macros.fatGoal,
            ),
            const SizedBox(height: 28),

            // Meals
            const SectionHeader(text: 'MEALS'),
            ...data.meals.asMap().entries.map((entry) {
              return Padding(
                padding: entry.key == 0
                    ? const EdgeInsets.only(left: 0)
                    : EdgeInsets.zero,
                child: MealCard(
                  meal: entry.value,
                  showAccent: entry.key == 0,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
