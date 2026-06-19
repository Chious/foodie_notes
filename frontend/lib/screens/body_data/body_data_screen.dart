import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/mock_data.dart';
import '../../widgets/data_row_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/primary_button.dart';

class BodyDataScreen extends StatefulWidget {
  const BodyDataScreen({super.key});

  @override
  State<BodyDataScreen> createState() => _BodyDataScreenState();
}

class _BodyDataScreenState extends State<BodyDataScreen> {
  static const _base = MockData.bodyData;

  double _height = _base.height;
  double _currentWeight = _base.currentWeight;
  double _targetWeight = _base.targetWeight;
  String _targetDate = _base.targetDate;

  double get _weightLost => _base.startWeight - _currentWeight;
  double get _weightRemaining => _currentWeight - _targetWeight;
  double get _progress =>
      ((_base.startWeight - _currentWeight) /
              (_base.startWeight - _targetWeight))
          .clamp(0.0, 1.0);

  Future<double?> _showNumberDialog(String title, double current, String unit) {
    final controller = TextEditingController(
      text: current == current.roundToDouble()
          ? current.toInt().toString()
          : current.toStringAsFixed(1),
    );
    return showDialog<double>(
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
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: GoogleFonts.spaceGrotesk(fontSize: 28, color: AppColors.dark),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.mutedText,
            ),
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
  }

  Future<void> _editHeight() async {
    final result = await _showNumberDialog('身高', _height, 'cm');
    if (result != null) setState(() => _height = result);
  }

  Future<void> _recordWeight() async {
    final result = await _showNumberDialog('記錄體重', _currentWeight, 'kg');
    if (result != null && mounted) {
      setState(() => _currentWeight = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已記錄體重 ${result.toStringAsFixed(1)} kg'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _editTarget() async {
    final result = await _showNumberDialog('目標體重', _targetWeight, 'kg');
    if (result != null) setState(() => _targetWeight = result);
  }

  Future<void> _editTargetDate() async {
    final parts = _targetDate.split('/');
    final initial = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
      setState(() {
        _targetDate = '${picked.year}/${picked.month}/${picked.day}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  '$_currentWeight',
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
                  value: _progress,
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
                  '目標 $_targetWeight',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                Text(
                  '起點 ${_base.startWeight} KG',
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
                    text: '${_weightRemaining.toStringAsFixed(1)} kg',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' · 已減 ${_weightLost.toStringAsFixed(1)} kg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Data rows
            const SectionHeader(text: '資料'),
            DataRowTile(
              label: '身高',
              value: '${_height.toInt()}',
              unit: 'cm',
              onTap: _editHeight,
            ),
            DataRowTile(
              label: '目前體重',
              value: '$_currentWeight',
              unit: 'kg',
              onTap: _recordWeight,
            ),
            DataRowTile(
              label: '目標體重',
              value: '$_targetWeight',
              unit: 'kg',
              highlight: true,
              onTap: _editTarget,
            ),
            DataRowTile(
              label: '目標日期',
              value: _targetDate,
              onTap: _editTargetDate,
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
              onPressed: _recordWeight,
            ),
          ],
        ),
      ),
    );
  }
}
