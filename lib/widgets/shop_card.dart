/// ============================================================
/// FILE: shop_card.dart
/// PURPOSE: Compact shop/restaurant card for horizontal carousels
///          on the Home screen and future dining lists.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:pdx_airport/theme/app_theme.dart';

/// A small 140×160 shop preview card with image, name, category, and concourse badge.
/// Stateless — all content is passed via constructor parameters.
class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.name,
    required this.category,
    required this.concourse,
    this.width = 140,
    this.height = 160,
  });

  // Shop or restaurant display name
  final String name;

  // Category label shown in grey below the name (e.g. "Coffee")
  final String category;

  // Concourse location shown in the green pill (e.g. "Concourse D")
  final String concourse;

  // Card width — defaults to 140px per Home screen spec
  final double width;

  // Card height — defaults to 160px per Home screen spec
  final double height;

  /// Builds the shop card with grey image placeholder and text footer.
  /// Returns a fixed-size [Container] with shadow and rounded corners.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grey image placeholder — top portion of the card
          Container(
            height: 80,
            width: double.infinity,
            color: AppColors.divider,
            child: Icon(
              Icons.storefront_outlined,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 32,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(AppColors.textPrimary).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(AppColors.textSecondary)
                        .copyWith(fontSize: 11),
                  ),
                  const Spacer(),
                  _ConcourseBadge(label: concourse),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small green pill showing which concourse the shop is located in.
class _ConcourseBadge extends StatelessWidget {
  const _ConcourseBadge({required this.label});

  // Concourse text (e.g. "Concourse B")
  final String label;

  /// Builds the concourse pill with green background and white text.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTypography.caption(AppColors.background).copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
