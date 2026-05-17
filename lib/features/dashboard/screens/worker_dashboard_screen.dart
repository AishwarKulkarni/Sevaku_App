import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/core/utils/image_helper.dart';
import 'package:workzy/providers/data_providers.dart';
import 'package:workzy/core/widgets/app_error_state.dart';
import 'package:workzy/core/widgets/app_empty_state.dart';
import 'package:workzy/features/auth/providers/auth_provider.dart';
import 'package:workzy/models/booking_model.dart';

class WorkerDashboardScreen extends ConsumerWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(workerBookingsProvider);
    final user = ref.watch(currentUserProvider);
    final workerAsync = user != null
        ? ref.watch(workerProfileProvider(user.uid))
        : const AsyncValue.loading();

    return bookingsAsync.when(
      data: (bookings) {
        final pendingBookings = bookings
            .where((b) => b.status == 'pending')
            .toList();
        final activeBookings = bookings
            .where((b) => b.status == 'in_progress' || b.status == 'accepted')
            .toList();
        final completedBookings = bookings
            .where((b) => b.status == 'completed')
            .toList();

        final totalJobs = completedBookings.length;

        final now = DateTime.now();
        final thisMonthEarnings = completedBookings
            .where(
              (b) =>
                  b.scheduledDate.year == now.year &&
                  b.scheduledDate.month == now.month,
            )
            .fold<double>(0, (sum, b) => sum + b.totalAmount);

        final rating =
            workerAsync.valueOrNull?.rating.toStringAsFixed(1) ?? '0.0';

        // Calculate earnings for the last 7 days for the chart
        final barItems = <_BarItem>[];
        double maxDaily = 0;
        final dailyEarnings = List.filled(7, 0.0);

        for (int i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          final dayBookings = completedBookings.where(
            (b) =>
                b.scheduledDate.year == day.year &&
                b.scheduledDate.month == day.month &&
                b.scheduledDate.day == day.day,
          );
          final earned = dayBookings.fold<double>(
            0,
            (sum, b) => sum + b.totalAmount,
          );
          dailyEarnings[6 - i] = earned;
          if (earned > maxDaily) maxDaily = earned;
        }

        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: 6 - i));
          final dayName = dayNames[date.weekday - 1]; // weekday is 1-7
          final heightRatio = maxDaily > 0 ? dailyEarnings[i] / maxDaily : 0.05;
          barItems.add(
            _BarItem(dayName, heightRatio == 0 ? 0.05 : heightRatio),
          );
        }

        return Scaffold(
          backgroundColor: BrandColors.shadeBlack,
          body: SafeArea(
            child: RefreshIndicator(
              color: BrandColors.primaryGreen,
              backgroundColor: BrandColors.lightGray,
              onRefresh: () async {
                ref.invalidate(workerBookingsProvider);
                if (user != null) ref.invalidate(workerProfileProvider(user.uid));
                
                await Future.wait([
                  ref.read(workerBookingsProvider.future),
                  if (user != null) ref.read(workerProfileProvider(user.uid).future),
                ]);
              },
              child: CustomScrollView(
                slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dashboard',
                                    style: AppTextStyles.headingLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Manage your jobs and earnings',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: BrandColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: BrandColors.lightGray,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: BrandColors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                ),

                // Stats Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Row(
                      children: [
                        _StatCard(
                          icon: Icons.currency_rupee,
                          iconColor: BrandColors.primaryGreen,
                          value: '₹${thisMonthEarnings.toInt()}',
                          label: 'This Month',
                          bgColor: BrandColors.primaryGreen.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.work_outline,
                          iconColor: BrandColors.info,
                          value: '$totalJobs',
                          label: 'Total Jobs',
                          bgColor: BrandColors.info.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.star_rounded,
                          iconColor: BrandColors.starYellow,
                          value: rating,
                          label: 'Rating',
                          bgColor: BrandColors.starYellow.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                  ),
                ),

                // Earnings Chart Placeholder
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: BrandColors.lightGray,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Earnings',
                                style: AppTextStyles.headingSmall,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: BrandColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'This Week',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Mini bar chart
                          SizedBox(
                            height: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: barItems,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ),

                // New Job Requests
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Requests', style: AppTextStyles.headingSmall),
                        if (pendingBookings.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: BrandColors.warning.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${pendingBookings.length}',
                              style: AppTextStyles.caption.copyWith(
                                color: BrandColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ),
                if (pendingBookings.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: AppEmptyState(
                        icon: Icons.inbox_outlined,
                        title: 'No New Requests',
                        subtitle: 'You are all caught up for now.',
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final booking = pendingBookings[index];
                      return _JobRequestCard(booking: booking)
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn()
                          .slideY(begin: 0.05);
                    }, childCount: pendingBookings.length),
                  ),

                // Ongoing Jobs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                    child: Text(
                      'Ongoing Jobs',
                      style: AppTextStyles.headingSmall,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ),
                if (activeBookings.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: AppEmptyState(
                        icon: Icons.work_outline,
                        title: 'No Ongoing Jobs',
                        subtitle: 'You do not have any active jobs right now.',
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final booking = activeBookings[index];
                      return _OngoingJobCard(
                            customerName: booking.customerName,
                            customerPhoto: booking.customerPhoto,
                            description: booking.description,
                            status: booking.status,
                            amount: booking.totalAmount,
                          )
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn()
                          .slideY(begin: 0.05);
                    }, childCount: activeBookings.length),
                  ),
              ],
            ),
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
      error: (err, _) => Scaffold(
        backgroundColor: BrandColors.shadeBlack,
        body: AppErrorState(
          message: 'Error loading dashboard data',
          onRetry: () => ref.invalidate(workerBookingsProvider),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BrandColors.lightGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final String day;
  final double height;

  const _BarItem(this.day, this.height);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 24,
          height: 80 * height,
          decoration: BoxDecoration(
            color: BrandColors.primaryGreen.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                BrandColors.primaryGreen,
                BrandColors.primaryGreen.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: AppTextStyles.caption.copyWith(fontSize: 9)),
      ],
    );
  }
}

