import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sevaku/core/theme/brand_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:sevaku/core/utils/image_helper.dart';
import 'package:sevaku/core/widgets/app_button.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      appBar: AppBar(
        backgroundColor: BrandColors.shadeBlack,
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile photo
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BrandColors.primaryGreen,
                        width: 3,
                      ),
                      image: resolveImageProvider(user?.photoUrl) != null
                          ? DecorationImage(
                              image: resolveImageProvider(user!.photoUrl)!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: resolveImageProvider(user?.photoUrl) == null
                        ? const Icon(Icons.person, size: 48, color: BrandColors.textMuted)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        if (user == null) return;
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (picked == null) return;
                        final storage = ref.read(storageServiceProvider);
                        final firestore = ref.read(firestoreServiceProvider);
                        final path = await storage.uploadProfilePhoto(user.uid, picked);
                        await firestore.updateUser(user.uid, {'photoUrl': path});
                        ref.read(authProvider.notifier).refreshUser();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: BrandColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: BrandColors.shadeBlack, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: BrandColors.shadeBlack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 16),

            // Name & Role
            Text(
              user?.name ?? 'User',
              style: AppTextStyles.headingMedium,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: AppTextStyles.bodySmall.copyWith(color: BrandColors.textMuted),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: BrandColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (user?.role ?? 'customer').toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: BrandColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // Menu items
            _ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                context.push('/edit-profile');
              },
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),
            _ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'My Addresses',
              onTap: () {},
            ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.05),
            _ProfileMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {},
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),
            _ProfileMenuItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
            ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.05),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'About Sevaku',
              onTap: () {},
            ).animate().fadeIn(delay: 550.ms).slideX(begin: -0.05),

            const SizedBox(height: 28),

            AppButton(
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/');
              },
              width: double.infinity,
              backgroundColor: BrandColors.error.withValues(alpha: 0.15),
              foregroundColor: BrandColors.error,
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.error,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 32),

            Text(
              'Sevaku v1.0.0',
              style: AppTextStyles.caption,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tileColor: BrandColors.lightGray,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BrandColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: BrandColors.white, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: BrandColors.textMuted,
          size: 22,
        ),
      ),
    );
  }
}
