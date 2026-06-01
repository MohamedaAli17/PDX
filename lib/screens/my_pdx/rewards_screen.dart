/// ============================================================
/// FILE: rewards_screen.dart
/// PURPOSE: PDX Rewards detail screen — points summary, earn/redeem
///          sections, and transaction history.
/// AUTHOR:
/// LAST UPDATED:
/// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdx_airport/services/auth_state.dart';
import 'package:pdx_airport/theme/app_theme.dart';

/// Full PDX Rewards screen with points, earn methods, and history.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  static const List<(String, String)> _earnMethods = [
    ('Shop at PDX stores', '+1 pt per \$1 spent'),
    ('Dine at restaurants', '+2 pts per \$1 spent'),
    ('Book airport parking', '+50 pts per booking'),
    ('Refer a friend', '+500 pts per referral'),
  ];

  static const List<(String, int)> _vouchers = [
    ('\$5 PDX Voucher', 500),
    ('\$10 PDX Voucher', 1000),
    ('Free Coffee', 250),
    ('Parking Discount', 750),
  ];

  static const List<(String, String, String)> _transactions = [
    ('+50 pts', 'Stumptown Coffee', 'May 28'),
    ('+120 pts', "Powell's Books", 'May 25'),
    ('+50 pts', 'Made in Oregon', 'May 20'),
    ('-500 pts', 'Redeemed \$5 voucher', 'May 15'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = AuthState.instance;
    final progress = auth.pointsBalance / auth.pointsToNextTier;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PointsSummaryCard(
                    points: auth.pointsBalance,
                    nextTierPoints: auth.pointsToNextTier,
                    progress: progress.clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How to earn',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final method in _earnMethods)
                    _EarnRow(title: method.$1, subtitle: method.$2),
                  const SizedBox(height: 24),
                  Text(
                    'Redeem',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final voucher in _vouchers)
                    _VoucherCard(
                      title: voucher.$1,
                      pointsCost: voucher.$2,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Transaction History',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final tx in _transactions)
                    _TransactionRow(
                      amount: tx.$1,
                      description: tx.$2,
                      date: tx.$3,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 8,
        right: 8,
      ),
      color: AppColors.primaryGreen,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.background),
            onPressed: () => context.go('/mypdx'),
          ),
          Text(
            'PDX Rewards',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsSummaryCard extends StatelessWidget {
  const _PointsSummaryCard({
    required this.points,
    required this.nextTierPoints,
    required this.progress,
  });

  final int points;
  final int nextTierPoints;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$points',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          Text(
            'PDX Rewards Points',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$points / $nextTierPoints pts to Gold',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnRow extends StatelessWidget {
  const _EarnRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
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
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({required this.title, required this.pointsCost});

  final String title;
  final int pointsCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: AppDecorations.cardDecoration(color: AppColors.background),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$pointsCost pts',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.amount,
    required this.description,
    required this.date,
  });

  final String amount;
  final String description;
  final String date;

  @override
  Widget build(BuildContext context) {
    final isCredit = amount.startsWith('+');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCredit
                  ? AppColors.statusOnTime
                  : AppColors.statusCancelled,
            ),
          ),
        ],
      ),
    );
  }
}
