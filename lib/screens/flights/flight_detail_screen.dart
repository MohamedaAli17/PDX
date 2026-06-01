/// ============================================================
/// FILE: flight_detail_screen.dart
/// PURPOSE: Full detail view for a single flight — route, gate info,
///          journey progress, and save/actions. Receives [flight] via
///          go_router extra or fetches by [ident] from FlightAware.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdx_airport/models/flight.dart';
import 'package:pdx_airport/services/flightaware_service.dart';
import 'package:pdx_airport/services/saved_flights_state.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

/// Shows full details for one flight passed via router [extra] or [ident].
class FlightDetailScreen extends StatefulWidget {
  const FlightDetailScreen({
    super.key,
    required this.ident,
    this.flight,
  });

  final String ident;
  final Flight? flight;

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen>
    with SingleTickerProviderStateMixin {
  Flight? _flight;
  bool _isLoading = false;
  String? _errorMessage;

  static final DateFormat _timeFormat = DateFormat('HH:mm');

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    if (widget.flight != null) {
      _flight = widget.flight;
      _refreshDetails(silent: true);
    } else {
      _loadDetails();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final flight =
          await FlightAwareService.instance.getFlightDetails(widget.ident);
      if (!mounted) return;
      setState(() {
        _flight = flight;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDetails({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    try {
      final flight =
          await FlightAwareService.instance.getFlightDetails(widget.ident);
      if (!mounted) return;
      setState(() {
        _flight = flight;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || silent) return;
      setState(() => _isLoading = false);
    }
  }

  void _saveFlight() {
    final flight = _flight;
    if (flight == null) return;

    SavedFlightsState.instance.saveFlight(flight);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${flight.formattedIdent} saved'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _isLoading && _flight == null
          ? _buildLoading()
          : _errorMessage != null && _flight == null
              ? _buildError()
              : _buildContent(_flight!),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.background,
      child: Column(
        children: [
          Container(height: 180, color: AppColors.primaryGreen),
          Expanded(child: Container(color: AppColors.surface)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _loadDetails, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildContent(Flight flight) {
    return Column(
      children: [
        _buildHeader(flight),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRouteCard(flight),
                const SizedBox(height: 16),
                _buildInfoGrid(flight),
                const SizedBox(height: 24),
                _buildJourneyProgress(flight),
                const SizedBox(height: 24),
                _buildActionButtons(flight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Flight flight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 24,
        left: 8,
        right: 8,
      ),
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.background),
                onPressed: () => context.go('/flights'),
              ),
            ],
          ),
          Text(
            flight.formattedIdent,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            flight.airline,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 12),
          _HeaderStatusBadge(status: flight.status),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Flight flight) {
    final arrivalTime = flight.scheduledArrival ?? flight.scheduledTime;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.originCode,
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      flight.originCity,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.textSecondary,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        child: CustomPaint(
                          painter: _DashedLinePainter(),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.flight,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                    Expanded(
                      child: CustomPaint(
                        painter: _DashedLinePainter(),
                        child: const SizedBox(height: 1),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.destinationCode,
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      flight.destinationCity,
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeFormat.format(flight.scheduledTime),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                flight.durationLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _timeFormat.format(arrivalTime),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Flight flight) {
    return Padding(
      padding: AppSpacing.screenHorizontal,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: [
          _InfoTile(
            icon: Icons.door_sliding_outlined,
            title: 'Gate ${flight.gate ?? 'TBD'}',
            subtitle: flight.concourseLabel,
          ),
          _InfoTile(
            icon: Icons.apartment_outlined,
            title: 'Terminal ${flight.terminal ?? 'D'}',
            subtitle: 'Main Terminal',
          ),
          flight.isDeparture
              ? _InfoTile(
                  icon: Icons.fact_check_outlined,
                  title: 'Check-in open',
                  subtitle: 'Online & kiosk',
                )
              : _InfoTile(
                  icon: Icons.luggage_outlined,
                  title: 'Belt ${flight.baggageClaim ?? 'TBD'}',
                  subtitle: 'Baggage Claim',
                ),
          _InfoTile(
            icon: Icons.schedule,
            title: 'Boards ${_timeFormat.format(flight.boardingTime)}',
            subtitle: '30 min before',
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyProgress(Flight flight) {
    const steps = ['Check-in', 'Security', 'Boarding', 'Departed'];
    final currentIndex = flight.journeyStepIndex;

    return Padding(
      padding: AppSpacing.screenHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Journey Status',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var stepIndex = 0; stepIndex < steps.length; stepIndex++) ...[
                if (stepIndex > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: stepIndex <= currentIndex
                          ? AppColors.primaryGreen
                          : AppColors.divider,
                    ),
                  ),
                _JourneyStepDot(
                  isCompleted: stepIndex < currentIndex,
                  isActive: stepIndex == currentIndex,
                  pulseAnimation: _pulseController,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final step in steps)
                Expanded(
                  child: Text(
                    step,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: step == steps[currentIndex]
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: step == steps[currentIndex]
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Flight flight) {
    final isSaved = SavedFlightsState.instance.isSaved(flight.ident);

    return Padding(
      padding: AppSpacing.screenHorizontal,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSaved ? null : _saveFlight,
              child: Text(isSaved ? 'Flight Saved' : 'Save Flight'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Flight alerts coming soon')),
                );
              },
              child: const Text('Set Flight Alerts'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStatusBadge extends StatelessWidget {
  const _HeaderStatusBadge({required this.status});

  final FlightStatus status;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.background, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.background,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStepDot extends StatelessWidget {
  const _JourneyStepDot({
    required this.isCompleted,
    required this.isActive,
    required this.pulseAnimation,
  });

  final bool isCompleted;
  final bool isActive;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: AppColors.background, size: 14),
      );
    }

    if (isActive) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen
                      .withValues(alpha: 0.3 + pulseAnimation.value * 0.3),
                  blurRadius: 6 + pulseAnimation.value * 4,
                  spreadRadius: pulseAnimation.value * 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider, width: 2),
        color: AppColors.background,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
