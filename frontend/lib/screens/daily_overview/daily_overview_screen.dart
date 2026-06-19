import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/mock_data.dart';
import '../../widgets/calorie_header.dart';
import '../../widgets/macro_progress_bar.dart';
import '../../widgets/meal_card.dart';
import '../../widgets/section_header.dart';

class DailyOverviewScreen extends StatefulWidget {
  const DailyOverviewScreen({super.key});

  @override
  State<DailyOverviewScreen> createState() => _DailyOverviewScreenState();
}

class _DailyOverviewScreenState extends State<DailyOverviewScreen> {
  static const _original = MockData.dailyData;

  late final List<Meal> _meals = List.of(_original.meals);

  int get _totalCalories => _meals.fold(0, (sum, m) => sum + m.totalKcal);

  double get _ratio =>
      _original.totalCalories > 0
          ? _totalCalories / _original.totalCalories
          : 0.0;

  int get _proteinCurrent =>
      (_original.macros.proteinCurrent * _ratio).round();
  int get _carbsCurrent => (_original.macros.carbsCurrent * _ratio).round();
  int get _fatCurrent => (_original.macros.fatCurrent * _ratio).round();

  void _removeMeal(int index) {
    final removed = _meals[index];
    setState(() => _meals.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('已移除「${removed.name}」'),
          backgroundColor: AppColors.dark,
          action: SnackBarAction(
            label: '復原',
            textColor: AppColors.greenLight,
            onPressed: () {
              setState(() => _meals.insert(index, removed));
            },
          ),
        ),
      );
  }

  void _resetMeals() {
    setState(() {
      _meals
        ..clear()
        ..addAll(_original.meals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_original.dateLabel, style: AppTextStyles.sectionLabel()),
            const SizedBox(height: 2),
            Text(_original.dayLabel, style: AppTextStyles.title()),
            const SizedBox(height: 24),

            CalorieHeader(
              current: _totalCalories,
              goal: _original.goalCalories,
            ),
            const SizedBox(height: 28),

            // Macro bars
            MacroProgressBar(
              label: '蛋白質',
              current: _proteinCurrent,
              goal: _original.macros.proteinGoal,
            ),
            const SizedBox(height: 15),
            MacroProgressBar(
              label: '碳水',
              current: _carbsCurrent,
              goal: _original.macros.carbsGoal,
            ),
            const SizedBox(height: 15),
            MacroProgressBar(
              label: '脂肪',
              current: _fatCurrent,
              goal: _original.macros.fatGoal,
            ),
            const SizedBox(height: 28),

            // Meals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(text: 'MEALS'),
                if (_meals.length != _original.meals.length)
                  GestureDetector(
                    onTap: _resetMeals,
                    child: Text(
                      '重置',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (_meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    '沒有餐點記錄',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 15,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              )
            else
              ..._meals.asMap().entries.map((entry) {
                return Dismissible(
                  key: ValueKey('${entry.value.name}_${entry.value.time}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: const Color(0xFFD4533B),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => _removeMeal(entry.key),
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
