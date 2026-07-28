import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool isOutlined;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const AppButton({
    super.key,
    this.onTap,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.isOutlined = false,
    this.isLoading = false,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height ?? 50,
        child: OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? context.colors.lightGray,
              width: 1.5,
            ),
            foregroundColor: foregroundColor ?? context.colors.white,
            padding: padding,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _buildChild(context),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.colors.primaryGreen,
          foregroundColor: foregroundColor ?? context.colors.shadeBlack,
          elevation: 0,
          padding: padding,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: isOutlined
              ? context.colors.primaryGreen
              : context.colors.shadeBlack,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), child],
      );
    }
    return child;
  }
}
