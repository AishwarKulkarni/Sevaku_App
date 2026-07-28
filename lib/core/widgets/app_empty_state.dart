import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.colors.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: context.typography.bodyMedium.copyWith(
              color: context.colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: context.typography.bodySmall.copyWith(
                color: context.colors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.colors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                actionLabel!,
                style: context.typography.labelLarge.copyWith(
                  color: context.colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
