import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusChip({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(status);
    final bgColor = AppTheme.getStatusBgColor(status);

    IconData icon;
    switch (status) {
      case 'Checked In':
        icon = Icons.login_rounded;
        break;
      case 'Checked Out':
        icon = Icons.logout_rounded;
        break;
      case 'Registered':
      default:
        icon = Icons.schedule_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