class _JobRequestCard extends ConsumerStatefulWidget {
  final BookingModel booking;

  const _JobRequestCard({required this.booking});

  @override
  ConsumerState<_JobRequestCard> createState() => _JobRequestCardState();
}

class _JobRequestCardState extends ConsumerState<_JobRequestCard> {
  bool _isStartingChat = false;
  bool _isUpdatingStatus = false;

  Future<void> _updateStatus(String status) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    
    try {
      await ref.read(firestoreServiceProvider).updateBookingStatus(widget.booking.id, status);
      
      // Invalidate the dashboard bookings list so it refreshes immediately
      ref.invalidate(workerBookingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking status: $e'), 
            backgroundColor: BrandColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _openChat() async {
    if (_isStartingChat) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isStartingChat = true);
    try {
      final chatId = await ref
          .read(firestoreServiceProvider)
          .getOrCreateChat(
            currentUser.uid,
            widget.booking.customerId,
            widget.booking.customerName,
            widget.booking.customerPhoto,
            user1Name: currentUser.name,
            user1Photo: currentUser.photoUrl,
          );
      if (mounted) context.push('/chat/$chatId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open chat. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.lightGray,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: BrandColors.warning.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: BrandColors.surfaceLight,
                backgroundImage: resolveImageProvider(
                  widget.booking.customerPhoto,
                ),
                child:
                    resolveImageProvider(widget.booking.customerPhoto) == null
                    ? const Icon(
                        Icons.person,
                        size: 20,
                        color: BrandColors.textMuted,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.customerName,
                      style: AppTextStyles.labelLarge,
                    ),
                    Text(
                      '${widget.booking.scheduledDate.day}/${widget.booking.scheduledDate.month} at ${widget.booking.scheduledDate.hour}:${widget.booking.scheduledDate.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '₹${widget.booking.totalAmount.toInt()}',
                style: AppTextStyles.price.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.booking.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: BrandColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: _isStartingChat ? null : _openChat,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: BrandColors.white,
                    side: const BorderSide(color: BrandColors.divider),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isStartingChat
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: BrandColors.primaryGreen,
                          ),
                        )
                      : const Icon(Icons.chat_bubble_outline, size: 18),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdatingStatus ? null : () => _updateStatus('cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BrandColors.error,
                    side: const BorderSide(color: BrandColors.error, width: 1),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(fontFamily: 'Lexend', fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUpdatingStatus ? null : () => _updateStatus('accepted'),
                  child: _isUpdatingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: BrandColors.shadeBlack,
                          ),
                        )
                      : const Text(
                          'Accept',
                          style: TextStyle(fontFamily: 'Lexend', fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OngoingJobCard extends StatelessWidget {
  final String customerName;
  final String? customerPhoto;
  final String description;
  final String status;
  final double amount;

  const _OngoingJobCard({
    required this.customerName,
    this.customerPhoto,
    required this.description,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = status == 'in_progress' ? 'In Progress' : 'Accepted';
    final statusColor = status == 'in_progress'
        ? BrandColors.primaryGreen
        : BrandColors.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: BrandColors.surfaceLight,
            backgroundImage: resolveImageProvider(customerPhoto),
            child: resolveImageProvider(customerPhoto) == null
                ? const Icon(
                    Icons.person,
                    size: 22,
                    color: BrandColors.textMuted,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${amount.toInt()}',
                style: AppTextStyles.price.copyWith(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
