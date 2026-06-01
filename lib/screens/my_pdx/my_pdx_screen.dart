/// ============================================================
/// FILE: my_pdx_screen.dart
/// PURPOSE: My PDX tab — shows logged-out rewards pitch or logged-in
///          profile, points, quick actions, and saved flights.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdx_airport/services/auth_state.dart';
import 'package:pdx_airport/services/saved_flights_state.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:pdx_airport/widgets/flight_card.dart';

/// The My PDX tab — account hub with logged-in and logged-out states.
class MyPdxScreen extends StatefulWidget {
  const MyPdxScreen({super.key});

  @override
  State<MyPdxScreen> createState() => _MyPdxScreenState();
}

class _MyPdxScreenState extends State<MyPdxScreen> {
  @override
  void initState() {
    super.initState();
    AuthState.instance.addListener(_onAuthChanged);
    SavedFlightsState.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthState.instance.removeListener(_onAuthChanged);
    SavedFlightsState.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: AuthState.instance.isLoggedIn
            ? _LoggedInView(onSignOut: () => AuthState.instance.signOut())
            : _LoggedOutView(onJoin: () => AuthState.instance.signIn()),
      ),
    );
  }
}

/// Logged-out My PDX view with rewards hero and benefits list.
class _LoggedOutView extends StatelessWidget {
  const _LoggedOutView({required this.onJoin});

  final VoidCallback onJoin;

  static const List<(String, String)> _benefits = [
    ('Earn points on every purchase', 'Shop, dine, and park at PDX'),
    ('Exclusive member offers', 'Deals only for Rewards members'),
    ('Redeem for vouchers', 'Turn points into PDX vouchers'),
    ('Flight alerts', 'Get notified about gate changes'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My PDX',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildHeroCard(context),
          const SizedBox(height: 24),
          Text(
            'Why join PDX Rewards?',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final benefit in _benefits) _BenefitRow(
            title: benefit.$1,
            subtitle: benefit.$2,
          ),
          const SizedBox(height: 24),
          Text(
            'Saved Flights',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const _EmptySavedFlightsCard(),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: AppColors.primaryGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'PDX Rewards',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Earn points every time you shop or dine at PDX',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Join Now'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onJoin,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.background,
                side: const BorderSide(color: AppColors.background),
              ),
              child: const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logged-in My PDX view with profile, points, and saved flights.
class _LoggedInView extends StatelessWidget {
  const _LoggedInView({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.instance;
    final savedFlights = SavedFlightsState.instance.savedFlights;
    final progress = auth.pointsBalance / auth.pointsToNextTier;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(context, auth),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PointsCard(
                  points: auth.pointsBalance,
                  nextTierPoints: auth.pointsToNextTier,
                  progress: progress.clamp(0.0, 1.0),
                  onRedeem: () => context.go('/mypdx/rewards'),
                ),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Flights',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(onPressed: onSignOut, child: const Text('Sign Out')),
                  ],
                ),
                const SizedBox(height: 8),
                if (savedFlights.isEmpty)
                  const _EmptySavedFlightsCard()
                else
                  ...savedFlights.map(
                    (savedFlight) => FlightCard(flight: savedFlight),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthState auth) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: AppSpacing.base,
        right: AppSpacing.base,
      ),
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.background,
            child: Text(
              'JD',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            auth.userName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
          Text(
            auth.memberSince,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.background),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.background, size: 14),
                const SizedBox(width: 4),
                Text(
                  auth.rewardsTier,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.background,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      (Icons.flight_takeoff, 'My Flights', '/flights'),
      (Icons.book_online_outlined, 'My Bookings', '/offers'),
      (Icons.local_parking_outlined, 'Parking', '/map'),
      (Icons.settings_outlined, 'Settings', '/mypdx'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        for (final action in actions)
          GestureDetector(
            onTap: () => context.go(action.$3),
            child: Container(
              decoration: AppDecorations.cardDecoration(
                color: AppColors.background,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.$1, color: AppColors.primaryGreen),
                  const SizedBox(height: 6),
                  Text(
                    action.$2,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({
    required this.points,
    required this.nextTierPoints,
    required this.progress,
    required this.onRedeem,
  });

  final int points;
  final int nextTierPoints;
  final double progress;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$points',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          Text(
            'PDX Rewards Points',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$points / $nextTierPoints pts to Gold',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRedeem,
              child: const Text('Redeem Points'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.background, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySavedFlightsCard extends StatelessWidget {
  const _EmptySavedFlightsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No saved flights yet',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Sign in to save flights',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
