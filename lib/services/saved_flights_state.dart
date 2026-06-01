/// ============================================================
/// FILE: saved_flights_state.dart
/// PURPOSE: In-memory store for flights saved by the user from
///          the detail screen. Mock/API flights only — no fake data.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/foundation.dart';
import 'package:pdx_airport/models/flight.dart';

/// Holds the list of flights the user has saved during the session.
class SavedFlightsState extends ChangeNotifier {
  SavedFlightsState._internal();

  static final SavedFlightsState instance = SavedFlightsState._internal();

  // Flights saved by the user from the detail screen
  final List<Flight> _savedFlights = [];

  /// Returns an unmodifiable view of saved flights.
  List<Flight> get savedFlights => List.unmodifiable(_savedFlights);

  /// Adds [flight] to saved list if not already present.
  void saveFlight(Flight flight) {
    if (_savedFlights.any((saved) => saved.ident == flight.ident)) {
      return;
    }
    _savedFlights.add(flight);
    notifyListeners();
  }

  /// Returns true if [ident] is already saved.
  bool isSaved(String ident) =>
      _savedFlights.any((flight) => flight.ident == ident);
}
