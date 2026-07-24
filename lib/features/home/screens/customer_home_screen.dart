import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/core/theme/brand_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:sevaku/core/utils/image_helper.dart';
import 'package:sevaku/features/auth/providers/auth_provider.dart';
import 'package:sevaku/features/home/widgets/category_grid.dart';
import 'package:sevaku/features/workers/widgets/worker_card.dart';
import 'package:sevaku/providers/data_providers.dart';
import 'package:sevaku/providers/location_provider.dart';
import 'package:sevaku/core/widgets/app_empty_state.dart';
import 'package:sevaku/core/widgets/app_error_state.dart';
import 'package:sevaku/core/widgets/section_header.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentLocationProvider.notifier).fetchLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting(String? name) {
    final hour = DateTime.now().hour;
    String timeGreeting = 'Hello';
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    return '$timeGreeting, ${name?.split(' ').first ?? 'there'}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final featuredWorkersAsync = ref.watch(featuredWorkersProvider);
    final allWorkersAsync = ref.watch(workersByCategoryProvider(null));

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      body: SafeArea(
        child: RefreshIndicator(
          color: BrandColors.primaryGreen,
          backgroundColor: BrandColors.lightGray,
          onRefresh: () async {
            ref.invalidate(featuredWorkersProvider);
            ref.invalidate(workersByCategoryProvider(null));
            ref.invalidate(customerBookingsProvider);

            await Future.wait([
              ref.read(featuredWorkersProvider.future),
              ref.read(workersByCategoryProvider(null).future),
              ref.read(customerBookingsProvider.future),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(user?.name),
                              style: AppTextStyles.headingMedium,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: BrandColors.textMuted,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final addressAsync = ref.watch(
                                        currentAddressProvider,
                                      );
                                      return Text(
                                        addressAsync.value ??
                                            user?.city ??
                                            'fetching location...',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: BrandColors.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideX(begin: -0.1),

                      // Profile + Notification
                      _IconBtn(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                        badge: 3,
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                  child: GestureDetector(
                    onTap: () => context.push('/customer/search'),
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.lightGray,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BrandColors.divider.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: BrandColors.textMuted,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Search for services...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: BrandColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),

              // Section: Categories
              SliverToBoxAdapter(
                child: CategoryGrid(
                  onCategoryTap: (category) {
                    context.push('/customer/workers/$category');
                  },
                ).animate().fadeIn(delay: 400.ms),
              ),

              // Section: Featured Workers
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Top Rated',
                    actionLabel: 'See All',
                    onActionTap: () => context.push('/customer/workers/all'),
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: featuredWorkersAsync.when(
                    data: (workers) {
                      if (workers.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.person_off_rounded,
                          title: 'No featured workers found',
                        );
                      }
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: workers.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return WorkerCard(
                                worker: workers[index],
                                isCompact: true,
                                onTap: () {
                                  context.push(
                                    '/customer/worker/${workers[index].uid}',
                                  );
                                },
                              )
                              .animate(
                                delay: Duration(milliseconds: 100 * index),
                              )
                              .fadeIn()
                              .slideX(begin: 0.2);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: BrandColors.primaryGreen,
                      ),
                    ),
                    error: (err, _) => AppErrorState(
                      message: 'Error loading workers',
                      onRetry: () => ref.invalidate(featuredWorkersProvider),
                    ),
                  ),
                ),
              ),

              // Section: Near You
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SectionHeader(
                    title: 'Near You',
                    actionLabel: 'See All',
                    onActionTap: () => context.push('/customer/workers/all'),
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ),
              allWorkersAsync.when(
                data: (workers) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final worker = workers[index];
                      return WorkerCard(
                            worker: worker,
                            onTap: () {
                              context.push('/customer/worker/${worker.uid}');
                            },
                          )
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn()
                          .slideY(begin: 0.1);
                    }, childCount: workers.length.clamp(0, 5)),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: BrandColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AppErrorState(
                      message: 'Error loading nearby workers',
                      onRetry: () =>
                          ref.invalidate(workersByCategoryProvider(null)),
                    ),
                  ),
                ),
              ),

              // Section: Active Bookings (Elevated)
              SliverToBoxAdapter(child: _buildActiveBookings()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookings() {
    final activeBookingsAsync = ref.watch(customerBookingsProvider);

    return activeBookingsAsync.when(
      data: (bookings) {
        final activeBookings = bookings
            .where((b) => b.status != 'completed' && b.status != 'cancelled')
            .toList();

        if (activeBookings.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: SectionHeader(title: 'Active Bookings'),
            ),
            SizedBox(
              height: 135,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: activeBookings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final booking = activeBookings[index];
                  return _ActiveBookingCard(booking: booking);
                },
              ),
            ),
          ],
        ).animate().fadeIn(delay: 250.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  const _IconBtn({required this.icon, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BrandColors.lightGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: BrandColors.white, size: 22),
          ),
          if (badge > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: BrandColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: BrandColors.shadeBlack, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveBookingCard extends StatelessWidget {
  final dynamic booking;

  const _ActiveBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    switch (booking.status) {
      case 'pending':
        statusColor = BrandColors.warning;
        statusLabel = 'Pending';
        break;
      case 'accepted':
        statusColor = BrandColors.info;
        statusLabel = 'Accepted';
        break;
      case 'in_progress':
        statusColor = BrandColors.primaryGreen;
        statusLabel = 'In Progress';
        break;
      default:
        statusColor = BrandColors.textMuted;
        statusLabel = booking.status;
    }

    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrandColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: BrandColors.surfaceLight,
                backgroundImage: resolveImageProvider(booking.workerPhoto),
                child: resolveImageProvider(booking.workerPhoto) == null
                    ? const Icon(
                        Icons.person,
                        size: 18,
                        color: BrandColors.textMuted,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.workerName,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      booking.category.toString().toUpperCase(),
                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.white.withValues(alpha: 0.15),
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
            ],
          ),
          const SizedBox(height: 10),
          Text(
            booking.description,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${booking.totalAmount.toInt()}',
                style: AppTextStyles.price.copyWith(fontSize: 13),
              ),
              Text(
                _formatDate(booking.scheduledDate),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    return '${date.day}/${date.month}';
  }
}
