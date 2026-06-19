import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/mock_data.dart';
import 'widgets/date_navigator.dart';
import 'widgets/hourly_timeline.dart';
import 'widgets/meal_detail_sheet.dart';

class DailyStatsView extends StatefulWidget {
  const DailyStatsView({super.key});

  @override
  State<DailyStatsView> createState() => _DailyStatsViewState();
}

class _DailyStatsViewState extends State<DailyStatsView> {
  static const _weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];

  int _dayOffset = 0;

  DateTime get _selectedDate => DateTime.now().add(Duration(days: _dayOffset));

  bool get _isToday => _dayOffset == 0;

  String _formatDateLabel(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    return '${date.month}月${date.day}日 $weekday';
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final data = MockData.dailyStatsData;
    final date = _selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateNavigator(
          label: _formatDateLabel(date),
          onPrevious: () => setState(() => _dayOffset--),
          onNext: () => setState(() => _dayOffset++),
        ),
        const SizedBox(height: 16),

        // Calorie summary
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(data.totalCalories),
              style: AppTextStyles.heroNumber(fontSize: 50),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '/ ${_formatNumber(data.goalCalories)} KCAL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: (data.totalCalories / data.goalCalories).clamp(0.0, 1.0),
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 7),
        RichText(
          text: TextSpan(
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.mutedText,
            ),
            children: [
              const TextSpan(text: '還可以吃 '),
              TextSpan(
                text: _formatNumber(data.remaining),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const TextSpan(text: ' kcal'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Macro bars
        _MacroRow(
          label: '蛋白質',
          current: data.macros.proteinCurrent,
          goal: data.macros.proteinGoal,
          color: AppColors.primary,
        ),
        const SizedBox(height: 11),
        _MacroRow(
          label: '碳水',
          current: data.macros.carbsCurrent,
          goal: data.macros.carbsGoal,
          color: AppColors.greenMedium,
        ),
        const SizedBox(height: 11),
        _MacroRow(
          label: '脂肪',
          current: data.macros.fatCurrent,
          goal: data.macros.fatGoal,
          color: AppColors.greenPale,
        ),
        const SizedBox(height: 20),

        // Hint text
        Text(
          '點任一小時的空格,即可在該時間新增餐點',
          style: GoogleFonts.notoSansTc(
            fontSize: 11,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 12),

        // Hourly timeline
        HourlyTimeline(
          meals: data.meals,
          currentTime: _isToday ? _formatCurrentTime() : null,
          onMealTap: (meal) => _showMealDetail(context, meal),
        ),
      ],
    );
  }

  void _showMealDetail(BuildContext context, StatsMeal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MealDetailSheet(meal: meal),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return n.toString();
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (current / goal).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: AppColors.dark,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        SizedBox(
          width: 56,
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: AppColors.mutedText,
              ),
              children: [
                TextSpan(
                  text: '$current',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                TextSpan(text: '/${goal}g'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
