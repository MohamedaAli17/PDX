/// ============================================================
/// FILE: flights_screen.dart
/// PURPOSE: Main flights screen showing live arrivals and
///          departures for PDX fetched from FlightAware AeroAPI.
///          Users can toggle between arrivals/departures,
///          filter by date, and search by flight/airline/city.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdx_airport/models/flight.dart';
import 'package:pdx_airport/services/flightaware_service.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:pdx_airport/widgets/flight_card.dart';
import 'package:shimmer/shimmer.dart';

/// The Flights tab — live PDX arrivals and departures from FlightAware.
/// Manages tab selection, search, date pills, loading/error states.
class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

/// State for [FlightsScreen] — holds flight list, filters, and UI flags.
class _FlightsScreenState extends State<FlightsScreen> {
  // 0 = Departures, 1 = Arrivals
  int _selectedTab = 0;

  // Full flight list returned from the API
  List<Flight> _flights = [];

  // True while an API call is in progress
  bool _isLoading = true;

  // User-facing error message — null when no error
  String? _errorMessage;

  // Selected date pill index — 1 = today (default)
  int _selectedDateIndex = 1;

  // Current search query in lowercase for filtering
  String _searchQuery = '';

  // Controller for the search TextField
  final TextEditingController _searchController = TextEditingController();

  // Date label formatter for pills e.g. "Sat 30"
  static final DateFormat _datePillFormat = DateFormat('E d');

  /// Loads flights on first mount.
  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  /// Disposes the search controller.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Calls FlightAwareService to fetch departures or arrivals
  /// depending on [_selectedTab]. Updates [_flights], [_isLoading],
  /// and [_errorMessage] state accordingly.
  Future<void> _loadFlights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = _selectedTab == 0
          ? await FlightAwareService.instance.getDepartures()
          : await FlightAwareService.instance.getArrivals();

      if (!mounted) return;

      setState(() {
        _flights = result;
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

  /// Called when the user types in the search box.
  /// [query] is the raw search string from the TextField.
  /// Updates [_searchQuery] and triggers a rebuild for local filtering.
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  /// Returns the list of flights after applying the search filter.
  List<Flight> get _displayedFlights {
    if (_searchQuery.isEmpty) {
      return _flights;
    }

    return _flights.where((flight) {
      return flight.ident.toLowerCase().contains(_searchQuery) ||
          flight.airline.toLowerCase().contains(_searchQuery) ||
          flight.destinationCity.toLowerCase().contains(_searchQuery) ||
          flight.originCity.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  /// Generates 7 date pills starting from yesterday.
  /// Index 0 = yesterday, index 1 = today, indices 2–6 = next 5 days.
  List<DateTime> get _datePills {
    final today = DateTime.now();
    return List.generate(7, (index) {
      return today.add(Duration(days: index - 1));
    });
  }

  /// Opens a placeholder filter bottom sheet.
  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return const SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'Filters coming soon',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the full flights screen layout.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(),
            _buildTabToggle(),
            _buildSearchRow(),
            _buildDateSelector(),
            Expanded(child: _buildFlightList()),
          ],
        ),
      ),
    );
  }

  /// Builds the white top bar with title and airport subtitle.
  Widget _buildTopBar() {
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
            'Flights',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Portland International Airport',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Departures / Arrivals segmented toggle.
  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabButton(label: 'Departures', tabIndex: 0),
          _buildTabButton(label: 'Arrivals', tabIndex: 1),
        ],
      ),
    );
  }

  /// Builds one half of the departures/arrivals toggle.
  /// [label] is the tab text; [tabIndex] is 0 for departures, 1 for arrivals.
  Widget _buildTabButton({
    required String label,
    required int tabIndex,
  }) {
    final isSelected = _selectedTab == tabIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != tabIndex) {
            setState(() => _selectedTab = tabIndex);
            _loadFlights();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.background : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the search field and filter button row.
  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        12,
        AppSpacing.base,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by flight, airline, city...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the horizontal scrollable date pill selector.
  Widget _buildDateSelector() {
    final dates = _datePills;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 8,
        ),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, dateIndex) {
          final date = dates[dateIndex];
          final isSelected = _selectedDateIndex == dateIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDateIndex = dateIndex);
              // TODO: Pass selected date to AeroAPI query params in backend phase.
              _loadFlights();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _datePillFormat.format(date),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the flight list — shimmer, error, empty, or card list.
  Widget _buildFlightList() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final displayed = _displayedFlights;

    if (displayed.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: AppSpacing.base),
      itemCount: displayed.length,
      itemBuilder: (context, flightIndex) {
        return FlightCard(flight: displayed[flightIndex]);
      },
    );
  }

  /// Builds 6 shimmer skeleton cards while loading.
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: 6,
      itemBuilder: (context, _) {
        return Shimmer.fromColors(
          baseColor: AppColors.divider,
          highlightColor: AppColors.surface,
          child: const FlightCardShimmer(),
        );
      },
    );
  }

  /// Builds the centered error state with retry button.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenHorizontal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 64,
              color: AppColors.divider,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load flights',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _loadFlights,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the centered empty state when no flights match filters.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flight_takeoff,
            size: 64,
            color: AppColors.divider,
          ),
          const SizedBox(height: 16),
          Text(
            'No flights found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or date',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
