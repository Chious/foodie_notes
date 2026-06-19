import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/mock_data.dart';
import 'widgets/date_navigator.dart';
import 'widgets/stats_bar_chart.dart';
import 'widgets/stats_info_card.dart';

class WeeklyStatsView extends StatefulWidget {
  const WeeklyStatsView({super.key});

  @override
  State<WeeklyStatsView> createState() => _WeeklyStatsViewState();
}

class _WeeklyStatsViewState extends State<WeeklyStatsView> {
  int _weekOffset = 0;

  DateTime get _weekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: _weekOffset * 7));
  }

  String _formatWeekRange(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.month}/${monday.day} – ${sunday.month}/${sunday.day}';
  }

  @override
  Widget build(BuildContext context) {
    final data = MockData.weeklyStatsData;
    final monday = _weekStart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateNavigator(
          label: _formatWeekRange(monday),
          onPrevious: () => setState(() => _weekOffset--),
          onNext: () => setState(() => _weekOffset++),
        ),
        const SizedBox(height: 24),

        // Bar chart
        StatsBarChart(
          bars: data.days,
          calorieGoal: data.calorieGoal,
          chartHeight: 188,
          targetLabel: '目標 ${data.calorieGoal}',
          barRadius: 5,
          barGap: 9,
        ),
        const SizedBox(height: 10),

        // Day labels
        Row(
          children: data.days.map((day) {
            final isToday = day.status == DayStatus.today;
            return Expanded(
              child: Text(
                day.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansTc(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday
                      ? AppColors.primary
                      : day.status == DayStatus.future
                          ? AppColors.chevron
                          : AppColors.mutedText,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 26),

        // Info cards
        Row(
          children: [
            Expanded(
              child: StatsInfoCard(
                title: '平均三大營養',
                value: data.avgMacros,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatsInfoCard(
                title: '本週體重',
                value: data.weightChange,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
