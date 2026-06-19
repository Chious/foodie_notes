import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class DataRowTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool highlight;
  final VoidCallback? onTap;

  const DataRowTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(highlight ? 14 : 16, 18, 0, 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: const BorderSide(color: AppColors.borderLight),
            left: highlight
                ? const BorderSide(color: AppColors.primary, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.notoSansTc(
                fontSize: 16,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.dark,
              ),
            ),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: highlight ? AppColors.primary : AppColors.dark,
                        ),
                      ),
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.mutedText,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.chevron,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
