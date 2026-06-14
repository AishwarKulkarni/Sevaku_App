import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/core/theme/brand_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:sevaku/core/widgets/app_button.dart';
import 'package:sevaku/core/widgets/app_text_field.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';
import 'package:sevaku/models/user_model.dart';
import 'package:sevaku/models/worker_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoadingData = true;
  bool _isSaving = false;

  UserModel? _baseUser;
  WorkerModel? _workerProfile;

  // Base fields
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // Worker fields
  final _bioCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _hourlyRateCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _serviceAreasCtrl = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        context.pop();
      }
      return;
    }

    _baseUser = user;
    _nameCtrl.text = user.name;
    _phoneCtrl.text = user.phone;
    _cityCtrl.text = user.city;

    if (user.role == 'worker') {
      final worker = await ref
          .read(firestoreServiceProvider)
          .getWorker(user.uid);
      if (worker != null) {
        _workerProfile = worker;
        _bioCtrl.text = worker.bio;
        _categoryCtrl.text = worker.category;
        _hourlyRateCtrl.text = worker.hourlyRate > 0
            ? worker.hourlyRate.toInt().toString()
            : '';
        _skillsCtrl.text = worker.skills.join(', ');
        _serviceAreasCtrl.text = worker.serviceAreas.join(', ');
        _isAvailable = worker.isAvailable;
      }
    }

    if (mounted) setState(() => _isLoadingData = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    _categoryCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _skillsCtrl.dispose();
    _serviceAreasCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_baseUser == null) return;

    setState(() => _isSaving = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);

      // 1. Update general user data
      final userUpdates = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
      };
      await firestore.updateUser(_baseUser!.uid, userUpdates);

      // 2. Update worker profile if applicable
      if (_baseUser!.role == 'worker') {
        final hourlyRate = double.tryParse(_hourlyRateCtrl.text.trim()) ?? 0.0;

        // Parse comma-separated strings into lists
        final skillsList = _skillsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final serviceAreasList = _serviceAreasCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final workerUpdates = {
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'bio': _bioCtrl.text.trim(),
          'category': _categoryCtrl.text.trim(),
          'hourly_rate': hourlyRate,
          'skills': skillsList,
          'service_areas': serviceAreasList,
          'is_available': _isAvailable,
        };

        await firestore.updateWorkerProfile(_baseUser!.uid, workerUpdates);
      }

      // Refresh auth provider state
      await ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: BrandColors.shadeBlack,
        body: Center(
          child: CircularProgressIndicator(color: BrandColors.primaryGreen),
        ),
      );
    }

    final isWorker = _baseUser?.role == 'worker';

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      appBar: AppBar(
        backgroundColor: BrandColors.shadeBlack,
        title: const Text('Edit Profile'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Info',
                style: AppTextStyles.headingSmall,
              ).animate().fadeIn(),
              const SizedBox(height: 16),

              AppTextField(
                controller: _nameCtrl,
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),

              AppTextField(
                controller: _phoneCtrl,
                hintText: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 16),

              AppTextField(
                controller: _cityCtrl,
                hintText: 'City',
                prefixIcon: Icons.location_city_outlined,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),

              if (isWorker) ...[
                Text(
                  'Worker Details',
                  style: AppTextStyles.headingSmall,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.lightGray,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available for jobs?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Switch(
                        value: _isAvailable,
                        activeColor: BrandColors.primaryGreen,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _categoryCtrl,
                  hintText: 'Category (e.g. plumbing, electrical)',
                  prefixIcon: Icons.category_outlined,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _hourlyRateCtrl,
                  hintText: 'Hourly Rate (₹)',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _bioCtrl,
                  hintText: 'Short Bio',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _skillsCtrl,
                  hintText: 'Skills (comma separated)',
                  prefixIcon: Icons.handyman_outlined,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _serviceAreasCtrl,
                  hintText: 'Service Areas (comma separated)',
                  prefixIcon: Icons.map_outlined,
                ).animate().fadeIn(delay: 550.ms),
                const SizedBox(height: 32),
              ],

              AppButton(
                onTap: _saveProfile,
                isLoading: _isSaving,
                width: double.infinity,
                height: 56,
                child: const Text(
                  'Save Profile',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
