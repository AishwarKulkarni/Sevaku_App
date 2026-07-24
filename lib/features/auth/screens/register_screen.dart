import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/core/constants/app_constants.dart';
import 'package:sevaku/core/theme/brand_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:sevaku/core/widgets/app_button.dart';
import 'package:sevaku/core/widgets/app_text_field.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String _selectedRole = AppConstants.roleCustomer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        final role = next.user?.role ?? 'customer';
        if (role == 'worker') {
          context.go('/worker');
        } else {
          context.go('/customer');
        }
      }
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                IconButton(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: BrandColors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: BrandColors.lightGray,
                    padding: const EdgeInsets.all(12),
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Create Account',
                  style: AppTextStyles.headingLarge,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                const SizedBox(height: 4),
                Text(
                  'Join Sevaku and find the best home services',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: BrandColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Role Selector
                Text(
                  'Choose your path',
                  style: AppTextStyles.labelLarge,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleTile(
                        title: 'Customer',
                        subtitle: 'Hire workers',
                        icon: Icons.person_outline,
                        isSelected: _selectedRole == AppConstants.roleCustomer,
                        onTap: () => setState(
                          () => _selectedRole = AppConstants.roleCustomer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleTile(
                        title: 'Worker',
                        subtitle: 'Offer services',
                        icon: Icons.handyman_outlined,
                        isSelected: _selectedRole == AppConstants.roleWorker,
                        onTap: () => setState(
                          () => _selectedRole = AppConstants.roleWorker,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // Name
                AppTextField(
                  controller: _nameController,
                  hintText: 'Full name',
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your name';
                    return null;
                  },
                ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),

                const SizedBox(height: 16),

                // Email
                AppTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your email';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                const SizedBox(height: 16),

                // Phone
                AppTextField(
                  controller: _phoneController,
                  hintText: 'Phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1),

                const SizedBox(height: 16),

                // Password
                AppTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: BrandColors.textMuted,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                const SizedBox(height: 32),

                // Register Button
                AppButton(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      ref
                          .read(authProvider.notifier)
                          .register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _phoneController.text.trim(),
                            _passwordController.text,
                            _selectedRole,
                          );
                    }
                  },
                  isLoading: authState.isLoading,
                  width: double.infinity,
                  height: 54,
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                // Login link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: BrandColors.textMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: BrandColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? BrandColors.white.withValues(alpha: 0.1)
              : BrandColors.lightGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? BrandColors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? BrandColors.white : BrandColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? BrandColors.white : BrandColors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? BrandColors.white.withValues(alpha: 0.7)
                    : BrandColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
