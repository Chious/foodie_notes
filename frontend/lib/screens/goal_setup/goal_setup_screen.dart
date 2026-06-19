import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class GoalSetupScreen extends StatelessWidget {
  const GoalSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step indicator
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppColors.mutedText,
                        ),
                        children: [
                          TextSpan(
                            text: 'STEP 1',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: AppColors.primary,
                            ),
                          ),
                          const TextSpan(text: ' / 1'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('設定飲食目標', style: AppTextStyles.title(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(
                      '這些之後都可以隨時調整',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input cards row 1
                    Row(
                      children: [
                        Expanded(
                          child: _InputCard(label: '身高', value: '178', unit: 'cm'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InputCard(
                            label: '目前體重',
                            value: '80.0',
                            unit: 'kg',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Input cards row 2
                    Row(
                      children: [
                        Expanded(
                          child: _InputCard(
                            label: '目標體重',
                            value: '68.0',
                            unit: 'kg',
                            highlight: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InputCard(
                            label: '目標日期',
                            value: '2026/9/30',
                            valueFontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly estimate dark card
                    const _WeeklyEstimateCard(),
                  ],
                ),
              ),
            ),
            // Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 32),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: PrimaryButton(
                label: '開始記錄',
                onPressed: () => context.go('/today'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool highlight;
  final double valueFontSize;

  const _InputCard({
    required this.label,
    required this.value,
    this.unit,
    this.highlight = false,
    this.valueFontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: highlight ? AppColors.primary : AppColors.border,
          width: highlight ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansTc(
              fontSize: 12,
              color: highlight ? AppColors.primary : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: valueFontSize,
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
        ],
      ),
    );
  }
}

class _WeeklyEstimateCard extends StatelessWidget {
  const _WeeklyEstimateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '每週估計減重',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.background.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '0.8',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -1,
                            height: 0.85,
                            color: AppColors.background,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'kg / 週',
                            style: GoogleFonts.notoSansTc(
                              fontSize: 14,
                              color: AppColors.background.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '需減重',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 12,
                      color: AppColors.background.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '−12.0',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greenLight,
                          ),
                        ),
                        TextSpan(
                          text: ' kg',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppColors.background.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Health range bar
          SizedBox(
            height: 14,
            child: Stack(
              children: [
                // Track
                Positioned(
                  left: 0,
                  right: 0,
                  top: 4,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Healthy range
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2,
                  top: 4,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.greenLight.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                // Dot indicator
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.28,
                  top: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.dark, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.5',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: AppColors.background.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '健康範圍',
                style: GoogleFonts.notoSansTc(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenLight,
                ),
              ),
              Text(
                '1.0 kg',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: AppColors.background.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              height: 1,
              color: AppColors.background.withValues(alpha: 0.12),
            ),
          ),
          // Estimated timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '預估期間',
                style: GoogleFonts.notoSansTc(
                  fontSize: 13,
                  color: AppColors.background.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '約 15 週 · 達標於 9/30',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.background,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
