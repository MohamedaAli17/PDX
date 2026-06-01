/// ============================================================
/// FILE: mobile_preview_frame.dart
/// PURPOSE: Wraps the app in a fixed-size phone frame when running
///          on web or desktop so the UI matches a real mobile device.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in an iPhone-sized frame on web/desktop for mobile preview.
/// On real mobile devices, passes [child] through unchanged.
class MobilePreviewFrame extends StatelessWidget {
  const MobilePreviewFrame({
    super.key,
    required this.child,
  });

  // The app widget tree (typically [PdxAirportApp])
  final Widget child;

  // iPhone 14 logical width in logical pixels
  static const double _phoneWidth = 390;

  // iPhone 14 logical height in logical pixels
  static const double _phoneHeight = 844;

  // Outer bezel corner radius mimicking a modern phone
  static const double _bezelRadius = 44;

  /// Returns true when the app should render inside the phone preview frame.
  /// Enabled on web; on native mobile builds the app runs full-screen.
  static bool get shouldUsePreview => kIsWeb;

  /// Builds either the phone frame (web) or the raw [child] (mobile).
  @override
  Widget build(BuildContext context) {
    if (!shouldUsePreview) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFF1A1A1A),
        child: Center(
          child: _PhoneBezel(child: child),
        ),
      ),
    );
  }
}

/// Visual phone bezel containing the app at fixed mobile dimensions.
class _PhoneBezel extends StatelessWidget {
  const _PhoneBezel({required this.child});

  // App content rendered inside the bezel
  final Widget child;

  /// Builds the rounded phone shell with notch and shadow.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MobilePreviewFrame._phoneWidth + 16,
      height: MobilePreviewFrame._phoneHeight + 16,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(MobilePreviewFrame._bezelRadius + 8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MobilePreviewFrame._bezelRadius),
        child: SizedBox(
          width: MobilePreviewFrame._phoneWidth,
          height: MobilePreviewFrame._phoneHeight,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: [
              child,
              // Dynamic Island / notch overlay at top center
              const Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: _DynamicIsland(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill-shaped notch shown at the top of the phone preview.
class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  /// Builds the centered black pill notch.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
