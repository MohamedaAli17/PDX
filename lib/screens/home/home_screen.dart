/// ============================================================
/// FILE: home_screen.dart
/// PURPOSE: Home tab screen — landing page with PDX header, flight
///          search, saved flight card, quick actions, shops, and offers.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdx_airport/models/flight.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:pdx_airport/widgets/offer_card.dart';
import 'package:pdx_airport/widgets/shop_card.dart';
import 'package:pdx_airport/widgets/status_badge.dart';

/// The Home tab — first screen users see when opening the app.
/// Layout mirrors the Heathrow app home screen with PDX green branding.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fixed height of the green PDX header bar in logical pixels
  static const double _headerHeight = 120;

  // How far the search bar overlaps upward into the header
  static const double _searchBarOverlap = 20;

  // Mock shop data for the horizontal Shops & Dining carousel
  static const List<Map<String, String>> _mockShops = [
    {
      'name': 'Stumptown Coffee',
      'category': 'Coffee',
      'concourse': 'Concourse B',
    },
    {
      'name': "Powell's Books",
      'category': 'Books & Gifts',
      'concourse': 'Concourse C',
    },
    {
      'name': "Kenny & Zuke's",
      'category': 'Deli',
      'concourse': 'Concourse D',
    },
    {
      'name': 'Elephant Bar',
      'category': 'Bar & Grill',
      'concourse': 'Concourse E',
    },
    {
      'name': 'Made in Oregon',
      'category': 'Gifts',
      'concourse': 'Concourse B',
    },
    {
      'name': 'Voodoo Doughnut',
      'category': 'Bakery',
      'concourse': 'Concourse C',
    },
    {
      'name': 'RingSide Steakhouse',
      'category': 'Steakhouse',
      'concourse': 'Concourse D',
    },
    {
      'name': 'Casa del Matador',
      'category': 'Mexican',
      'concourse': 'Concourse E',
    },
    {
      'name': 'Washington Local',
      'category': 'Pub & Grill',
      'concourse': 'Concourse B',
    },
    {
      'name': 'Nike Factory Store',
      'category': 'Apparel',
      'concourse': 'Concourse C',
    },
    {
      'name': 'Hudson News',
      'category': 'News & Snacks',
      'concourse': 'Concourse D',
    },
    {
      'name': 'Burgerville',
      'category': 'Fast Food',
      'concourse': 'Concourse E',
    },
  ];

  // Mock offer previews shown in the Exclusive Offers section
  static const List<Map<String, String>> _mockOffers = [
    {
      'title': 'Stumptown Coffee — 15% Off',
      'description':
          'Show your boarding pass at any Stumptown location in Concourse B.',
      'savings': 'Save 15%',
    },
    {
      'title': 'PDX Parking — First Hour Free',
      'description':
          'Valid for short-term parking when you book through the PDX app.',
      'savings': 'Save 15%',
    },
  ];

  /// Builds the full scrollable home screen matching the Heathrow-style layout.
  /// Returns a [Scaffold] with green header, floating search, and content sections.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderWithSearch(context),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: AppSpacing.screenHorizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMyFlightSection(),
                  const SizedBox(height: AppSpacing.base),
                  _buildQuickActionsRow(context),
                  const SizedBox(height: 24),
                  const _ShopsDiningSection(),
                  const SizedBox(height: 24),
                  _buildOffersSection(context),
                  const SizedBox(height: AppSpacing.base),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the green header and overlapping white search bar.
  /// [context] is used for navigation to My PDX via the avatar tap.
  /// Returns a [Column] with a [Stack] for the overlap and trailing spacer.
  Widget _buildHeaderWithSearch(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Green PDX header — 120px tall with logo and avatar
            Container(
              height: _headerHeight,
              color: AppColors.primaryGreen,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildHeaderTitles()),
                      _buildProfileAvatar(context),
                    ],
                  ),
                ),
              ),
            ),
            // Search bar floats 20px over the bottom edge of the header
            Positioned(
              left: AppSpacing.base,
              right: AppSpacing.base,
              top: _headerHeight - _searchBarOverlap,
              child: _buildSearchBar(),
            ),
          ],
        ),
        // Clears the portion of the search bar that extends below the header
        const SizedBox(height: 36),
      ],
    );
  }

  /// Builds the "PDX" logo text and airport subtitle in white.
  /// Returns a left-aligned [Column] of title texts.
  Widget _buildHeaderTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'PDX',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.background,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Portland International Airport',
          style: AppTypography.body(AppColors.background),
        ),
      ],
    );
  }

  /// Builds the circular white avatar button that opens My PDX.
  /// [context] is used to navigate to `/mypdx` on tap.
  /// Returns a tappable circular icon container.
  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/mypdx'),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_outline,
          color: AppColors.primaryGreen,
          size: 22,
        ),
      ),
    );
  }

  /// Builds the floating white search bar with magnifying glass icon.
  /// Returns a [Container] styled as a card with shadow and rounded corners.
  Widget _buildSearchBar() {
    return Container(
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Search flights, shops, gates...',
          hintStyle: AppTypography.body(AppColors.textSecondary),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// Builds the "My Flight" section with saved flight card and progress bar.
  /// Returns a [Column] with section title and flight card.
  Widget _buildMyFlightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Flight',
          style: AppTypography.headingMedium(AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _MyFlightCard(),
      ],
    );
  }

  /// Builds the horizontally scrollable quick action chips row.
  /// [context] is used to navigate to Flights or Map tabs on chip tap.
  /// Returns a [SizedBox] with a horizontal [ListView] of action chips.
  Widget _buildQuickActionsRow(BuildContext context) {
    // Quick action definitions — label, icon, and target route
    final quickActions = [
      _QuickAction(
        label: 'Arrivals',
        icon: Icons.flight_land,
        route: '/flights',
      ),
      _QuickAction(
        label: 'Departures',
        icon: Icons.flight_takeoff,
        route: '/flights',
      ),
      _QuickAction(
        label: 'Map',
        icon: Icons.map_outlined,
        route: '/map',
      ),
      _QuickAction(
        label: 'Parking',
        icon: Icons.local_parking_outlined,
        route: null,
      ),
      _QuickAction(
        label: 'Lounges',
        icon: Icons.weekend_outlined,
        route: null,
      ),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, actionIndex) {
          final action = quickActions[actionIndex];
          return _QuickActionChip(
            label: action.label,
            icon: action.icon,
            onTap: action.route != null
                ? () => context.go(action.route!)
                : null,
          );
        },
      ),
    );
  }

  /// Builds the Exclusive Offers section with two stacked preview cards.
  /// [context] is used to navigate to `/offers` when "See all" is tapped.
  /// Returns a [Column] with section header and offer cards.
  Widget _buildOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Exclusive Offers',
          onSeeAll: () => context.go('/offers'),
        ),
        const SizedBox(height: 12),
        for (var offerIndex = 0; offerIndex < _mockOffers.length; offerIndex++) ...[
          OfferCard(
            title: _mockOffers[offerIndex]['title']!,
            description: _mockOffers[offerIndex]['description']!,
            savingsLabel: _mockOffers[offerIndex]['savings']!,
          ),
          if (offerIndex < _mockOffers.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Expandable Shops & Dining section — carousel when collapsed, grid when expanded.
class _ShopsDiningSection extends StatefulWidget {
  const _ShopsDiningSection();

  @override
  State<_ShopsDiningSection> createState() => _ShopsDiningSectionState();
}

/// State for [_ShopsDiningSection] — toggles between preview carousel and full grid.
class _ShopsDiningSectionState extends State<_ShopsDiningSection> {
  // When true, shows all shops in a 2-column grid; when false, horizontal carousel
  bool _isExpanded = false;

  // Number of shops shown in the collapsed horizontal preview
  static const int _previewCount = 5;

  /// Toggles between expanded grid and collapsed carousel.
  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final shops = HomeScreen._mockShops;
    final previewShops = shops.take(_previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Shops & Dining',
          seeAllLabel: _isExpanded ? 'Show less' : 'See all',
          onSeeAll: _toggleExpanded,
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          firstChild: _buildCollapsedCarousel(previewShops),
          secondChild: _buildExpandedGrid(shops),
        ),
      ],
    );
  }

  /// Builds the horizontal shop card carousel shown before "See all" is tapped.
  /// [previewShops] is the subset of shops displayed in the carousel.
  Widget _buildCollapsedCarousel(List<Map<String, String>> previewShops) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: previewShops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, shopIndex) {
          final shop = previewShops[shopIndex];
          return ShopCard(
            name: shop['name']!,
            category: shop['category']!,
            concourse: shop['concourse']!,
          );
        },
      ),
    );
  }

  /// Builds a 2-column grid of all shops when the section is expanded.
  /// [allShops] is the full list of mock shop data.
  Widget _buildExpandedGrid(List<Map<String, String>> allShops) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 140 / 160,
      ),
      itemCount: allShops.length,
      itemBuilder: (context, shopIndex) {
        final shop = allShops[shopIndex];
        return ShopCard(
          name: shop['name']!,
          category: shop['category']!,
          concourse: shop['concourse']!,
        );
      },
    );
  }
}

