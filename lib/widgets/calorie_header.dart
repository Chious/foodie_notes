import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CalorieHeader extends StatelessWidget {
  final int current;
  final int goal;

  const CalorieHeader({
    super.key,
    required this.current,
    required this.goal,
  });

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (current / goal).clamp(0.0, 1.0);
    final remaining = goal - current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(current),
              style: AppTextStyles.heroNumber(fontSize: 60),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '/ ${_formatNumber(goal)} KCAL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.notoSansTc(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
            children: [
              const TextSpan(text: '還可以吃 '),
              TextSpan(
                text: _formatNumber(remaining),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
              const TextSpan(text: ' kcal'),
            ],
          ),
        ),
      ],
    );
  }
}
