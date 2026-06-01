/// ============================================================
/// FILE: flight.dart
/// PURPOSE: Data model representing a single flight.
///          Maps directly from FlightAware AeroAPI v4 JSON response.
///          Used across flights screen, detail screen, and home screen.
/// TODO: No changes needed when backend is added — this model
///       stays as-is since it maps from the API.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

/// Represents the derived status of a flight for UI display.
enum FlightStatus {
  onTime,
  delayed,
  cancelled,
  landed,
  enRoute,
}

/// A single flight record parsed from FlightAware AeroAPI v4.
/// Immutable value object used across flights list, detail, and home.
class Flight {
  const Flight({
    required this.ident,
    required this.airline,
    required this.originCode,
    required this.originCity,
    required this.destinationCode,
    required this.destinationCity,
    required this.scheduledTime,
    this.scheduledArrival,
    this.estimatedTime,
    this.actualTime,
    this.gate,
    this.terminal,
    this.baggageClaim,
    required this.status,
  });

  // Flight identifier e.g. "AS487"
  final String ident;

  // Operating airline name e.g. "Alaska Airlines"
  final String airline;

  // IATA origin airport code e.g. "PDX"
  final String originCode;

  // Origin city name — used when searching arrivals
  final String originCity;

  // IATA destination airport code e.g. "JFK"
  final String destinationCode;

  // Destination city name e.g. "New York"
  final String destinationCity;

  // Scheduled departure time from scheduled_out
  final DateTime scheduledTime;

  // Scheduled arrival time from scheduled_in — nullable
  final DateTime? scheduledArrival;

  // Estimated departure from estimated_out — null if not provided
  final DateTime? estimatedTime;

  // Actual time from actual_out — null if not yet departed/arrived
  final DateTime? actualTime;

  // Departure gate from gate_origin — null if unassigned
  final String? gate;

  // Terminal from terminal_origin — null if not provided
  final String? terminal;

  // Baggage claim carousel — arrivals only, nullable
  final String? baggageClaim;

  // Derived status for badge display
  final FlightStatus status;

  /// Parses a FlightAware AeroAPI v4 flight JSON object into a [Flight].
  /// [json] is a single flight object from departures/arrivals/detail response.
  /// Returns a fully populated [Flight] with derived [status].
  factory Flight.fromJson(Map<String, dynamic> json) {
    final scheduledTime =
        _parseDateTime(json['scheduled_out']) ?? DateTime.now();
    final scheduledArrival = _parseDateTime(json['scheduled_in']);
    final estimatedTime = _parseDateTime(json['estimated_out']);
    final apiStatus = json['status'] as String? ?? '';

    return Flight(
      ident: json['ident'] as String? ?? '',
      airline: json['operator'] as String? ?? 'Unknown Airline',
      originCode: _readAirportCode(json['origin']),
      originCity: _readAirportCity(json['origin']),
      destinationCode: _readAirportCode(json['destination']),
      destinationCity: _readAirportCity(json['destination']),
      scheduledTime: scheduledTime,
      scheduledArrival: scheduledArrival,
      estimatedTime: estimatedTime,
      actualTime: _parseDateTime(json['actual_out']),
      gate: json['gate_origin'] as String? ?? json['gate_destination'] as String?,
      terminal: json['terminal_origin'] as String? ??
          json['terminal_destination'] as String?,
      baggageClaim: json['baggage_claim'] as String?,
      status: _deriveStatus(
        apiStatus: apiStatus,
        scheduledTime: scheduledTime,
        estimatedTime: estimatedTime,
      ),
    );
  }

  /// Formats ident with a space between airline code and number e.g. "AS 487".
  String get formattedIdent {
    final match = RegExp(r'^([A-Za-z]+)(\d+)$').firstMatch(ident);
    if (match != null) {
      return '${match.group(1)!.toUpperCase()} ${match.group(2)}';
    }
    return ident.toUpperCase();
  }

  /// Returns two-letter airline initials for the logo placeholder circle.
  String get airlineInitials {
    final match = RegExp(r'^([A-Za-z]{1,2})').firstMatch(ident);
    return (match?.group(1) ?? ident.substring(0, ident.length.clamp(0, 2)))
        .toUpperCase();
  }

  /// Returns true when PDX is the origin (departure flight).
  bool get isDeparture => originCode == 'PDX';

  /// Human-readable flight duration e.g. "5h 13m".
  String get durationLabel {
    if (scheduledArrival == null) {
      return '--';
    }
    final duration = scheduledArrival!.difference(scheduledTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Boarding time — 30 minutes before scheduled departure.
  DateTime get boardingTime =>
      scheduledTime.subtract(const Duration(minutes: 30));

  /// Concourse letter derived from gate e.g. "D6" → "Concourse D".
  String get concourseLabel {
    if (gate == null || gate!.isEmpty) {
      return 'Main Terminal';
    }
    final concourseLetter = gate!.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (concourseLetter.isEmpty) {
      return 'Main Terminal';
    }
    return 'Concourse ${concourseLetter.toUpperCase()}';
  }

  /// Zero-based index of the current journey step for the progress indicator.
  int get journeyStepIndex {
    switch (status) {
      case FlightStatus.landed:
      case FlightStatus.enRoute:
        return 3;
      case FlightStatus.onTime:
      case FlightStatus.delayed:
        return 2;
      case FlightStatus.cancelled:
        return 1;
    }
  }

  /// Returns the first word of the airline name for the abbreviated label.
  String get abbreviatedAirline {
    final parts = airline.split(' ');
    return parts.isNotEmpty ? parts.first : airline;
  }

  /// Safely parses an ISO8601 date string; returns null on failure.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value is! String || value.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Reads the IATA code from a nested origin/destination object.
  static String _readAirportCode(dynamic airportJson) {
    if (airportJson is Map<String, dynamic>) {
      return airportJson['code_iata'] as String? ?? '';
    }
    return '';
  }

  /// Reads the city name from a nested origin/destination object.
  static String _readAirportCity(dynamic airportJson) {
    if (airportJson is Map<String, dynamic>) {
      return airportJson['city'] as String? ?? '';
    }
    return '';
  }

  /// Derives [FlightStatus] from API status string and time comparison.
  static FlightStatus _deriveStatus({
    required String apiStatus,
    required DateTime scheduledTime,
    DateTime? estimatedTime,
  }) {
    final normalizedStatus = apiStatus.toLowerCase();

    if (normalizedStatus.contains('cancel')) {
      return FlightStatus.cancelled;
    }
    if (normalizedStatus.contains('landed')) {
      return FlightStatus.landed;
    }
    if (normalizedStatus.contains('en route') ||
        normalizedStatus.contains('enroute')) {
      return FlightStatus.enRoute;
    }
    if (estimatedTime != null &&
        estimatedTime.difference(scheduledTime).inMinutes > 15) {
      return FlightStatus.delayed;
    }
    return FlightStatus.onTime;
  }
}
