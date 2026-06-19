import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/segment_toggle.dart';

class PortionSheet extends StatefulWidget {
  final FoodItem food;
  final String mealLabel;

  const PortionSheet({
    super.key,
    required this.food,
    this.mealLabel = '午餐',
  });

  @override
  State<PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends State<PortionSheet> {
  double _quantity = 1.0;
  int _unitIndex = 0;

  bool get _isGramMode => _unitIndex == 1;
  int get _servingG => widget.food.defaultServingGrams;

  double get _grams => _isGramMode ? _quantity : _quantity * _servingG;
  double get _multiplier => _grams / 100;

  int get _totalKcal => (widget.food.kcalPer100g * _multiplier).round();
  int get _totalProtein =>
      (widget.food.proteinPer100g * _multiplier).round();
  int get _totalCarbs =>
      (widget.food.carbsPer100g * _multiplier).round();
  int get _totalFat => (widget.food.fatPer100g * _multiplier).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Source label
            Text(
              '台灣資料庫',
              style: AppTextStyles.label(color: AppColors.primary),
            ),
            const SizedBox(height: 6),

            // Food name
            Text(
              widget.food.name,
              style: AppTextStyles.title(fontSize: 28),
            ),
            const SizedBox(height: 24),

            // Kcal + macro row
            Container(
              padding: const EdgeInsets.only(bottom: 22),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '$_totalKcal',
                            style: AppTextStyles.heroNumber(fontSize: 58),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('KCAL', style: AppTextStyles.suffix()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _MacroColumn(label: '蛋白', value: '${_totalProtein}g'),
                  const SizedBox(width: 8),
                  _MacroColumn(label: '碳水', value: '${_totalCarbs}g'),
                  const SizedBox(width: 8),
                  _MacroColumn(label: '脂肪', value: '${_totalFat}g'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Unit toggle
            SegmentToggle(
              labels: const ['份', '公克'],
              selectedIndex: _unitIndex,
              onChanged: (i) {
                setState(() {
                  if (i == 1 && _unitIndex == 0) {
                    _quantity = _quantity * _servingG;
                  } else if (i == 0 && _unitIndex == 1) {
                    _quantity = (_quantity / _servingG).clamp(0.5, 4.0);
                  }
                  _unitIndex = i;
                });
              },
            ),
            const SizedBox(height: 20),

            // Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('份量', style: AppTextStyles.bodyBold()),
                    const SizedBox(height: 3),
                    Text(
                      '1 份 ≈ $_servingG g',
                      style: AppTextStyles.unit(fontSize: 11),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _StepperButton(
                      icon: Icons.remove,
                      filled: false,
                      onTap: () {
                        final step = _isGramMode ? 10.0 : 0.5;
                        final min = _isGramMode ? 10.0 : 0.5;
                        if (_quantity > min) {
                          setState(() => _quantity -= step);
                        }
                      },
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: _isGramMode ? 72 : 48,
                      child: Text(
                        _isGramMode
                            ? '${_quantity.toInt()}'
                            : _quantity == _quantity.roundToDouble()
                                ? '${_quantity.toInt()}'
                                : _quantity.toStringAsFixed(1),
                        style: AppTextStyles.number(fontSize: 30),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _isGramMode ? ' g' : ' 份',
                        style: AppTextStyles.unit(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 18),
                    _StepperButton(
                      icon: Icons.add,
                      filled: true,
                      onTap: () {
                        final step = _isGramMode ? 10.0 : 0.5;
                        setState(() => _quantity += step);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.borderLight,
                thumbColor: AppColors.background,
                overlayColor: AppColors.primary.withValues(alpha: 0.12),
                trackHeight: 3,
                thumbShape: _BorderedThumbShape(),
              ),
              child: _isGramMode
                  ? Slider(
                      value: _quantity.clamp(10.0, _servingG * 4.0),
                      min: 10,
                      max: _servingG * 4.0,
                      divisions: ((_servingG * 4 - 10) / 10).round(),
                      onChanged: (v) =>
                          setState(() => _quantity = (v / 10).round() * 10.0),
                    )
                  : Slider(
                      value: _quantity.clamp(0.5, 4.0),
                      min: 0.5,
                      max: 4.0,
                      divisions: 7,
                      onChanged: (v) => setState(() => _quantity = v),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _isGramMode
                    ? ['10', '$_servingG', '${_servingG * 2}', '${_servingG * 3}', '${_servingG * 4}g']
                        .map((t) => Text(t, style: AppTextStyles.unit(fontSize: 11)))
                        .toList()
                    : ['½', '1', '2', '3', '4 份']
                        .map((t) => Text(t, style: AppTextStyles.unit(fontSize: 11)))
                        .toList(),
              ),
            ),
            const SizedBox(height: 18),

            PrimaryButton(
              label: '加入${widget.mealLabel}',
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: AppColors.dark,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  final String label;
  final String value;

  const _MacroColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: AppTextStyles.unit(fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.number(fontSize: 16)),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 22,
          color: filled ? Colors.white : AppColors.mutedText,
        ),
      ),
    );
  }
}

class _BorderedThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(10);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      10,
      Paint()..color = AppColors.background,
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
