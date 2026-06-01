/// ============================================================
/// FILE: offer_card.dart
/// PURPOSE: Full-width offer/deal card with green accent border,
///          used on Home previews and the Offers tab.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:pdx_airport/theme/app_theme.dart';

/// A full-width promotional offer card with title, description, and savings badge.
/// Stateless — display content is supplied via constructor parameters.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.title,
    required this.description,
    required this.savingsLabel,
  });

  // Offer headline (e.g. "Stumptown Coffee Deal")
  final String title;

  // Short offer description in grey body text
  final String description;

  // Badge text shown top-right (e.g. "Save 15%")
  final String savingsLabel;

  /// Builds the offer card with 4px green left border and savings badge.
  /// Returns a [Container] styled as a white card with subtle shadow.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background)
          .copyWith(
        border: const Border(
          left: BorderSide(color: AppColors.primaryGreen, width: 4),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            // Right padding so text does not overlap the savings badge
            padding: const EdgeInsets.only(right: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body(AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.caption(AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                savingsLabel,
                style: AppTypography.caption(AppColors.background).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
