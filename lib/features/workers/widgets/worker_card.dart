import 'package:flutter/material.dart';
import 'package:sevaku/core/theme/app_colors.dart';
import 'package:sevaku/core/theme/text_styles.dart';
import 'package:sevaku/models/worker_model.dart';
import 'package:sevaku/core/constants/app_constants.dart';
import 'package:sevaku/core/utils/image_helper.dart';

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
    if (isCompact) return _buildCompactCard(context);
    return _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    final imageProvider = resolveImageProvider(worker.photoUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        height: 160,
        decoration: BoxDecoration(
          color: context.colors.lightGray,
          borderRadius: BorderRadius.circular(18),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
          boxShadow: [
            BoxShadow(
              color: context.colors.shadeBlack.withValues(alpha: 0.2),
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
                  colors: [Colors.transparent, context.colors.shadeBlack],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(12.0),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: context.colors.starYellow,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    worker.rating.toStringAsFixed(1),
                    style: context.typography.rating.copyWith(
                      fontSize: 10,
                      color: context.colors.shadeBlack,
                    ),
                  ),
                ],
              ),
            ),

            // Empty State Icon (if no image)
            if (imageProvider == null)
              Center(
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: context.colors.textMuted.withValues(alpha: 0.3),
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
                                    style: context.typography.headingSmall
                                        .copyWith(color: context.colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildCategoryBadge(context),
                                const SizedBox(width: 8),
                                if (worker.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.colors.success.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Available',
                                      style: context.typography.caption
                                          .copyWith(
                                            color: context.colors.white,
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
                                Text(
                                  '(${worker.reviewCount})',
                                  style: context.typography.caption.copyWith(
                                    color: context.colors.textHint,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: context.colors.textHint,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  worker.city,
                                  style: context.typography.caption.copyWith(
                                    color: context.colors.textHint,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '₹${worker.hourlyRate.toInt()}hr',
                                  style: context.typography.price.copyWith(
                                    fontSize: 14,
                                    color: context.colors.white,
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

  Widget _buildCompactCard(BuildContext context) {
    final imageProvider = resolveImageProvider(worker.photoUrl);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: context.colors.lightGray,
          borderRadius: BorderRadius.circular(18),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
          boxShadow: [
            BoxShadow(
              color: context.colors.shadeBlack.withValues(alpha: 0.1),
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
                  colors: [Colors.transparent, context.colors.shadeBlack],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(12.0),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: context.colors.starYellow,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    worker.rating.toStringAsFixed(1),
                    style: context.typography.rating.copyWith(
                      fontSize: 10,
                      color: context.colors.shadeBlack,
                    ),
                  ),
                ],
              ),
            ),

            // Empty State Icon
            if (imageProvider == null)
              Center(
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: context.colors.textMuted.withValues(alpha: 0.3),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    worker.name,
                    style: context.typography.labelLarge.copyWith(
                      fontSize: 13,
                      color: context.colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getCategoryLabel(),
                    style: context.typography.caption.copyWith(
                      color: context.colors.primaryGreen,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${worker.hourlyRate.toInt()}/hr',
                    style: context.typography.price.copyWith(
                      fontSize: 13,
                      color: context.colors.white,
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

  Widget _buildCategoryBadge(BuildContext context) {
    final catLabel = _getCategoryLabel();
    final catColor = _getCategoryColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        catLabel,
        style: context.typography.caption.copyWith(
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

  Color _getCategoryColor(BuildContext context) {
    try {
      return AppConstants.categories
          .firstWhere((c) => c.id == worker.category)
          .color;
    } catch (_) {
      return context.colors.white;
    }
  }
}
