/// ============================================================
/// FILE: flightaware_service.dart
/// PURPOSE: Handles ALL communication with FlightAware AeroAPI v4.
///          No screen or widget should ever call the API directly.
///          All screens must use the methods in this service.
///          Includes in-memory caching to avoid excessive API calls.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pdx_airport/models/flight.dart';

/// Singleton service for FlightAware AeroAPI v4 requests and caching.
/// Manages departure/arrival caches with a 60-second TTL.
class FlightAwareService {
  FlightAwareService._internal();

  // Shared singleton instance used across the app
  static final FlightAwareService instance = FlightAwareService._internal();

  // Base URL for all FlightAware API calls
  static const String _baseUrl = 'https://aeroapi.flightaware.com/aeroapi';

  // PDX airport ICAO code used in endpoint paths
  static const String _airportCode = 'KPDX';

  // Cached departure list — null when not yet fetched
  List<Flight>? _cachedDepartures;

  // Timestamp of last successful departures fetch
  DateTime? _departuresCachedAt;

  // Cached arrival list — null when not yet fetched
  List<Flight>? _cachedArrivals;

  // Timestamp of last successful arrivals fetch
  DateTime? _arrivalsCachedAt;

  // Minimum interval before re-fetching the same list from the API
  static const _cacheDuration = Duration(seconds: 60);

  /// Returns the required headers for every FlightAware API request.
  /// Loads the API key from the .env file via flutter_dotenv.
  Map<String, String> _getHeaders() {
    return {
      'x-apikey': dotenv.env['FLIGHTAWARE_API_KEY'] ?? '',
      'Content-Type': 'application/json',
    };
  }

  /// Returns true if the cache is still fresh (under 60 seconds old).
  /// [cachedAt] is the timestamp of the last successful cache write.
  /// Returns false if cache is null or expired.
  bool _isCacheValid(DateTime? cachedAt) {
    if (cachedAt == null) {
      return false;
    }
    return DateTime.now().difference(cachedAt) < _cacheDuration;
  }

  /// Fetches upcoming departures from PDX (KPDX).
  /// Returns cached data if cache is under 60 seconds old.
  /// Endpoint: GET /airports/KPDX/flights/departures
  /// Returns a [List] of [Flight] parsed from the API response.
  /// Throws an [Exception] with a user-friendly message on failure.
  Future<List<Flight>> getDepartures() async {
    if (_isCacheValid(_departuresCachedAt) && _cachedDepartures != null) {
      return _cachedDepartures!;
    }

    final uri = Uri.parse('$_baseUrl/airports/$_airportCode/flights/departures')
        .replace(queryParameters: {
      'type': 'Airline',
      'max_pages': '1',
    });

    try {
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Could not load departures. Please check your connection.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = body['departures'] as List<dynamic>? ?? [];

      _cachedDepartures = rawList
          .map((item) => Flight.fromJson(item as Map<String, dynamic>))
          .toList();
      _departuresCachedAt = DateTime.now();

      return _cachedDepartures!;
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Could not load departures. Please check your connection.');
    }
  }

  /// Fetches upcoming arrivals into PDX (KPDX).
  /// Returns cached data if cache is under 60 seconds old.
  /// Endpoint: GET /airports/KPDX/flights/arrivals
  /// Returns a [List] of [Flight] parsed from the API response.
  /// Throws an [Exception] with a user-friendly message on failure.
  Future<List<Flight>> getArrivals() async {
    if (_isCacheValid(_arrivalsCachedAt) && _cachedArrivals != null) {
      return _cachedArrivals!;
    }

    final uri = Uri.parse('$_baseUrl/airports/$_airportCode/flights/arrivals')
        .replace(queryParameters: {
      'type': 'Airline',
      'max_pages': '1',
    });

    try {
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Could not load arrivals. Please check your connection.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = body['arrivals'] as List<dynamic>? ?? [];

      _cachedArrivals = rawList
          .map((item) => Flight.fromJson(item as Map<String, dynamic>))
          .toList();
      _arrivalsCachedAt = DateTime.now();

      return _cachedArrivals!;
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Could not load arrivals. Please check your connection.');
    }
  }

  /// Fetches full details for a single flight by its ident.
  /// [ident] is the flight identifier e.g. "AS487".
  /// Endpoint: GET /flights/{ident}
  /// Returns a [Flight] with complete detail data — always fetched fresh.
  /// Throws an [Exception] with a user-friendly message on failure.
  Future<Flight> getFlightDetails(String ident) async {
    final uri = Uri.parse('$_baseUrl/flights/$ident');

    try {
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Could not load flight details. Please try again.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final flights = body['flights'] as List<dynamic>? ?? [];

      if (flights.isEmpty) {
        throw Exception('Flight not found.');
      }

      return Flight.fromJson(flights.first as Map<String, dynamic>);
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Could not load flight details. Please try again.');
    }
  }

  /// Searches the cached flight list locally by flight number, airline, or city.
  /// [query] is the user's search string (case-insensitive).
  /// [isDepartures] determines which cached list to search.
  /// Fetches from API first if cache is empty or expired.
  /// Returns a filtered [List] of [Flight] matching the query.
  Future<List<Flight>> searchFlights(String query, bool isDepartures) async {
    final flights =
        isDepartures ? await getDepartures() : await getArrivals();

    if (query.trim().isEmpty) {
      return flights;
    }

    final normalizedQuery = query.toLowerCase().trim();

    return flights.where((flight) {
      return flight.ident.toLowerCase().contains(normalizedQuery) ||
          flight.airline.toLowerCase().contains(normalizedQuery) ||
          flight.destinationCity.toLowerCase().contains(normalizedQuery) ||
          flight.originCity.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}
