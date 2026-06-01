/// ============================================================
/// FILE: main.dart
/// PURPOSE: App entry point — configures theme, routing, and the
///          persistent bottom navigation shell for all 5 tabs.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pdx_airport/models/flight.dart';
import 'package:pdx_airport/screens/flights/flight_detail_screen.dart';
import 'package:pdx_airport/screens/flights/flights_screen.dart';
import 'package:pdx_airport/screens/home/home_screen.dart';
import 'package:pdx_airport/screens/map/map_screen.dart';
import 'package:pdx_airport/screens/my_pdx/my_pdx_screen.dart';
import 'package:pdx_airport/screens/my_pdx/rewards_screen.dart';
import 'package:pdx_airport/screens/offers/offers_screen.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:pdx_airport/widgets/bottom_nav.dart';
import 'package:pdx_airport/widgets/mobile_preview_frame.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

/// Bootstraps the Flutter app — loads .env then mounts [PdxAirportApp].
/// On web, wraps the app in a phone-sized preview frame for mobile layout.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }

  await dotenv.load(fileName: '.env');

  runApp(
    const MobilePreviewFrame(
      child: PdxAirportApp(),
    ),
  );
}

/// Root widget for the PDX airport app.
/// Manages no local state — delegates navigation to [_router] and
/// applies the global [AppTheme.light] theme.
class PdxAirportApp extends StatelessWidget {
  const PdxAirportApp({super.key});

  /// Builds the [MaterialApp.router] with PDX branding and go_router config.
  /// Returns the fully themed app widget tree.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PDX Portland International Airport',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

/// Global router instance shared across the app.
/// Uses [StatefulShellRoute.indexedStack] so each tab keeps its own
/// navigation stack while the bottom bar stays visible.
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PdxBottomNavShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1 — Flights (with nested detail route)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/flights',
              builder: (context, state) => const FlightsScreen(),
              routes: [
                GoRoute(
                  path: ':ident',
                  builder: (context, state) {
                    final ident = state.pathParameters['ident']!;
                    final flight = state.extra as Flight?;
                    return FlightDetailScreen(
                      ident: ident,
                      flight: flight,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2 — Map
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        // Tab 3 — Offers
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/offers',
              builder: (context, state) => const OffersScreen(),
            ),
          ],
        ),
        // Tab 4 — My PDX (profile / rewards)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mypdx',
              builder: (context, state) => const MyPdxScreen(),
              routes: [
                GoRoute(
                  path: 'rewards',
                  builder: (context, state) => const RewardsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
