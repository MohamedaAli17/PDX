/// ============================================================
/// FILE: map_screen.dart
/// PURPOSE: Map tab — loads the official PDX airport map in a
///          WebView with floor selector and amenity bottom sheet.
///          On web, skips unsupported WebView APIs (e.g. setJavaScriptMode).
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdx_airport/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Official PDX interactive map URL embedded in the WebView.
const String _pdxMapUrl = 'https://www.flypdx.com/map';

/// The Map tab — embeds https://www.flypdx.com/map in a WebView.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

/// State for [MapScreen] — WebView controller and floor selection.
class _MapScreenState extends State<MapScreen> {
  // Floor/concourse filter labels shown in the horizontal pill row
  static const List<String> _floors = [
    'All',
    'Concourse B',
    'Concourse C',
    'Concourse D',
    'Concourse E',
  ];

  // Index of the currently selected floor pill
  int _selectedFloorIndex = 0;

  // True while the WebView is loading the map page
  bool _isMapLoading = true;

  // WebView controller for the PDX airport map URL
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initMapWebView();
  }

  /// Creates and configures the WebView controller in a platform-safe way.
  /// [setJavaScriptMode] is skipped on web — it throws [UnimplementedError]
  /// on webview_flutter_web. JavaScript is enabled by default in the web iframe.
  Future<void> _initMapWebView() async {
    final controller = WebViewController();

    // Mobile/desktop native WebViews require explicit JS mode; web does not.
    if (!kIsWeb) {
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isMapLoading = false);
            }
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() => _isMapLoading = false);
            }
          },
        ),
      );
    }

    await controller.loadRequest(Uri.parse(_pdxMapUrl));

    if (!mounted) return;

    setState(() {
      _webViewController = controller;
    });

    // Fallback: hide spinner if onPageFinished never fires (some web embeds).
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isMapLoading) {
        setState(() => _isMapLoading = false);
      }
    });
  }

  /// Builds the map screen with header, floor selector, WebView, and sheet.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildFloorSelector(),
            Expanded(child: _buildMapArea()),
            _buildAmenitySheet(),
          ],
        ),
      ),
    );
  }

  /// Builds the map WebView or a loading placeholder until the controller is ready.
  Widget _buildMapArea() {
    final controller = _webViewController;

    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isMapLoading)
          const ColoredBox(
            color: AppColors.surface,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
      ],
    );
  }

  /// Builds the screen title and airport subtitle.
  Widget _buildHeader() {
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
            'Airport Map',
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

  /// Builds the horizontal scrollable floor/concourse pill selector.
  Widget _buildFloorSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: _floors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, floorIndex) {
          final isSelected = _selectedFloorIndex == floorIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedFloorIndex = floorIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _floors[floorIndex],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.background
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the collapsed bottom sheet with nearby amenity chips.
  Widget _buildAmenitySheet() {
    const amenities = [
      (Icons.wc, 'Restrooms'),
      (Icons.atm, 'ATM'),
      (Icons.weekend_outlined, 'Lounge'),
      (Icons.info_outline, 'Gate Info'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final amenity in amenities) ...[
                  _AmenityChip(icon: amenity.$1, label: amenity.$2),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single amenity chip in the map bottom sheet.
class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
