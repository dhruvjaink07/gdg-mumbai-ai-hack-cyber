import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Based on the provided color scheme)
  static const Color primary = Color(0xFF4B2138); // Deep burgundy
  static const Color primaryDark = Color(0xFF1B0C1A); // Very dark burgundy
  static const Color primaryLight = Color(0xFF6D3C52); // Medium burgundy
  
  // Secondary Colors from the palette
  static const Color secondary = Color(0xFF765D67); // Muted purple-brown
  static const Color accent = Color(0xFFFADCD5); // Light peachy pink
  
  // Light Theme Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFAFAFA); // Light white shade
  static const Color onSurfaceLight = Color(0xFF2D222F); // Dark text
  static const Color onSurfaceVariantLight = Color(0xFF765D67); // Muted text
  static const Color surfaceVariantLight = Color(0xFFF5F0F2); // Very light variant
  
  // Dark Theme Colors
  static const Color surfaceDark = Color(0xFF2D222F);
  static const Color backgroundDark = Color(0xFF1B0C1A);
  static const Color onSurfaceDark = Color(0xFFFADCD5);
  static const Color onSurfaceVariantDark = Color(0xFF765D67);
  static const Color surfaceVariantDark = Color(0xFF4B2138);
  
  // Alert Severity Colors (harmonized with the palette)
  static const Color severityLow = Color(0xFF10B981);
  static const Color severityMedium = Color(0xFFF59E0B);
  static const Color severityHigh = Color(0xFF6D3C52); // Using our burgundy
  static const Color severityCritical = Color(0xFF4B2138); // Deep burgundy
  
  // Alert Status Colors
  static const Color statusOpen = Color(0xFFF59E0B);
  static const Color statusInvestigating = Color(0xFF765D67); // Muted purple
  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusEscalated = Color(0xFF4B2138); // Deep burgundy
}           