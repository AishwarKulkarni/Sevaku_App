import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sevaku/core/constants/app_constants.dart';
import 'package:sevaku/core/theme/brand_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';

class CategoryGrid extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;

  const CategoryGrid({
    super.key,
    this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          final isSelected = selectedCategory == cat.id;
          return _CategoryItem(
                category: cat,
                isSelected: isSelected,
                onTap: () => onCategoryTap(cat.id),
              )
              .animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn()
              .slideX(begin: 0.2);
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: isSelected ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, color: category.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? category.color : BrandColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
