import 'package:flutter/material.dart';
import 'package:workzy/core/theme/brand_colors.dart';

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
              color: backgroundColor ?? BrandColors.lightGray,
              width: 1.5,
            ),
            foregroundColor: foregroundColor ?? BrandColors.white,
            padding: padding,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _buildChild(),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? BrandColors.primaryGreen,
          foregroundColor: foregroundColor ?? BrandColors.shadeBlack,
          elevation: 0,
          padding: padding,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: isOutlined ? BrandColors.primaryGreen : BrandColors.shadeBlack,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          child,
        ],
      );
    }
    return child;
  }
}
