import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.actionLabel,
    this.onActionTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (trailing == null && actionLabel == null) {
      return Text(title, style: titleStyle ?? context.typography.labelLarge);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: titleStyle ?? context.typography.labelLarge),
        if (trailing != null)
          trailing!
        else if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
