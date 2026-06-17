import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.center_focus_strong_outlined,
                                  size: 18,
                                  color: AppColors.background,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '食誌 · AI 食記',
                                style: GoogleFonts.notoSansTc(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: AppColors.background,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),
                          Text(
                            'EAT · LOG · REACH',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppColors.navInactive,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '掃一下,\n記好每一餐,\n走向目標體重。',
                            style: GoogleFonts.notoSansTc(
                              fontSize: 46,
                              fontWeight: FontWeight.w300,
                              height: 1.18,
                              letterSpacing: -1.5,
                              color: AppColors.background,
                            ),
                          ),
                          const Spacer(),
                          _FeatureItem(number: '01', text: '條碼或拍照,AI 在背景辨識'),
                          const _Divider(),
                          _FeatureItem(number: '02', text: '台灣飲食資料庫,份量一鍵確認'),
                          const _Divider(),
                          _FeatureItem(number: '03', text: '設定目標日期,追蹤每週進度'),
                          const SizedBox(height: 40),
                          PrimaryButton(
                            label: '設定我的目標',
                            trailingIcon: Icons.arrow_forward,
                            onPressed: () => context.go('/goal-setup'),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String number;
  final String text;

  const _FeatureItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              number,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.notoSansTc(
              fontSize: 15,
              color: AppColors.background.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.background.withValues(alpha: 0.12),
    );
  }
}
