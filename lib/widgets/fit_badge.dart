import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FitBadge extends StatelessWidget {
  final int score;
  final String label;

  const FitBadge({
    super.key,
    required this.score,
    this.label = 'Fit',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(
        '$score% $label',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
