import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/core/widgets/app_button.dart';
import 'package:workzy/core/widgets/app_logo.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Logo
              const AppLogo(),

              const SizedBox(height: 40),

              // Tagline
              Text(
                'Home services, simplified.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: BrandColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Find trusted professionals for plumbing, carpentry, painting, cleaning and more all in one app.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: BrandColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const Spacer(flex: 2),

              // Feature highlights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FeatureChip(
                    icon: Icons.verified_user_outlined,
                    label: 'Verified\nWorkers',
                  ),
                  _FeatureChip(
                    icon: Icons.schedule_outlined,
                    label: 'Quick\nBooking',
                  ),
                  _FeatureChip(
                    icon: Icons.star_outline_rounded,
                    label: 'Rated &\nReviewed',
                  ),
                ],
              ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.15),

              const Spacer(flex: 1),

              // Get Started button
              AppButton(
                onTap: () => context.go('/login'),
                width: double.infinity,
                height: 56,
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: BrandColors.lightGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: BrandColors.divider.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Icon(icon, color: BrandColors.primaryGreen, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: BrandColors.textSecondary,
            fontSize: 10,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
