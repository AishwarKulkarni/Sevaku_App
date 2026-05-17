import 'package:flutter/material.dart';
import 'package:workzy/core/theme/brand_colors.dart';
import 'package:workzy/core/theme/text_styles.dart';
import 'package:workzy/models/worker_model.dart';
import 'package:workzy/core/constants/app_constants.dart';
import 'package:workzy/core/utils/image_helper.dart';

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;
  final bool isCompact;

  const WorkerCard({
    super.key,
    required this.worker,
    this.onTap,
    this.onBookTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) return _buildCompactCard();
    return _buildFullCard();
  }

  Widget _buildFullCard() {
    final imageProvider = resolveImageProvider(worker.photoUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        height: 160,
        decoration: BoxDecoration(
          color: BrandColors.lightGray,
          borderRadius: BorderRadius.circular(18),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
          boxShadow: [
            BoxShadow(
              color: BrandColors.shadeBlack.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    BrandColors.shadeBlack.withValues(alpha: 0.9),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            // Empty State Icon (if no image)
            if (imageProvider == null)
              Center(
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: BrandColors.textMuted.withValues(alpha: 0.3),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    worker.name,
                                    style: AppTextStyles.headingSmall.copyWith(
                                      color: BrandColors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildCategoryBadge(),
                                const SizedBox(width: 8),
                                if (worker.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BrandColors.success.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Available',
                                      style: AppTextStyles.caption.copyWith(
                                        color: BrandColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
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
                                  style: AppTextStyles.rating.copyWith(
                                    fontSize: 13,
                                    color: BrandColors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${worker.reviewCount})',
                                  style: AppTextStyles.caption.copyWith(
                                    color: BrandColors.textHint,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: BrandColors.textHint,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  worker.city,
                                  style: AppTextStyles.caption.copyWith(
                                    color: BrandColors.textHint,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '₹${worker.hourlyRate.toInt()}/hr',
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 16,
                                    color: BrandColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard() {
    final imageProvider = resolveImageProvider(worker.photoUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: BrandColors.lightGray,
          borderRadius: BorderRadius.circular(18),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
          boxShadow: [
            BoxShadow(
              color: BrandColors.shadeBlack.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    BrandColors.shadeBlack.withValues(alpha: 0.9),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Empty State Icon
            if (imageProvider == null)
              Center(
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: BrandColors.textMuted.withValues(alpha: 0.3),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: BrandColors.starYellow,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        worker.rating.toStringAsFixed(1),
                        style: AppTextStyles.rating.copyWith(
                          fontSize: 11,
                          color: BrandColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    worker.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 13,
                      color: BrandColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getCategoryLabel(),
                    style: AppTextStyles.caption.copyWith(
                      color: BrandColors.primaryGreen,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${worker.hourlyRate.toInt()}/hr',
                    style: AppTextStyles.price.copyWith(
                      fontSize: 13,
                      color: BrandColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final catLabel = _getCategoryLabel();
    final catColor = _getCategoryColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        catLabel,
        style: AppTextStyles.caption.copyWith(
          color: catColor,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }

  String _getCategoryLabel() {
    try {
      return AppConstants.categories
          .firstWhere((c) => c.id == worker.category)
          .label;
    } catch (_) {
      return worker.category;
    }
  }

  Color _getCategoryColor() {
    try {
      return AppConstants.categories
          .firstWhere((c) => c.id == worker.category)
          .color;
    } catch (_) {
      return BrandColors.primaryGreen;
    }
  }
}
