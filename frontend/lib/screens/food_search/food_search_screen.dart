import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/dashed_border_button.dart';
import '../../widgets/food_search_bar.dart';
import '../../widgets/food_search_result_tile.dart';
import '../../widgets/section_header.dart';
import 'portion_sheet.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  List<FoodItem> get _filteredResults => _query.isEmpty
      ? []
      : MockData.allFoodItems
            .where((f) => f.name.contains(_query))
            .toList();

  void _showPortionSheet(FoodItem food) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PortionSheet(food: food),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('搜尋食物', style: AppTextStyles.title(fontSize: 30)),
            const SizedBox(height: 18),
            FoodSearchBar(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _query.isEmpty ? _buildRecentSection() : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const SectionHeader(text: '最近常吃'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MockData.recentFoods
                .map(
                  (name) => GestureDetector(
                    onTap: () {
                      _controller.text = name;
                      setState(() => _query = name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        name,
                        style: AppTextStyles.body(fontSize: 13),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final results = _filteredResults;
    return ListView.builder(
      itemCount: results.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'SOURCE · 台灣食品營養成分資料庫',
              style: AppTextStyles.unit(fontSize: 11),
            ),
          );
        }
        if (index <= results.length) {
          final food = results[index - 1];
          return FoodSearchResultTile(
            food: food,
            onTap: () => _showPortionSheet(food),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: DashedBorderButton(
            label: '找不到？手動新增食物並加入這一餐',
            onTap: () {},
          ),
        );
      },
    );
  }
}
