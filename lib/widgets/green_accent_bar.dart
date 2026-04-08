import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GreenAccentBar extends StatelessWidget {
  const GreenAccentBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2,
      color: AppColors.green,
    );
  }
}