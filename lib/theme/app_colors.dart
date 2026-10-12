import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // COLOUR-THEORY FAMILY (UNDERRATED COLOUR PALETTE)
  // ============================================================

  static const hue = Color(0xFF7A3345); // Rosewood
  static const tint = Color(0xFFF4DDE2); // Soft Blush
  static const lightTint = Color(0xFFFAEFF1); // Pale Rose
  static const tone = Color(0xFF925667); // Muted Berry
  static const shade = Color(0xFF5A2632); // Deep Wine
  static const darkShade = Color(0xFF3D1A22); // Oxblood

  // Warm supporting underrated colours
  static const cocoa = Color(0xFF6E554B);
  static const dustyRose = Color(0xFFB76E79);
  static const oldRose = Color(0xFFA55C6B);
  static const mushroom = Color(0xFF8C7A76);
  static const smokedSlate = Color(0xFF6B5B60);
  static const lichen = Color(0xFF5A7363);
  static const antiqueBrass = Color(0xFF9E7B58);
  static const dustyCoral = Color(0xFFB85D59);

  // Neutrals
  static const background = Color(0xFFF7F2EC); // Warm Parchment
  static const surface = Color(0xFFFFFDFC); // Ivory White
  static const surfaceSoft = Color(0xFFF3ECE8);
  static const secondary = Color(0xFF786B68); // Taupe
  static const border = Color(0xFFE6DCD7); // Warm Stone
  static const text = Color(0xFF292224); // Espresso Charcoal
  static const textSoft = Color(0xFF5F5351);

  static const focusSurface = Color(0xFFF0E4E7);
  static const navSelectedSurface = Color(0xFFEAD8DC);
  static const hoverSurface = Color(0xFFF3E7EA);
  static const pressedSurface = Color(0xFFE4D0D5);

  // Semantic aliases & backward compatibility
  static const primary = hue;
  static const primaryDark = shade;
  static const primarySoft = lightTint;
  static const primaryGlow = dustyRose;
  static const accent = dustyRose;
  static const secondaryAccent = cocoa;

  static const textSecondary = secondary;
  static const muted = textSoft;

  static const positive = cocoa;
  static const warning = oldRose;
  static const danger = Color(0xFF9D3041);

  static const success = cocoa;
  static const successSoft = lightTint;
  static const warningSoft = surfaceSoft;
  static const dangerSoft = lightTint;

  // Interaction states
  static const hover = Color(0xFFF0D6DC);
  static const pressed = Color(0xFFE8C5CD);
  static const focus = Color(0xFFC98A98);

  // Event category colors
  static const hackathon = hue;
  static const workshop = dustyRose;
  static const competition = cocoa;
  static const conference = shade;
  static const meetup = tone;
  static const symposium = oldRose;
  static const openSource = shade;

  static const hackathonSoft = lightTint;
  static const workshopSoft = Color(0xFFF9EBEE);
  static const competitionSoft = surfaceSoft;
  static const conferenceSoft = lightTint;
  static const meetupSoft = lightTint;
  static const symposiumSoft = lightTint;
  static const openSourceSoft = surfaceSoft;

  // Hero gradient colors
  static const heroNavy = darkShade;
  static const heroNavyDark = Color(0xFF240E16);

  static Color opportunityAccent(String type) {
    switch (type.trim().toLowerCase()) {
      case 'hackathon':
        return hue;
      case 'workshop':
        return dustyRose;
      case 'competition':
        return cocoa;
      case 'open source program':
      case 'open source project':
        return const Color(0xFF5B454A);
      case 'conference':
        return shade;
      default:
        return tone;
    }
  }

  static Color opportunitySurface(String type) {
    switch (type.trim().toLowerCase()) {
      case 'hackathon':
        return lightTint;
      case 'workshop':
        return const Color(0xFFF9EBEE);
      case 'competition':
        return const Color(0xFFF3ECE8);
      case 'open source program':
      case 'open source project':
        return const Color(0xFFF2EBE9);
      default:
        return surface;
    }
  }

  static Color categoryAccent(String type) => opportunityAccent(type);
  static Color categorySurface(String type) => opportunitySurface(type);

  static IconData categoryIcon(String type) {
    switch (type.trim().toLowerCase()) {
      case 'hackathon':
        return Icons.code_rounded;
      case 'workshop':
        return Icons.handyman_outlined;
      case 'competition':
        return Icons.emoji_events_outlined;
      case 'conference':
        return Icons.groups_outlined;
      case 'meetup':
        return Icons.people_outline_rounded;
      case 'symposium':
        return Icons.campaign_outlined;
      case 'open source':
      case 'open source program':
      case 'open source project':
        return Icons.folder_open_rounded;
      default:
        return Icons.event_outlined;
    }
  }
}
