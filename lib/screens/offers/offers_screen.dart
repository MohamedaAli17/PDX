/// ============================================================
/// FILE: offers_screen.dart
/// PURPOSE: Offers tab — exclusive deals, filter chips, featured
///          banner, and a scrollable list of mock offer cards.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdx_airport/models/offer.dart';
import 'package:pdx_airport/theme/app_theme.dart';

/// The Offers tab — displays PDX shop and restaurant promotions.
class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  // Filter chip labels mapped to [OfferCategory]
  static const List<(String, OfferCategory)> _filters = [
    ('All', OfferCategory.all),
    ('Food & Drink', OfferCategory.foodAndDrink),
    ('Shopping', OfferCategory.shopping),
    ('Travel', OfferCategory.travel),
    ('Services', OfferCategory.services),
  ];

  // Currently selected filter category
  OfferCategory _selectedCategory = OfferCategory.all;

  /// Returns offers matching the selected category filter.
  List<Offer> get _filteredOffers {
    if (_selectedCategory == OfferCategory.all) {
      return Offer.mockOffers;
    }
    return Offer.mockOffers
        .where((offer) => offer.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(child: _buildFeaturedBanner()),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.base),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OfferListCard(offer: _filteredOffers[index]),
                    );
                  },
                  childCount: _filteredOffers.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exclusive Offers',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save at PDX shops & restaurants',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedCategory == filter.$2;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = filter.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.divider,
                ),
              ),
              child: Text(
                filter.$1,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      height: 160,
      margin: const EdgeInsets.all(AppSpacing.base),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF004D33), Color(0xFF00704A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '20% off your first order',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pre-order food at any PDX restaurant',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.background,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.background,
                side: const BorderSide(color: AppColors.background),
              ),
              child: const Text('Claim Offer'),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single offer row in the vertical offers list.
class _OfferListCard extends StatelessWidget {
  const _OfferListCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.shopName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.expiryLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Redeem'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                offer.discountBadge,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
