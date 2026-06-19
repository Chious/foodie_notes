import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';

class StatsInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final double valueFontSize;
  final String? unitSuffix;
  final bool useChineseFont;

  const StatsInfoCard({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
    this.valueFontSize = 14,
    this.unitSuffix,
    this.useChineseFont = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSansTc(
              fontSize: 11,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 7),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: useChineseFont
                      ? GoogleFonts.notoSansTc(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w600,
                          color: valueColor ?? AppColors.dark,
                        )
                      : GoogleFonts.spaceGrotesk(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w600,
                          color: valueColor ?? AppColors.dark,
                        ),
                ),
                if (unitSuffix != null)
                  TextSpan(
                    text: unitSuffix,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
