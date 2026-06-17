import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/mock_data.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final bool showAccent;

  const MealCard({
    super.key,
    required this.meal,
    this.showAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(showAccent ? 14 : 16, 15, 0, 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: const BorderSide(color: AppColors.borderLight),
          left: showAccent
              ? const BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: meal.name,
                        style: GoogleFonts.notoSansTc(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      TextSpan(
                        text: ' ${meal.time}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meal.itemsSummary,
                  style: GoogleFonts.notoSansTc(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${meal.totalKcal}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: showAccent ? AppColors.dark : AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
