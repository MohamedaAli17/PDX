/// ============================================================
/// FILE: offer.dart
/// PURPOSE: Data model for promotional offers shown on the
///          Offers tab and home screen previews.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

/// Category labels used to filter offers on the Offers screen.
enum OfferCategory {
  all,
  foodAndDrink,
  shopping,
  travel,
  services,
}

/// A single promotional offer from a PDX shop or restaurant.
class Offer {
  const Offer({
    required this.shopName,
    required this.title,
    required this.expiryLabel,
    required this.discountBadge,
    required this.category,
  });

  final String shopName;
  final String title;
  final String expiryLabel;
  final String discountBadge;
  final OfferCategory category;

  /// All mock offers for the Offers tab — hardcoded until backend is added.
  static const List<Offer> mockOffers = [
    Offer(
      shopName: 'Stumptown Coffee',
      title: 'Free pastry with any drink',
      expiryLabel: 'Valid until Jun 30',
      discountBadge: 'Free Item',
      category: OfferCategory.foodAndDrink,
    ),
    Offer(
      shopName: "Powell's Books",
      title: '10% off all titles',
      expiryLabel: 'Valid until Jul 15',
      discountBadge: '10% OFF',
      category: OfferCategory.shopping,
    ),
    Offer(
      shopName: 'Made in Oregon',
      title: '15% off \$30+ purchase',
      expiryLabel: 'Valid until Jun 30',
      discountBadge: '15% OFF',
      category: OfferCategory.shopping,
    ),
    Offer(
      shopName: "Kenny & Zuke's",
      title: 'Free side with any sandwich',
      expiryLabel: 'Valid until Jul 1',
      discountBadge: 'Free Side',
      category: OfferCategory.foodAndDrink,
    ),
    Offer(
      shopName: 'Hudson News',
      title: 'Buy 2 get 1 free on magazines',
      expiryLabel: 'Valid until Jun 30',
      discountBadge: 'B2G1',
      category: OfferCategory.shopping,
    ),
  ];
}
