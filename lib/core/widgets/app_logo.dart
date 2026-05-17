import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLogo extends StatelessWidget {
  /// Width of the logo image. Defaults to [double.infinity].
  final double? width;

  /// Height of the logo image.
  final double? height;

  /// Whether to play the entrance animation. Defaults to [true].
  final bool animate;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image(
      image: const AssetImage('assets/logo/Sevaku_t.png'),
      fit: BoxFit.contain,
      width: width,
      height: height,
    );

    if (!animate) return image;

    return image
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}
