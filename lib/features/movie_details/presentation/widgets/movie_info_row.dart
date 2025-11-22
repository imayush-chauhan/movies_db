import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MovieInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const MovieInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? AppTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}