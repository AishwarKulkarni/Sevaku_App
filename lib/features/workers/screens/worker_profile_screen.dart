import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:workzy/core/utils/image_helper.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/core/widgets/app_button.dart';
import 'package:workzy/providers/data_providers.dart';
import 'package:workzy/features/auth/providers/auth_provider.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  final String workerId;

  const WorkerProfileScreen({super.key, required this.workerId});

  @override
  ConsumerState<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends ConsumerState<WorkerProfileScreen> {
  bool _isStartingChat = false;

  Future<void> _openChat(
    String workerUid,
    String workerName,
    String workerPhoto,
  ) async {
    if (_isStartingChat) return;
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isStartingChat = true);
    try {
      final chatId = await ref
          .read(firestoreServiceProvider)
          .getOrCreateChat(
            currentUser.uid,
            workerUid,
            workerName,
            workerPhoto,
            user1Name: currentUser.name,
            user1Photo: currentUser.photoUrl,
          );
      if (mounted) context.push('/chat/$chatId');
    } catch (e) {
      print('Error opening chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open chat: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerAsync = ref.watch(workerProfileProvider(widget.workerId));
    final reviewsAsync = ref.watch(workerReviewsProvider(widget.workerId));

    return workerAsync.when(
      data: (worker) {
        if (worker == null) {
          return Scaffold(
            backgroundColor: BrandColors.shadeBlack,
            appBar: AppBar(backgroundColor: BrandColors.shadeBlack),
            body: const Center(
              child: Text(
                'Worker not found',
                style: TextStyle(color: BrandColors.white),
              ),
            ),
          );
        }
        final reviewsData = reviewsAsync.value ?? [];
        final reviews = reviewsData;
        final catLabel = _getCategoryLabel(worker.category);
        final catColor = _getCategoryColor(worker.category);

        return Scaffold(
          backgroundColor: BrandColors.shadeBlack,
          body: CustomScrollView(
            slivers: [
              // Hero Image AppBar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: BrandColors.shadeBlack,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: BrandColors.shadeBlack.withValues(
                      alpha: 0.6,
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: BrandColors.white,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: BrandColors.shadeBlack.withValues(
                        alpha: 0.6,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: BrandColors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: CircleAvatar(
                      backgroundColor: BrandColors.shadeBlack.withValues(
                        alpha: 0.6,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                          size: 20,
                          color: BrandColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'worker_${worker.uid}',
                        child: _buildWorkerImage(worker.photoUrl),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              BrandColors.shadeBlack.withValues(alpha: 0.3),
                              BrandColors.shadeBlack,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Name & category at bottom
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    worker.name,
                                    style: AppTextStyles.headingLarge.copyWith(
                                      fontSize: 26,
                                    ),
                                  ),
                                ),
                                if (worker.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BrandColors.success.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: BrandColors.success,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Available',
                                          style: AppTextStyles.caption.copyWith(
                                            color: BrandColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                catLabel,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: catColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _StatTile(
                        icon: Icons.star_rounded,
                        iconColor: BrandColors.starYellow,
                        value: worker.rating.toStringAsFixed(1),
                        label: 'Rating',
                      ),
                      _StatTile(
                        icon: Icons.rate_review_outlined,
                        iconColor: BrandColors.info,
                        value: '${worker.reviewCount}',
                        label: 'Reviews',
                      ),
                      _StatTile(
                        icon: Icons.work_outline,
                        iconColor: BrandColors.primaryGreen,
                        value: '${worker.jobsCompleted}',
                        label: 'Jobs Done',
                      ),
                      _StatTile(
                        icon: Icons.currency_rupee,
                        iconColor: BrandColors.warning,
                        value: '${worker.hourlyRate.toInt()}',
                        label: 'Per Hour',
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                ),
              ),

              // Bio
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 10),
                      Text(
                        worker.bio,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: BrandColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ),
              ),

              // Skills
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Skills', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: worker.skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: BrandColors.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: BrandColors.primaryGreen.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              skill,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: BrandColors.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                ),
              ),

              // Portfolio
              if (worker.portfolioImages.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text('Portfolio', style: AppTextStyles.headingSmall),
                  ).animate().fadeIn(delay: 500.ms),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: worker.portfolioImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _buildPortfolioImage(
                              worker.portfolioImages[index],
                            )
                            .animate(delay: Duration(milliseconds: 100 * index))
                            .fadeIn()
                            .scale(begin: const Offset(0.95, 0.95));
                      },
                    ),
                  ),
                ),
              ],

              // Service Areas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service Areas', style: AppTextStyles.headingSmall),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: worker.serviceAreas.map((area) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: BrandColors.lightGray,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: BrandColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  area,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: BrandColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                ),
              ),

              // Reviews
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews (${reviews.length})',
                        style: AppTextStyles.headingSmall,
                      ),
                      if (reviews.length > 3)
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'See All',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: BrandColors.primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final review = reviews[index];
                  return _ReviewCard(review: review)
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn()
                      .slideY(begin: 0.05);
                }, childCount: reviews.length.clamp(0, 3)),
              ),

              // Bottom spacing for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Bottom action bar
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: BrandColors.shadeBlack,
              border: Border(
                top: BorderSide(color: BrandColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Message button
                Expanded(
                  flex: 1,
                  child: AppButton(
                    onTap: _isStartingChat
                        ? null
                        : () => _openChat(
                            worker.uid,
                            worker.name,
                            worker.photoUrl,
                          ),
                    isOutlined: true,
                    height: 52,
                    icon: _isStartingChat ? null : Icons.chat_bubble_outline,
                    child: _isStartingChat
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: BrandColors.primaryGreen,
                            ),
                          )
                        : const Text(
                            'Chat',
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Book Now button
                Expanded(
                  flex: 2,
                  child: AppButton(
                    onTap: () {
                      context.push(
                        '/customer/booking/new?workerId=${worker.uid}',
                      );
                    },
                    height: 52,
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 1, duration: 400.ms, curve: Curves.easeOut),
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
            'Error loading profile',
            style: TextStyle(color: BrandColors.error),
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(String id) {
    try {
      return AppConstants.categories.firstWhere((c) => c.id == id).label;
    } catch (_) {
      return id;
    }
  }

  Color _getCategoryColor(String id) {
    try {
      return AppConstants.categories.firstWhere((c) => c.id == id).color;
    } catch (_) {
      return BrandColors.primaryGreen;
    }
  }

  /// Builds the hero/banner image widget supporting both local paths and URLs.
  Widget _buildWorkerImage(String pathOrUrl) {
    final provider = resolveImageProvider(pathOrUrl);
    if (provider == null) {
      return Container(
        color: BrandColors.lightGray,
        child: const Center(
          child: Icon(Icons.person, size: 80, color: BrandColors.textMuted),
        ),
      );
    }
    return Image(image: provider, fit: BoxFit.cover);
  }

  /// Builds a portfolio image tile supporting both local paths and URLs.
  Widget _buildPortfolioImage(String pathOrUrl) {
    final provider = resolveImageProvider(pathOrUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 200,
        height: 160,
        child: provider != null
            ? Image(image: provider, fit: BoxFit.cover)
            : Container(
                color: BrandColors.lightGray,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 32,
                    color: BrandColors.textMuted,
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: BrandColors.lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.labelLarge.copyWith(fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.lightGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: BrandColors.surfaceLight,
                backgroundImage: resolveImageProvider(review.reviewerPhoto),
                child: resolveImageProvider(review.reviewerPhoto) == null
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
                      review.reviewerName,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                    ),
                    Text(
                      _timeAgo(review.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: BrandColors.starYellow,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: AppTextStyles.bodySmall.copyWith(
              color: BrandColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'Just now';
  }
}
