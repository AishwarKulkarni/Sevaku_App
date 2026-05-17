import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/core/utils/image_helper.dart';
import 'package:workzy/core/widgets/app_button.dart';
import 'package:workzy/core/widgets/app_text_field.dart';
import 'package:workzy/providers/data_providers.dart';
import 'package:workzy/features/auth/providers/auth_provider.dart';
import 'package:workzy/models/booking_model.dart';
import 'package:uuid/uuid.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final String? workerId;

  const BookingFlowScreen({super.key, this.workerId});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  int _estimatedHours = 2;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workerId == null) {
      return const Scaffold(
        backgroundColor: BrandColors.shadeBlack,
        body: Center(child: Text('Invalid worker ID')),
      );
    }

    final workerAsync = ref.watch(workerProfileProvider(widget.workerId!));
    final currentUser = ref.watch(currentUserProvider);

    return workerAsync.when(
      data: (worker) {
        if (worker == null) {
          return const Scaffold(
            backgroundColor: BrandColors.shadeBlack,
            body: Center(
              child: Text(
                'Worker not found',
                style: TextStyle(color: BrandColors.white),
              ),
            ),
          );
        }

        final totalAmount = worker.hourlyRate * _estimatedHours;

        return Scaffold(
          backgroundColor: BrandColors.shadeBlack,
          appBar: AppBar(
            backgroundColor: BrandColors.shadeBlack,
            title: const Text('Book Service'),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BrandColors.lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: BrandColors.surfaceLight,
                        backgroundImage: resolveImageProvider(worker.photoUrl),
                        child: resolveImageProvider(worker.photoUrl) == null
                            ? const Icon(
                                Icons.person,
                                size: 28,
                                color: BrandColors.textMuted,
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker.name, style: AppTextStyles.labelLarge),
                            const SizedBox(height: 2),
                            Text(
                              '₹${worker.hourlyRate.toInt()}/hr',
                              style: AppTextStyles.price.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: BrandColors.starYellow,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            worker.rating.toStringAsFixed(1),
                            style: AppTextStyles.rating.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 28),

                // Date Picker
                Text(
                  'Select Date',
                  style: AppTextStyles.labelLarge,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: BrandColors.primaryGreen,
                              surface: BrandColors.lightGray,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: BrandColors.lightGray,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedDate != null
                            ? BrandColors.primaryGreen.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: _selectedDate != null
                              ? BrandColors.primaryGreen
                              : BrandColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Choose a date',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _selectedDate != null
                                ? BrandColors.white
                                : BrandColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 20),

                // Time Picker
                Text(
                  'Select Time',
                  style: AppTextStyles.labelLarge,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: BrandColors.primaryGreen,
                              surface: BrandColors.lightGray,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) setState(() => _selectedTime = time);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: BrandColors.lightGray,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedTime != null
                            ? BrandColors.primaryGreen.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: _selectedTime != null
                              ? BrandColors.primaryGreen
                              : BrandColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : 'Choose a time',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _selectedTime != null
                                ? BrandColors.white
                                : BrandColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 20),

                // Estimated hours
                Text(
                  'Estimated Duration',
                  style: AppTextStyles.labelLarge,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.lightGray,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_estimatedHours > 1) {
                            setState(() => _estimatedHours--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: BrandColors.textSecondary,
                      ),
                      Text(
                        '$_estimatedHours hours',
                        style: AppTextStyles.headingSmall,
                      ),
                      IconButton(
                        onPressed: () {
                          if (_estimatedHours < 12) {
                            setState(() => _estimatedHours++);
                          }
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: BrandColors.primaryGreen,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 20),

                // Description
                Text(
                  'Job Description',
                  style: AppTextStyles.labelLarge,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descriptionController,
                  hintText: 'Describe the work you need done...',
                  maxLines: 4,
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 20),

                // Address
                Text(
                  'Address',
                  style: AppTextStyles.labelLarge,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _addressController,
                  hintText: 'Enter your address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ).animate().fadeIn(delay: 550.ms),

                const SizedBox(height: 28),

                // Price Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BrandColors.lightGray,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BrandColors.primaryGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _PriceRow('Rate', '₹${worker.hourlyRate.toInt()}/hr'),
                      const SizedBox(height: 8),
                      _PriceRow('Duration', '$_estimatedHours hours'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: BrandColors.divider),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.headingSmall),
                          Text(
                            '₹${totalAmount.toInt()}',
                            style: AppTextStyles.price.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 28),

                // Confirm Button
                AppButton(
                  onTap: () async {
                    if (_selectedDate == null || _selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select date and time'),
                        ),
                      );
                      return;
                    }

                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to book a service'),
                        ),
                      );
                      return;
                    }

                    setState(() => _isSubmitting = true);

                    try {
                      // Create booking DateTime
                      final scheduledDateTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );

                      final booking = BookingModel(
                        id: const Uuid().v4(),
                        customerId: currentUser.uid,
                        customerName: currentUser.name,
                        customerPhoto: currentUser.photoUrl,
                        workerId: worker.uid,
                        workerName: worker.name,
                        workerPhoto: worker.photoUrl,
                        category: worker.category,
                        status: 'pending',
                        paymentStatus: 'pending',
                        scheduledDate: scheduledDateTime,
                        totalAmount: totalAmount,
                        description: _descriptionController.text.trim(),
                        address: _addressController.text.trim(),
                        createdAt: DateTime.now(),
                      );

                      await ref
                          .read(firestoreServiceProvider)
                          .createBooking(booking);

                      if (mounted) {
                        setState(() => _isSubmitting = false);
                        _showSuccessDialog();
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  isLoading: _isSubmitting,
                  width: double.infinity,
                  height: 56,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: BrandColors.shadeBlack,
        body: Center(
          child: CircularProgressIndicator(color: BrandColors.primaryGreen),
        ),
      ),
      error: (err, _) => const Scaffold(
        backgroundColor: BrandColors.shadeBlack,
        body: Center(
          child: Text(
            'Error loading data',
            style: TextStyle(color: BrandColors.error),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: BrandColors.lightGray,
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
                  color: BrandColors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: BrandColors.primaryGreen,
                  size: 40,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text('Booking Confirmed!', style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Text(
                'Your booking has been placed successfully. The worker will confirm shortly.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: BrandColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/customer');
                },
                width: double.infinity,
                height: 48,
                child: const Text(
                  'Back to Home',
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
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: BrandColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
