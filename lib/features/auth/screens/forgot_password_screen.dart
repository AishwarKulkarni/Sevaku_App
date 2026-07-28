import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/core/widgets/app_button.dart';
import 'package:sevaku/core/widgets/app_text_field.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isSendingOtp = false;
  bool _isResetting = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    setState(() => _isSendingOtp = true);

    try {
      final authService = ref.read(authServiceProvider);
      final devOtp = await authService.sendPasswordReset(email);
      if (mounted) {
        setState(() {
          _otpSent = true;
          _isSendingOtp = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              devOtp != null
                  ? 'OTP generated: $devOtp (Dev Mode)'
                  : 'OTP sent to your email!',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingOtp = false);
        String msg = e.toString();
        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map<String, dynamic> && data.containsKey('detail')) {
            msg = data['detail'].toString();
          } else if (data is String) {
            msg = data;
          } else {
            msg = e.response?.statusMessage ?? msg;
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $msg')));
      }
    }
  }

  void _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isResetting = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resetPassword(email, otp, newPassword);
      if (mounted) {
        setState(() => _isResetting = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isResetting = false);
        String msg = e.toString();
        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map<String, dynamic> && data.containsKey('detail')) {
            msg = data['detail'].toString();
          } else if (data is String) {
            msg = data;
          } else {
            msg = e.response?.statusMessage ?? msg;
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $msg')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: context.colors.lightGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.colors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: context.colors.primaryGreen,
                  size: 40,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text('Success!', style: context.typography.headingMedium),
              const SizedBox(height: 8),
              Text(
                'Your password has been reset successfully. You can now login with your new password.',
                style: context.typography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                onTap: () {
                  Navigator.pop(context); // close dialog
                  context.pop(); // go back to login
                },
                width: double.infinity,
                height: 48,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.shadeBlack,
      appBar: AppBar(
        backgroundColor: context.colors.shadeBlack,
        title: const Text('Forgot Password'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _otpSent ? 'Reset Password' : 'Find Your Account',
                style: context.typography.headingLarge,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 12),

              Text(
                _otpSent
                    ? 'Enter the 6-digit code sent to your email and choose a new password.'
                    : 'Enter your registered email address to receive a password reset code.',
                style: context.typography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 40),

              AppTextField(
                controller: _emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                readOnly: _otpSent,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              if (!_otpSent) ...[
                const SizedBox(height: 32),
                AppButton(
                  onTap: _sendOtp,
                  isLoading: _isSendingOtp,
                  width: double.infinity,
                  height: 56,
                  child: const Text(
                    'Send Reset Code',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              ] else ...[
                const SizedBox(height: 20),

                AppTextField(
                  controller: _otpController,
                  hintText: '6-digit OTP Code',
                  prefixIcon: Icons.password_rounded,
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                AppTextField(
                  controller: _newPasswordController,
                  hintText: 'New Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                AppButton(
                  onTap: _resetPassword,
                  isLoading: _isResetting,
                  width: double.infinity,
                  height: 56,
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _otpSent = false;
                        _otpController.clear();
                        _newPasswordController.clear();
                      });
                    },
                    child: Text(
                      'Use a different email',
                      style: context.typography.bodyMedium.copyWith(
                        color: context.colors.primaryGreen,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
