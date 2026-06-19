import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/mock_data.dart';

class HourlyTimeline extends StatelessWidget {
  final List<StatsMeal> meals;
  final String? currentTime;
  final ValueChanged<StatsMeal>? onMealTap;

  const HourlyTimeline({
    super.key,
    required this.meals,
    this.currentTime,
    this.onMealTap,
  });

  static const _startHour = 0;
  static const _endHour = 24;
  static const _pixelsPerHour = 42.0;
  static const _totalHeight = (_endHour - _startHour) * _pixelsPerHour;
  static const _gutterWidth = 42.0;

  double _topForTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return ((hour - _startHour) + minute / 60) * _pixelsPerHour;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _totalHeight + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Grid lines and hour labels
          for (var h = _startHour; h <= _endHour; h++) ...[
            Positioned(
              left: _gutterWidth,
              right: 0,
              top: (h - _startHour) * _pixelsPerHour,
              child: Container(height: 1, color: const Color(0xFFEDEAE0)),
            ),
            if (h < _endHour)
              Positioned(
                left: 0,
                top: (h - _startHour) * _pixelsPerHour - 6,
                child: SizedBox(
                  width: _gutterWidth - 8,
                  child: Text(
                    '${h.toString().padLeft(2, '0')}:00',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: const Color(0xFFB6B1A6),
                    ),
                  ),
                ),
              ),
          ],

          // Meal blocks
          ...meals.map((meal) => _buildMealBlock(meal)),

          // Now indicator (only shown for today)
          if (currentTime != null)
            Positioned(
              left: 0,
              right: 0,
              top: _topForTime(currentTime!),
              child: _buildNowIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildMealBlock(StatsMeal meal) {
    final top = _topForTime(meal.time);
    final isLatestMeal = meals.last == meal;

    return Positioned(
      left: _gutterWidth + 6,
      right: 0,
      top: top + 4,
      child: GestureDetector(
        onTap: () => onMealTap?.call(meal),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: isLatestMeal
                ? Border.all(color: AppColors.primary, width: 1.5)
                : Border.all(color: AppColors.borderLight),
            boxShadow: isLatestMeal
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Left accent bar for non-highlighted meals
              if (!isLatestMeal)
                Container(width: 3, color: AppColors.greenMedium),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isLatestMeal ? 13 : 10,
                    6,
                    13,
                    6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${meal.name} ',
                                    style: GoogleFonts.notoSansTc(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${meal.time} · ${meal.summary}',
                                    style: GoogleFonts.notoSansTc(
                                      fontSize: 11,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            meal.kcal.toString(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 5,
                          child: Row(
                            children: [
                              Expanded(
                                flex: meal.macros.protein,
                                child: Container(color: AppColors.primary),
                              ),
                              Expanded(
                                flex: meal.macros.carbs,
                                child: Container(color: AppColors.greenMedium),
                              ),
                              Expanded(
                                flex: meal.macros.fat,
                                child: Container(color: AppColors.greenPale),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'P${meal.macros.protein} · C${meal.macros.carbs} · F${meal.macros.fat} g · 點擊看明細 ›',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildNowIndicator() {
    return Row(
      children: [
        SizedBox(
          width: _gutterWidth - 8,
          child: Text(
            currentTime!,
            textAlign: TextAlign.right,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Container(height: 1.5, color: AppColors.primary),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '現在',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.background,
            ),
          ),
        ),
      ],
    );
  }
}
