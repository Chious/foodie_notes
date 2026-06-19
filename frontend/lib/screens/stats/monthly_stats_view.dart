import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/mock_data.dart';
import 'widgets/date_navigator.dart';
import 'widgets/stats_bar_chart.dart';
import 'widgets/stats_info_card.dart';

class MonthlyStatsView extends StatefulWidget {
  const MonthlyStatsView({super.key});

  @override
  State<MonthlyStatsView> createState() => _MonthlyStatsViewState();
}

class _MonthlyStatsViewState extends State<MonthlyStatsView> {
  int _monthOffset = 0;

  DateTime get _selectedMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _monthOffset);
  }

  String _formatMonthLabel(DateTime date) {
    return '${date.year} 年 ${date.month} 月';
  }

  @override
  Widget build(BuildContext context) {
    final data = MockData.monthlyStatsData;
    final month = _selectedMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateNavigator(
          label: _formatMonthLabel(month),
          onPrevious: () => setState(() => _monthOffset--),
          onNext: () => setState(() => _monthOffset++),
        ),
        const SizedBox(height: 24),

        // Bar chart
        StatsBarChart(
          bars: data.days,
          calorieGoal: data.calorieGoal,
          chartHeight: 150,
          targetLabel: '${data.calorieGoal}',
          barRadius: 2,
          barGap: 2,
        ),
        const SizedBox(height: 10),

        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['1', '8', '15', '22', '30'].map((label) {
            return Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: AppColors.navInactive,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Info cards
        Row(
          children: [
            Expanded(
              child: StatsInfoCard(
                title: '達標率',
                value: '${data.targetRate}',
                valueFontSize: 18,
                unitSuffix: '%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatsInfoCard(
                title: '本月體重',
                value: data.weightChange,
                valueFontSize: 18,
                valueColor: AppColors.primary,
                unitSuffix: 'kg',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatsInfoCard(
                title: '最常吃',
                value: data.mostEaten,
                valueFontSize: 14,
                useChineseFont: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
