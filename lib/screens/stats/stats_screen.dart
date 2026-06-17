import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('統計', style: AppTextStyles.title()),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(
                child: Text(
                  'Phase 2',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
