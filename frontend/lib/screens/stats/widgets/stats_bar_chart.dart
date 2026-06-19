import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../models/mock_data.dart';

class StatsBarChart extends StatefulWidget {
  final List<DayCalorie> bars;
  final int calorieGoal;
  final double chartHeight;
  final String targetLabel;
  final double barRadius;
  final double barGap;

  const StatsBarChart({
    super.key,
    required this.bars,
    required this.calorieGoal,
    required this.chartHeight,
    required this.targetLabel,
    this.barRadius = 5,
    this.barGap = 9,
  });

  @override
  State<StatsBarChart> createState() => _StatsBarChartState();
}

class _StatsBarChartState extends State<StatsBarChart> {
  int? _tappedIndex;

  Color _barColor(DayCalorie day, bool isTapped) {
    if (day.status == DayStatus.future) return AppColors.borderLight;
    if (isTapped) return AppColors.primary;
    if (day.status == DayStatus.today) return AppColors.primary;
    final ratio = day.kcal / widget.calorieGoal;
    return ratio >= 0.75 ? AppColors.greenMedium : AppColors.greenMuted;
  }

  String _formatKcal(int kcal) {
    if (kcal >= 1000) {
      return '${kcal ~/ 1000},${(kcal % 1000).toString().padLeft(3, '0')}';
    }
    return kcal.toString();
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _tappedIndex;
    final barsAreaHeight = widget.chartHeight - 28;

    return SizedBox(
      height: widget.chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final barCount = widget.bars.length;
          final totalGap = widget.barGap * (barCount - 1);
          final barWidth = (totalWidth - totalGap) / barCount;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Dashed target line
              Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(double.infinity, 1.5),
                  painter: _DashedLinePainter(),
                ),
              ),
              // Target label
              Positioned(
                top: 6,
                right: 0,
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    widget.targetLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppColors.navInactive,
                    ),
                  ),
                ),
              ),
              // Bars
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 28,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.bars.asMap().entries.map((entry) {
                    final i = entry.key;
                    final day = entry.value;
                    final ratio = day.kcal > 0
                        ? (day.kcal / widget.calorieGoal).clamp(0.0, 1.0)
                        : 0.0;
                    final isTapped = activeIndex == i;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (day.kcal > 0) {
                            setState(() {
                              _tappedIndex = _tappedIndex == i ? null : i;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: i == 0 ? 0 : widget.barGap / 2,
                            right: i == widget.bars.length - 1
                                ? 0
                                : widget.barGap / 2,
                          ),
                          child: FractionallySizedBox(
                            heightFactor: ratio == 0 ? 0 : ratio,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 4),
                              decoration: BoxDecoration(
                                color: _barColor(day, isTapped),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(widget.barRadius),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Floating label for tapped or today bar
              if (activeIndex != null &&
                  widget.bars[activeIndex].kcal > 0) ...[
                _buildFloatingLabel(
                  activeIndex,
                  barsAreaHeight,
                  barWidth,
                  totalWidth,
                ),
              ] else ...[
                for (var i = 0; i < widget.bars.length; i++)
                  if (widget.bars[i].status == DayStatus.today &&
                      widget.bars[i].kcal > 0)
                    _buildFloatingLabel(i, barsAreaHeight, barWidth, totalWidth),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingLabel(
    int index,
    double barsAreaHeight,
    double barWidth,
    double totalWidth,
  ) {
    final day = widget.bars[index];
    final ratio = (day.kcal / widget.calorieGoal).clamp(0.0, 1.0);
    final barTop = 28 + barsAreaHeight * (1 - ratio);
    final barCenterX =
        (totalWidth / widget.bars.length) * index +
        (totalWidth / widget.bars.length) / 2;

    return Positioned(
      top: barTop - 20,
      left: barCenterX - 28,
      child: SizedBox(
        width: 56,
        child: Text(
          _formatKcal(day.kcal),
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9CCBC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashGap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
