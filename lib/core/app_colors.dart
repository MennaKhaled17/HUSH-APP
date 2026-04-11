import 'package:flutter/material.dart';

// ── HUSH Design System ── matches the screenshot exactly ──────────────────────
// Two-tone layout: dark hero (#0F1117) + light sheet (#F0F0EE)
// Primary accent: Lime #C8F135
// All "gold" references replaced with lime throughout the app

class AppColors {
  // ── Base / Hero (dark) ────────────────────────────────────────
  static const Color base      = Color(0xFF0F1117);
  static const Color surface   = Color(0xFF161820);  // dark cards
  static const Color surface2  = Color(0xFF1A1D27);
  static const Color border    = Color(0xFF1E2030);
  static const Color border2   = Color(0xFF252838);

  // ── Sheet / Light ─────────────────────────────────────────────
  static const Color sheet     = Color(0xFFF0F0EE);  // light background
  static const Color tileBg    = Color(0xFFFFFFFF);  // white service tiles
  static const Color tileBorder= Color(0xFFE8E8E8);
  static const Color sheetText = Color(0xFF111111);  // dark text on light bg

  // ── Primary Accent: Lime ──────────────────────────────────────
  static const Color lime      = Color(0xFFC8F135);  // was gold
  static const Color limeDim   = Color(0xFF8FAA24);
  static const Color limeBg    = Color(0xFF1E3A0E);  // dark lime tint for pills
  static const Color limeText  = Color(0xFFA8D44A);  // lime text on dark
  static const Color limeBorder= Color(0x40C8F135);

  // Keep "gold" aliases pointing to lime so existing references compile
  static const Color gold      = lime;
  static const Color goldBg    = limeBg;
  static const Color goldBorder= limeBorder;

  // ── Semantic ──────────────────────────────────────────────────
  static const Color green    = Color(0xFF34B775);
  static const Color greenBg  = Color(0xFF0D1F16);
  static const Color blue     = Color(0xFF5282E6);
  static const Color blueBg   = Color(0xFF0D1226);
  static const Color red      = Color(0xFFE05C5C);
  static const Color redBg    = Color(0xFF1F0D0D);
  static const Color purple   = Color(0xFF8B6FD4);
  static const Color purpleBg = Color(0xFF130F1E);
  static const Color orange   = Color(0xFFE8855A);
  static const Color orangeBg = Color(0xFF1F110A);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0EDE6);
  static const Color textSecondary = Color(0xFF888B9A);
  static const Color textMuted     = Color(0xFF3A3D4A);
  static const Color textDanger    = Color(0xFFE05C5C);

  // ── Service icon backgrounds (on light sheet) ─────────────────
  static const Color iconBgGreen  = Color(0xFFE8F8EF);
  static const Color iconBgPurple = Color(0xFFEFEBFA);
  static const Color iconBgOrange = Color(0xFFFFF0E8);
  static const Color iconBgGray   = Color(0xFFF0F0F0);
}