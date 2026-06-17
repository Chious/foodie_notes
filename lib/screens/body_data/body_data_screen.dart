import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/mock_data.dart';
import '../../widgets/data_row_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/primary_button.dart';

class BodyDataScreen extends StatelessWidget {
  const BodyDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockData.bodyData;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MY BODY', style: AppTextStyles.sectionLabel()),
            const SizedBox(height: 2),
            Text('身體數據', style: AppTextStyles.title()),
            const SizedBox(height: 24),

            // Weight hero
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${data.currentWeight}',
                  style: AppTextStyles.heroNumber(fontSize: 60),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'KG · 目前體重',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: data.progress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目標 ${data.targetWeight}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                Text(
                  '起點 ${data.startWeight} KG',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.notoSansTc(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
                children: [
                  const TextSpan(text: '距離目標還有 '),
                  TextSpan(
                    text: '${data.weightRemaining} kg',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(text: ' · 已減 ${data.weightLost} kg'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Data rows
            const SectionHeader(text: '資料'),
            DataRowTile(
              label: '身高',
              value: '${data.height.toInt()}',
              unit: 'cm',
            ),
            DataRowTile(
              label: '目前體重',
              value: '${data.currentWeight}',
              unit: 'kg',
            ),
            DataRowTile(
              label: '目標體重',
              value: '${data.targetWeight}',
              unit: 'kg',
              highlight: true,
            ),
            DataRowTile(
              label: '目標日期',
              value: data.targetDate,
              unit: '· 剩 9 週',
            ),
            DataRowTile(
              label: '每日熱量目標',
              value: '2,000',
              unit: 'kcal',
            ),
            const SizedBox(height: 24),

            OutlineButton(
              label: '記錄今天的體重',
              leadingIcon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
