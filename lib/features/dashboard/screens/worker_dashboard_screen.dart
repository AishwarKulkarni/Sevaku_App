import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/core/utils/image_helper.dart';
import 'package:sevaku/providers/data_providers.dart';
import 'package:sevaku/core/widgets/app_error_state.dart';
import 'package:sevaku/core/widgets/app_empty_state.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';
import 'package:sevaku/models/booking_model.dart';
import 'package:sevaku/core/widgets/section_header.dart';

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
        final upcomingEst = bookings
            .where((b) => b.status == 'accepted' || b.status == 'pending')
            .fold<double>(0, (sum, b) => sum + b.totalAmount);

        final now = DateTime.now();
        final thisMonthEarnings = completedBookings
            .where(
              (b) =>
                  b.scheduledDate.toLocal().year == now.year &&
                  b.scheduledDate.toLocal().month == now.month,
            )
            .fold<double>(0, (sum, b) => sum + b.totalAmount);

        final rating =
            workerAsync.valueOrNull?.rating.toStringAsFixed(1) ?? '0.0';

        // Calculate earnings for the current month broken down into 4 weeks
        final barItems = <_BarItem>[];
        final weeklyEarnings = List.filled(4, 0.0);
        double maxWeekly = 0;

        for (final b in completedBookings) {
          final localDate = b.scheduledDate.toLocal();
          if (localDate.year == now.year && localDate.month == now.month) {
            int weekIndex = (localDate.day - 1) ~/ 7;
            if (weekIndex > 3) weekIndex = 3; // Days 22-31 go into the 4th week
            weeklyEarnings[weekIndex] += b.totalAmount;
          }
        }

        for (double earned in weeklyEarnings) {
          if (earned > maxWeekly) maxWeekly = earned;
        }

        final weekNames = ['W1', 'W2', 'W3', 'W4'];
        for (int i = 0; i < 4; i++) {
          final heightRatio = maxWeekly > 0
              ? weeklyEarnings[i] / maxWeekly
              : 0.05;
          barItems.add(
            _BarItem(weekNames[i], heightRatio == 0 ? 0.05 : heightRatio),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.shadeBlack,
          body: SafeArea(
            child: RefreshIndicator(
              color: context.colors.primaryGreen,
              backgroundColor: context.colors.lightGray,
              onRefresh: () async {
                ref.invalidate(workerBookingsProvider);
                if (user != null) {
                  ref.invalidate(workerProfileProvider(user.uid));
                }

                await Future.wait([
                  ref.read(workerBookingsProvider.future),
                  if (user != null)
                    ref.read(workerProfileProvider(user.uid).future),
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
                                      style: context.typography.headingLarge,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Welcome back, ${user?.name}. Here's your overview for today.",
                                      style: context.typography.bodySmall
                                          .copyWith(
                                            color: context.colors.textMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: context.colors.lightGray,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: context.colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.lightGray,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available for jobs?',
                              style: context.typography.bodyMedium,
                            ),
                            Switch(
                              value:
                                  workerAsync.valueOrNull?.isAvailable ?? false,
                              activeColor: context.colors.primaryGreen,
                              onChanged: user == null
                                  ? null
                                  : (val) async {
                                      try {
                                        await ref
                                            .read(firestoreServiceProvider)
                                            .updateWorkerProfile(user.uid, {
                                              'is_available': val,
                                            });
                                        ref.invalidate(
                                          workerProfileProvider(user.uid),
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update availability: $e',
                                              ),
                                              backgroundColor:
                                                  context.colors.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    ),
                  ),

                  // Earnings Chart Placeholder
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.colors.lightGray,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Earnings Overview',
                              titleStyle: context.typography.headingSmall,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'This Month',
                                  style: context.typography.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _StatCard(
                              value: '₹${thisMonthEarnings.toInt()}',
                              headingSmallSize: 20,
                              captionSize: 12,
                            ),

                            const SizedBox(height: 20),
                            // Mini bar chart
                            SizedBox(
                              height: 120,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: barItems,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Divider(),

                            const SizedBox(height: 16),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Column(
                                spacing: 20,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _StatCard(
                                        value: 'Jobs Completed',
                                        headingSmallSize: 12,
                                        label: totalJobs.toString(),
                                        captionSize: 15,
                                      ),

                                      _StatCard(
                                        value: 'Overall Rating',
                                        headingSmallSize: 12,
                                        label: '$rating',
                                        captionSize: 15,
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _StatCard(
                                        value: 'Active Jobs',
                                        headingSmallSize: 12,
                                        label: activeBookings.length.toString(),
                                        captionSize: 15,
                                      ),

                                      _StatCard(
                                        value: 'Upcoming Est.',
                                        headingSmallSize: 12,
                                        label: '₹${upcomingEst.toInt()}',
                                        captionSize: 15,
                                      ),
                                    ],
                                  ),
                                ],
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
                      child: SectionHeader(
                        title: 'New Requests',
                        titleStyle: context.typography.headingSmall,
                        trailing: pendingBookings.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.colors.warning.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${pendingBookings.length}',
                                  style: context.typography.caption.copyWith(
                                    color: context.colors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
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
                      child: SectionHeader(
                        title: 'Ongoing Jobs',
                        titleStyle: context.typography.headingSmall,
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
                          subtitle:
                              'You do not have any active jobs right now.',
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
      loading: () => Scaffold(
        backgroundColor: context.colors.shadeBlack,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primaryGreen),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: context.colors.shadeBlack,
        body: AppErrorState(
          message: 'Error loading dashboard data',
          onRetry: () => ref.invalidate(workerBookingsProvider),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double captionSize;
  final double headingSmallSize;
  final String value;
  final String? label;

  const _StatCard({
    required this.captionSize,
    required this.headingSmallSize,
    required this.value,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: context.typography.headingSmall.copyWith(
            fontSize: headingSmallSize,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Text(
            label!,
            style: context.typography.caption.copyWith(fontSize: captionSize),
          ),
        ],
      ],
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
            color: context.colors.primaryGreen.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                context.colors.primaryGreen,
                context.colors.primaryGreen.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: context.typography.caption.copyWith(fontSize: 9)),
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
      await ref
          .read(firestoreServiceProvider)
          .updateBookingStatus(widget.booking.id, status);

      // Invalidate the dashboard bookings list so it refreshes immediately
      ref.invalidate(workerBookingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking status: $e'),
            backgroundColor: context.colors.error,
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
        color: context.colors.lightGray,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.2),
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
                backgroundColor: context.colors.surfaceLight,
                backgroundImage: resolveImageProvider(
                  widget.booking.customerPhoto,
                ),
                child:
                    resolveImageProvider(widget.booking.customerPhoto) == null
                    ? Icon(
                        Icons.person,
                        size: 20,
                        color: context.colors.textMuted,
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
                      style: context.typography.labelLarge,
                    ),
                    Text(
                      '${widget.booking.scheduledDate.day}/${widget.booking.scheduledDate.month} at ${widget.booking.scheduledDate.hour}:${widget.booking.scheduledDate.minute.toString().padLeft(2, '0')}',
                      style: context.typography.caption,
                    ),
                  ],
                ),
              ),
              Text(
                '₹${widget.booking.totalAmount.toInt()}',
                style: context.typography.price.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.booking.description,
            style: context.typography.bodySmall.copyWith(
              color: context.colors.textSecondary,
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
                    foregroundColor: context.colors.white,
                    side: BorderSide(color: context.colors.divider),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isStartingChat
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primaryGreen,
                          ),
                        )
                      : const Icon(Icons.chat_bubble_outline, size: 18),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => _updateStatus('cancelled'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.error,
                    side: BorderSide(color: context.colors.error, width: 1),
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
                  onPressed: _isUpdatingStatus
                      ? null
                      : () => _updateStatus('accepted'),
                  child: _isUpdatingStatus
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.shadeBlack,
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
        ? context.colors.primaryGreen
        : context.colors.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: context.colors.surfaceLight,
            backgroundImage: resolveImageProvider(customerPhoto),
            child: resolveImageProvider(customerPhoto) == null
                ? Icon(Icons.person, size: 22, color: context.colors.textMuted)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: context.typography.labelLarge.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: context.typography.bodySmall.copyWith(fontSize: 11),
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
                  style: context.typography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${amount.toInt()}',
                style: context.typography.price.copyWith(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
