import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/segment_toggle.dart';
import 'daily_stats_view.dart';
import 'weekly_stats_view.dart';
import 'monthly_stats_view.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('餐點檢視', style: AppTextStyles.title(fontSize: 30)),
            const SizedBox(height: 16),
            SegmentToggle(
              labels: const ['日', '週', '月'],
              selectedIndex: _selectedSegment,
              onChanged: (i) => setState(() => _selectedSegment = i),
            ),
            const SizedBox(height: 18),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedSegment) {
      case 0:
        return const DailyStatsView();
      case 1:
        return const WeeklyStatsView();
      case 2:
        return const MonthlyStatsView();
      default:
        return const SizedBox.shrink();
    }
  }
}
