import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class DateNavigator extends StatelessWidget {
  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const DateNavigator({
    super.key,
    required this.label,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPrevious,
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 24,
            color: AppColors.chevron,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.notoSansTc(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: onNext,
          child: const Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: AppColors.chevron,
          ),
        ),
      ],
    );
  }
}
