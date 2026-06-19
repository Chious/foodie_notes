import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/recognized_item_tile.dart';
import '../food_search/portion_sheet.dart';

class AiResultScreen extends StatefulWidget {
  const AiResultScreen({super.key});

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  final _result = MockData.recognitionResult;
  late final List<bool> _selections;
  final _searchController = TextEditingController();
  final String _mealPeriod = '午餐';

  @override
  void initState() {
    super.initState();
    _selections = _result.items.map((i) => i.selected).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _itemKcal(RecognizedItem item) {
    final g = item.foodItem.defaultServingGrams;
    return (item.foodItem.kcalPer100g * item.quantity * g / 100).round();
  }

  int _itemMacro(RecognizedItem item, double per100g) {
    final g = item.foodItem.defaultServingGrams;
    return (per100g * item.quantity * g / 100).round();
  }

  int get _totalKcal {
    int sum = 0;
    for (int i = 0; i < _result.items.length; i++) {
      if (_selections[i]) sum += _itemKcal(_result.items[i]);
    }
    return sum;
  }

  int get _totalProtein {
    int sum = 0;
    for (int i = 0; i < _result.items.length; i++) {
      if (_selections[i]) {
        sum += _itemMacro(
          _result.items[i],
          _result.items[i].foodItem.proteinPer100g,
        );
      }
    }
    return sum;
  }

  int get _totalCarbs {
    int sum = 0;
    for (int i = 0; i < _result.items.length; i++) {
      if (_selections[i]) {
        sum += _itemMacro(
          _result.items[i],
          _result.items[i].foodItem.carbsPer100g,
        );
      }
    }
    return sum;
  }

  int get _totalFat {
    int sum = 0;
    for (int i = 0; i < _result.items.length; i++) {
      if (_selections[i]) {
        sum += _itemMacro(
          _result.items[i],
          _result.items[i].foodItem.fatPer100g,
        );
      }
    }
    return sum;
  }

  int get _dailyPct =>
      ((_totalKcal / MockData.dailyData.goalCalories) * 100).round();

  void _showPortionSheet(FoodItem food) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PortionSheet(food: food, mealLabel: _mealPeriod),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 14, 26, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI 已辨識 · ${_result.items.length} 項',
                          style: AppTextStyles.label(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _result.mealName,
                      style: AppTextStyles.title(fontSize: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '勾選要加入記錄的項目 · 點任一項可調整份量',
                      style: AppTextStyles.body(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.segmentBg,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 17,
                            color: AppColors.mutedText,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '搜尋資料庫，或手動新增食物',
                            style: AppTextStyles.body(
                              fontSize: 14,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Item list
                    ...List.generate(_result.items.length, (i) {
                      return RecognizedItemTile(
                        item: _result.items[i],
                        selected: _selections[i],
                        onCheckChanged: (v) {
                          setState(() => _selections[i] = v ?? false);
                        },
                        onTap: () =>
                            _showPortionSheet(_result.items[i].foodItem),
                      );
                    }),

                    // Meal summary
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '這一餐 / 每日',
                          style: AppTextStyles.label(),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$_totalKcal ',
                                style: AppTextStyles.heroNumber(fontSize: 30),
                              ),
                              TextSpan(
                                text: 'KCAL · $_dailyPct%',
                                style: AppTextStyles.unit(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Macro progress bars
                    _MealMacroRow(
                      label: '蛋白',
                      current: _totalProtein,
                      goal: MockData.dailyData.macros.proteinGoal,
                    ),
                    const SizedBox(height: 13),
                    _MealMacroRow(
                      label: '碳水',
                      current: _totalCarbs,
                      goal: MockData.dailyData.macros.carbsGoal,
                    ),
                    const SizedBox(height: 13),
                    _MealMacroRow(
                      label: '脂肪',
                      current: _totalFat,
                      goal: MockData.dailyData.macros.fatGoal,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(26, 14, 26, 30),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '時段',
                          style: AppTextStyles.body(
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _mealPeriod,
                          style: AppTextStyles.bodyBold(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: '確認記錄',
                      onPressed: () => context.go('/today'),
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

class _MealMacroRow extends StatelessWidget {
  final String label;
  final int current;
  final int goal;

  const _MealMacroRow({
    required this.label,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? ((current / goal) * 100).round() : 0;
    final ratio = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label ${current}g', style: AppTextStyles.body(fontSize: 13)),
            Text(
              '佔 $pct%',
              style: AppTextStyles.unit(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
