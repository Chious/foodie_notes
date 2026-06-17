import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final String unit;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (current / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.notoSansTc(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.dark,
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: AppColors.mutedText,
                ),
                children: [
                  TextSpan(
                    text: '$current',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  TextSpan(text: ' / $goal $unit'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
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
      ],
    );
  }
}
