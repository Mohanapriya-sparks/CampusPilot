import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        icon = Icons.check_circle_rounded;
        color = AppColors.primary;
        break;
      case 'OPEN':
      case 'IN PROGRESS':
        icon = Icons.radio_button_checked_rounded;
        color = AppColors.accent;
        break;
      case 'CLOSING SOON':
        icon = Icons.priority_high_rounded;
        color = AppColors.primaryDark;
        break;
      default:
        icon = Icons.radio_button_unchecked_rounded;
        color = AppColors.textSecondary;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
