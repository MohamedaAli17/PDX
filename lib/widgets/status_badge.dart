/// ============================================================
/// FILE: status_badge.dart
/// PURPOSE: Reusable colored pill badge showing flight status.
///          Used on flight cards and flight detail screen.
///          Pass a FlightStatus enum value to get the right color.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdx_airport/models/flight.dart';

/// Renders a compact status pill with semantic background and text colors.
/// Stateless — display is driven entirely by [status].
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  // Determines pill colors and label text
  final FlightStatus status;

  /// Returns the uppercase label for the current [status].
  String get _label {
    switch (status) {
      case FlightStatus.onTime:
        return 'ON TIME';
      case FlightStatus.delayed:
        return 'DELAYED';
      case FlightStatus.cancelled:
        return 'CANCELLED';
      case FlightStatus.landed:
        return 'LANDED';
      case FlightStatus.enRoute:
        return 'EN ROUTE';
    }
  }

  /// Returns the pill background color for the current [status].
  Color get _backgroundColor {
    switch (status) {
      case FlightStatus.onTime:
        return const Color(0xFFE8F5E9);
      case FlightStatus.delayed:
        return const Color(0xFFFFF3E0);
      case FlightStatus.cancelled:
        return const Color(0xFFFFEBEE);
      case FlightStatus.landed:
        return const Color(0xFFE3F2FD);
      case FlightStatus.enRoute:
        return const Color(0xFFF3E5F5);
    }
  }

  /// Returns the text color for the current [status].
  Color get _textColor {
    switch (status) {
      case FlightStatus.onTime:
        return const Color(0xFF00874A);
      case FlightStatus.delayed:
        return const Color(0xFFE8A020);
      case FlightStatus.cancelled:
        return const Color(0xFFD0021B);
      case FlightStatus.landed:
        return const Color(0xFF1565C0);
      case FlightStatus.enRoute:
        return const Color(0xFF6A1B9A);
    }
  }

  /// Builds the rounded status pill widget.
  /// Returns a [Container] with Inter 11px Bold label text.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