/// Data class describing a single quick-action chip on the Home screen.
class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String? route;
}

/// Section header row with a bold title and optional green "See all" link.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    this.seeAllLabel = 'See all',
  });

  // Section title shown on the left (e.g. "Shops & Dining")
  final String title;

  // Label for the right-side action — "See all" or "Show less"
  final String seeAllLabel;

  // Callback fired when the user taps the right-side link
  final VoidCallback onSeeAll;

  /// Builds a row with the section title and right-aligned "See all" link.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.headingMedium(AppColors.textPrimary),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            seeAllLabel,
            style: AppTypography.body(AppColors.primaryGreen).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Large card showing the user's saved mock flight with status and progress.
class _MyFlightCard extends StatelessWidget {
  /// Builds the flight summary card with route, gate info, and journey progress.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AS 487',
                      style: AppTypography.flightNumber(AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alaska Airlines',
                      style: AppTypography.caption(AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const StatusBadge(status: FlightStatus.onTime),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'PDX → JFK',
            style: AppTypography.headingMedium(AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FlightDetailItem(label: 'Departure', value: '14:35'),
              const SizedBox(width: 20),
              _FlightDetailItem(label: 'Gate', value: 'D6'),
              const SizedBox(width: 20),
              _FlightDetailItem(label: 'Terminal', value: 'D'),
            ],
          ),
          const SizedBox(height: 16),
          const _FlightProgressBar(currentStageIndex: 2),
        ],
      ),
    );
  }
}

