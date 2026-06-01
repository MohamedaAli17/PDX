/// ============================================================
/// FILE: flight_card.dart
/// PURPOSE: Single flight row card for the arrivals/departures list.
///          Shows airline placeholder, route, time, gate, and status.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdx_airport/models/flight.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:pdx_airport/widgets/status_badge.dart';

/// Displays one flight in the departures/arrivals list.
/// Tapping navigates to [FlightDetailScreen] via go_router.
class FlightCard extends StatelessWidget {
  const FlightCard({
    super.key,
    required this.flight,
  });

  // Flight data to render in the card
  final Flight flight;

  // Time formatter — 24-hour HH:mm
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// Builds the tappable flight card with three-column layout.
  /// Returns a [GestureDetector] wrapping the card [Container].
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/flights/${flight.ident}', extra: flight),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: AppDecorations.cardDecoration(color: AppColors.background),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAirlineSection(),
            Expanded(child: _buildFlightDetails()),
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  /// Builds the left column — airline logo placeholder and abbreviated name.
  Widget _buildAirlineSection() {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              flight.airlineInitials,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            flight.abbreviatedAirline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the center column — flight number, route, time, and gate.
  Widget _buildFlightDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flight.formattedIdent,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${flight.originCode} → ${flight.destinationCode}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _timeFormat.format(flight.scheduledTime),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (flight.status == FlightStatus.delayed &&
              flight.estimatedTime != null) ...[
            const SizedBox(height: 2),
            Text(
              'Est. ${_timeFormat.format(flight.estimatedTime!)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.statusDelayed,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Gate ${flight.gate ?? 'TBD'}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the right column — status badge and optional estimated time.
  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        StatusBadge(status: flight.status),
        if (flight.status == FlightStatus.delayed &&
            flight.estimatedTime != null) ...[
          const SizedBox(height: 6),
          Text(
            _timeFormat.format(flight.estimatedTime!),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.statusDelayed,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shimmer placeholder matching [FlightCard] dimensions during loading.
class FlightCardShimmer extends StatelessWidget {
  const FlightCardShimmer({super.key});

  /// Builds a grey skeleton card the same size as a real flight card.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.divider,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 80,
                  color: AppColors.divider,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  color: AppColors.divider,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 22,
                  width: 60,
                  color: AppColors.divider,
                ),
              ],
            ),
          ),
          Container(
            height: 24,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
