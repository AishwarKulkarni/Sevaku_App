import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Workzy';
  static const String appTagline = 'Home services, simplified.';

  // Roles
  static const String roleCustomer = 'customer';
  static const String roleWorker = 'worker';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Service Categories
  static const List<ServiceCategory> categories = [
    ServiceCategory('plumber', 'Plumber', Icons.plumbing, Color(0xFF42A5F5)),
    ServiceCategory(
      'carpenter',
      'Carpenter',
      Icons.carpenter,
      Color(0xFFFFA726),
    ),
    ServiceCategory(
      'painter',
      'Painter',
      Icons.format_paint,
      Color(0xFFAB47BC),
    ),
    ServiceCategory(
      'electrician',
      'Electrician',
      Icons.electrical_services,
      Color(0xFFFFEE58),
    ),
    ServiceCategory(
      'maid',
      'Cleaning',
      Icons.cleaning_services,
      Color(0xFF66BB6A),
    ),
    ServiceCategory('ac_repair', 'AC Repair', Icons.ac_unit, Color(0xFF26C6DA)),
    ServiceCategory('mechanic', 'Mechanic', Icons.build, Color(0xFFEF5350)),
    ServiceCategory('gardener', 'Gardening', Icons.grass, Color(0xFF8BC34A)),
    ServiceCategory(
      'pest_control',
      'Pest Control',
      Icons.bug_report,
      Color(0xFFFF7043),
    ),
    ServiceCategory(
      'moving',
      'Moving',
      Icons.local_shipping,
      Color(0xFF78909C),
    ),
  ];

  // Animations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // Border Radius
  static const double radiusSM = 8;
  static const double radiusMD = 14;
  static const double radiusLG = 20;
  static const double radiusXL = 28;
}

class ServiceCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const ServiceCategory(this.id, this.label, this.icon, this.color);
}
