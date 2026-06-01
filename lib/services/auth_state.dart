/// ============================================================
/// FILE: auth_state.dart
/// PURPOSE: Simple in-memory auth state for My PDX logged-in
///          vs logged-out UI. Replaced by Supabase in a later phase.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/foundation.dart';

/// Manages mock login state for the My PDX tab.
/// Singleton [instance] notifies listeners on sign-in/sign-out.
class AuthState extends ChangeNotifier {
  AuthState._internal();

  static final AuthState instance = AuthState._internal();

  // Whether the user is currently signed in
  bool _isLoggedIn = false;

  // Mock user display name shown in the profile header
  String userName = 'Jane Doe';

  // Mock member-since label
  String memberSince = 'Member since Jan 2024';

  // Mock rewards tier label
  String rewardsTier = 'Silver Member';

  // Mock PDX Rewards points balance
  int pointsBalance = 2450;

  // Points required to reach the next tier
  int pointsToNextTier = 5000;

  /// Returns true when the user is signed in.
  bool get isLoggedIn => _isLoggedIn;

  /// Simulates a successful sign-in and notifies listeners.
  void signIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Simulates sign-out and notifies listeners.
  void signOut() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
