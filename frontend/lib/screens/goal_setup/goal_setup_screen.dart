import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  double _height = 178;
  double _currentWeight = 80.0;
  double _targetWeight = 68.0;
  DateTime _targetDate = DateTime(2026, 9, 30);

  double get _weightToLose => _currentWeight - _targetWeight;

  int get _weeksNeeded {
    final days = _targetDate.difference(DateTime.now()).inDays;
    return days > 0 ? (days / 7).ceil() : 0;
  }

  double get _weeklyRate =>
      _weeksNeeded > 0 ? _weightToLose / _weeksNeeded : 0;

  Future<void> _editNumber(
    String title,
    double current,
    ValueChanged<double> onSave,
  ) async {
    final controller = TextEditingController(
      text: current == current.roundToDouble()
          ? current.toInt().toString()
          : current.toStringAsFixed(1),
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          title,
          style: GoogleFonts.notoSansTc(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(fontSize: 22, color: AppColors.dark),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              '取消',
              style: GoogleFonts.notoSansTc(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: Text(
              '確定',
              style: GoogleFonts.notoSansTc(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => onSave(result));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.background,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  String _formatDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

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
                          child: _InputCard(
                            label: '身高',
                            value: _height.toInt().toString(),
                            unit: 'cm',
                            onTap: () => _editNumber(
                              '身高 (cm)',
                              _height,
                              (v) => _height = v,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InputCard(
                            label: '目前體重',
                            value: _currentWeight.toStringAsFixed(1),
                            unit: 'kg',
                            onTap: () => _editNumber(
                              '目前體重 (kg)',
                              _currentWeight,
                              (v) => _currentWeight = v,
                            ),
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
                            value: _targetWeight.toStringAsFixed(1),
                            unit: 'kg',
                            highlight: true,
                            onTap: () => _editNumber(
                              '目標體重 (kg)',
                              _targetWeight,
                              (v) => _targetWeight = v,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _InputCard(
                            label: '目標日期',
                            value: _formatDate(_targetDate),
                            valueFontSize: 18,
                            onTap: _pickDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly estimate dark card
                    _WeeklyEstimateCard(
                      weeklyRate: _weeklyRate,
                      weightToLose: _weightToLose,
                      weeksNeeded: _weeksNeeded,
                      targetDate: _targetDate,
                      onWeeklyRateChanged: _weeksNeeded > 0
                          ? (rate) {
                              setState(() {
                                _targetWeight = (_currentWeight -
                                        rate * _weeksNeeded)
                                    .clamp(30.0, _currentWeight);
                              });
                            }
                          : null,
                    ),
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
  final VoidCallback? onTap;

  const _InputCard({
    required this.label,
    required this.value,
    this.unit,
    this.highlight = false,
    this.valueFontSize = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _WeeklyEstimateCard extends StatelessWidget {
  final double weeklyRate;
  final double weightToLose;
  final int weeksNeeded;
  final DateTime targetDate;
  final ValueChanged<double>? onWeeklyRateChanged;

  const _WeeklyEstimateCard({
    required this.weeklyRate,
    required this.weightToLose,
    required this.weeksNeeded,
    required this.targetDate,
    this.onWeeklyRateChanged,
  });

  bool get _isHealthy => weeklyRate <= 1.0;

  @override
  Widget build(BuildContext context) {
    final rateStr = weeklyRate.toStringAsFixed(1);
    final loseStr =
        '${weightToLose >= 0 ? '−' : '+'}${weightToLose.abs().toStringAsFixed(1)}';
    final dateStr = '${targetDate.month}/${targetDate.day}';

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
                          rateStr,
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
                              color:
                                  AppColors.background.withValues(alpha: 0.6),
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
                          text: loseStr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _isHealthy
                                ? AppColors.greenLight
                                : const Color(0xFFE8A87C),
                          ),
                        ),
                        TextSpan(
                          text: ' kg',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color:
                                AppColors.background.withValues(alpha: 0.5),
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
          // Health range bar (draggable)
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final fraction = (weeklyRate - 0.5) / 0.5;
              final dotLeft =
                  (w * 0.2 + fraction * w * 0.6 - 7).clamp(0.0, w - 14);

              void handlePosition(double dx) {
                final f = (dx - w * 0.2) / (w * 0.6);
                final rate = (0.5 + f * 0.5).clamp(0.3, 1.2);
                onWeeklyRateChanged?.call(rate);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => handlePosition(d.localPosition.dx),
                onPanUpdate: (d) => handlePosition(d.localPosition.dx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: SizedBox(
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
                              color: AppColors.background
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        // Healthy range
                        Positioned(
                          left: w * 0.2,
                          right: w * 0.2,
                          top: 4,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.greenLight
                                  .withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        // Dot indicator
                        Positioned(
                          left: dotLeft,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _isHealthy
                                  ? AppColors.greenLight
                                  : const Color(0xFFE8A87C),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.dark, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                  color: _isHealthy
                      ? AppColors.greenLight
                      : const Color(0xFFE8A87C),
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
                weeksNeeded > 0
                    ? '約 $weeksNeeded 週 · 達標於 $dateStr'
                    : '請設定未來日期',
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
