import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/core/constants/app_constants.dart';
import 'package:workzy/features/workers/widgets/worker_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/core/widgets/shimmer_loading.dart';
import 'package:workzy/providers/data_providers.dart';
import 'package:workzy/models/worker_model.dart';
import 'package:workzy/core/widgets/app_empty_state.dart';
import 'package:workzy/core/widgets/app_error_state.dart';

class WorkerListScreen extends ConsumerStatefulWidget {
  final String? category;

  const WorkerListScreen({super.key, this.category});

  @override
  ConsumerState<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends ConsumerState<WorkerListScreen> {
  String? _selectedCategory;
  double _minRating = 0;
  double _maxPrice = 1000;
  String _sortBy = 'rating';
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category == 'all' ? null : widget.category;
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkerModel> _filterAndSortWorkers(List<WorkerModel> sourceWorkers) {
    var workers = List<WorkerModel>.from(sourceWorkers);

    if (_minRating > 0) {
      workers = workers.where((w) => w.rating >= _minRating).toList();
    }

    workers = workers.where((w) => w.hourlyRate <= _maxPrice).toList();

    if (_searchQuery.isNotEmpty) {
      workers = workers.where((w) {
        return w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.skills.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    switch (_sortBy) {
      case 'rating':
        workers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_low':
        workers.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case 'price_high':
        workers.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
        break;
      case 'reviews':
        workers.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return workers;
  }

  String get _categoryTitle {
    if (_selectedCategory == null) return 'All Workers';
    try {
      return AppConstants.categories
          .firstWhere((c) => c.id == _selectedCategory)
          .label;
    } catch (_) {
      return 'Workers';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: BrandColors.shadeBlack,
      appBar: AppBar(
        backgroundColor: BrandColors.shadeBlack,
        title: Text(_categoryTitle),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune_rounded, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                fontFamily: 'Lexend',
                color: BrandColors.white,
                fontSize: 14,
              ),
              cursorColor: BrandColors.primaryGreen,
              decoration: InputDecoration(
                hintText: 'Search workers, skills...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ).animate().fadeIn(),

          // Sort chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _SortChip('Top Rated', 'rating', _sortBy == 'rating',
                    () => setState(() => _sortBy = 'rating')),
                const SizedBox(width: 8),
                _SortChip('Price: Low', 'price_low', _sortBy == 'price_low',
                    () => setState(() => _sortBy = 'price_low')),
                const SizedBox(width: 8),
                _SortChip('Price: High', 'price_high', _sortBy == 'price_high',
                    () => setState(() => _sortBy = 'price_high')),
                const SizedBox(width: 8),
                _SortChip('Most Reviews', 'reviews', _sortBy == 'reviews',
                    () => setState(() => _sortBy = 'reviews')),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          // Worker list & Results count
          Expanded(
            child: ref.watch(workersByCategoryProvider(_selectedCategory)).when(
              data: (streamWorkers) {
                final workers = _filterAndSortWorkers(streamWorkers);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${workers.length} workers found',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const ShimmerList(itemCount: 6)
                          : workers.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  color: BrandColors.primaryGreen,
                                  backgroundColor: BrandColors.lightGray,
                                  onRefresh: () async {
                                    setState(() => _isLoading = true);
                                    _simulateLoading();
                                  },
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 80),
                                    itemCount: workers.length,
                                    itemBuilder: (context, index) {
                                      return WorkerCard(
                                        worker: workers[index],
                                        onTap: () {
                                          context.push(
                                            '/customer/worker/${workers[index].uid}',
                                          );
                                        },
                                      )
                                          .animate(
                                              delay: Duration(
                                                  milliseconds: 80 * index))
                                          .fadeIn()
                                          .slideY(begin: 0.05);
                                    },
                                  ),
                                ),
                    ),
                  ],
                );
              },
              loading: () => const ShimmerList(itemCount: 6),
              error: (err, _) => AppErrorState(
                message: 'Error loading workers',
                onRetry: () {
                  setState(() => _isLoading = true);
                  _simulateLoading();
                  ref.invalidate(workersByCategoryProvider(_selectedCategory));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.search_off_rounded,
      title: 'No workers found',
      subtitle: 'Try adjusting your filters',
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BrandColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: BrandColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Filters', style: AppTextStyles.headingMedium),
                const SizedBox(height: 24),

                // Category
                Text('Category', style: AppTextStyles.labelLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _selectedCategory == null,
                      onTap: () {
                        setModalState(() {});
                        setState(() => _selectedCategory = null);
                      },
                    ),
                    ...AppConstants.categories.map((cat) => _FilterChip(
                          label: cat.label,
                          isSelected: _selectedCategory == cat.id,
                          onTap: () {
                            setModalState(() {});
                            setState(() => _selectedCategory = cat.id);
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 24),

                // Min Rating
                Text(
                  'Min Rating: ${_minRating.toStringAsFixed(1)}',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: BrandColors.primaryGreen,
                  inactiveColor: BrandColors.lightGray,
                  onChanged: (v) {
                    setModalState(() {});
                    setState(() => _minRating = v);
                  },
                ),

                // Max Price
                Text(
                  'Max Price: ₹${_maxPrice.toInt()}/hr',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _maxPrice,
                  min: 100,
                  max: 1000,
                  divisions: 18,
                  activeColor: BrandColors.primaryGreen,
                  inactiveColor: BrandColors.lightGray,
                  onChanged: (v) {
                    setModalState(() {});
                    setState(() => _maxPrice = v);
                  },
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip(this.label, this.value, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? BrandColors.primaryGreen.withValues(alpha: 0.15)
              : BrandColors.lightGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? BrandColors.primaryGreen : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? BrandColors.primaryGreen : BrandColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? BrandColors.primaryGreen.withValues(alpha: 0.15)
              : BrandColors.lightGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? BrandColors.primaryGreen : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? BrandColors.primaryGreen : BrandColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