/// Single label/value pair inside the My Flight card (e.g. Gate: D6).
class _FlightDetailItem extends StatelessWidget {
  const _FlightDetailItem({
    required this.label,
    required this.value,
  });

  // Small grey label above the value (e.g. "Gate")
  final String label;

  // Bold value text (e.g. "D6")
  final String value;

  /// Builds a vertical label + value column.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption(AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body(AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Four-stage journey progress bar: Check-in → Security → Boarding → Departed.
class _FlightProgressBar extends StatelessWidget {
  const _FlightProgressBar({required this.currentStageIndex});

  // Zero-based index of the active stage — 2 = Boarding (stage 3)
  final int currentStageIndex;

  // Labels for each journey stage shown below the progress dots
  static const List<String> _stageLabels = [
    'Check-in',
    'Security',
    'Boarding',
    'Departed',
  ];

  /// Builds the horizontal stage indicator with connecting lines.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var stageIndex = 0;
                stageIndex < _stageLabels.length;
                stageIndex++) ...[
              if (stageIndex > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: stageIndex <= currentStageIndex
                        ? AppColors.primaryGreen
                        : AppColors.divider,
                  ),
                ),
              _StageDot(
                isCompleted: stageIndex < currentStageIndex,
                isActive: stageIndex == currentStageIndex,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final stageLabel in _stageLabels)
              Expanded(
                child: Text(
                  stageLabel,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(
                    stageLabel == _stageLabels[currentStageIndex]
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                  ).copyWith(
                    fontWeight:
                        stageLabel == _stageLabels[currentStageIndex]
                            ? FontWeight.w600
                            : FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Circular dot representing one stage in the flight progress bar.
class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.isCompleted,
    required this.isActive,
  });

  // True when this stage has already been passed
  final bool isCompleted;

  // True when this is the current active stage (Boarding)
  final bool isActive;

  /// Builds a filled or outlined circle for the stage indicator.
  @override
  Widget build(BuildContext context) {
    // Active stage gets a larger green ring; completed stages are solid green
    final dotSize = isActive ? 14.0 : 10.0;

    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isActive
            ? AppColors.primaryGreen
            : AppColors.background,
        border: Border.all(
          color: isCompleted || isActive
              ? AppColors.primaryGreen
              : AppColors.divider,
          width: isActive ? 2.5 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.35),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

/// A single 70×80 quick-action chip with icon and label.
class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  // Display label below the icon (e.g. "Departures")
  final String label;

  // Material icon shown centered above the label
  final IconData icon;

  // Navigation callback — null means the chip is not tappable yet
  final VoidCallback? onTap;

  /// Builds the white card chip with centered icon and caption label.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 80,
        decoration: AppDecorations.cardDecoration(color: AppColors.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.primaryGreen),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.caption(AppColors.textPrimary).copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
