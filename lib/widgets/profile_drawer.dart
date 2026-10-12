import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/student_profile.dart';
import '../screens/profile_setup_screen.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'campus_pilot_logo.dart';

class ProfileDrawer extends StatelessWidget {
  final VoidCallback? onSavedEvents;
  final VoidCallback? onOpenSourcePath;
  final VoidCallback? onSkillReadiness;
  final VoidCallback? onSettings;
  final VoidCallback? onProfileTap;

  const ProfileDrawer({
    super.key,
    this.onSavedEvents,
    this.onOpenSourcePath,
    this.onSkillReadiness,
    this.onSettings,
    this.onProfileTap,
  });

  StudentProfile get profile => AppState.instance.profile ?? StudentProfile();

  // ============================================================
  // BASIC PROFILE HELPERS
  // ============================================================

  String get displayName {
    if (profile.fullName.trim().isNotEmpty) {
      return profile.fullName.trim();
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user?.email?.trim().isNotEmpty == true) {
      return user!.email!.trim();
    }

    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim();
    }

    return 'Signed-in user';
  }

  String get _initials {
    final words = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'CP';
    }

    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, min(2, word.length)).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  String get _college {
    if (profile.college.trim().isNotEmpty) {
      return profile.college.trim();
    }

    return 'College not added';
  }

  String get _courseLine {
    final parts = <String>[];

    if (profile.degree.trim().isNotEmpty) {
      parts.add(profile.degree.trim());
    }

    if (profile.department.trim().isNotEmpty) {
      parts.add(profile.department.trim());
    }

    if (profile.year.trim().isNotEmpty) {
      parts.add(profile.year.trim());
    }

    if (parts.isEmpty) {
      return 'Course details not added';
    }

    return parts.join(' · ');
  }

  // ============================================================
  // URL OPENING
  // ============================================================

  Future<void> _openLink(
    BuildContext context,
    String value,
    String label,
  ) async {
    if (value.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label is not connected yet.'),
        ),
      );
      return;
    }

    var text = value.trim();

    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      text = 'https://$text';
    }

    final uri = Uri.tryParse(text);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid $label link.'),
        ),
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $label.'),
        ),
      );
    }
  }

  // ============================================================
  // CLOSE + ACTION
  // ============================================================

  void _closeAndRun(
    BuildContext context,
    VoidCallback? callback,
    String fallbackMessage,
  ) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    navigator.pop();

    if (callback != null) {
      Future<void>.delayed(
        const Duration(milliseconds: 180),
        callback,
      );
    } else {
      Future<void>.delayed(
        const Duration(milliseconds: 180),
        () {
          messenger.showSnackBar(
            SnackBar(
              content: Text(fallbackMessage),
            ),
          );
        },
      );
    }
  }

  Future<void> _editProfile(
    BuildContext context,
  ) async {
    final navigator = Navigator.of(context);

    navigator.pop();

    await Future<void>.delayed(
      const Duration(milliseconds: 180),
    );

    if (onProfileTap != null) {
      onProfileTap!();
      return;
    }

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(
          editing: true,
        ),
      ),
    );
  }

  Future<void> _logout(
    BuildContext context,
  ) async {
    Navigator.of(context).pop();

    await AppState.instance.clearSession();
    await FirebaseAuth.instance.signOut();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final width = min(
          MediaQuery.sizeOf(context).width * .87,
          430.0,
        );

        return Drawer(
          width: width,
          backgroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context),
                        _profileBlock(context),
                        const SizedBox(height: 18),
                        _summaryCard(context),
                        const SizedBox(height: 19),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Divider(
                            color: AppColors.border.withOpacity(.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _menuItem(
                          context,
                          icon: Icons.person_outline_rounded,
                          title: 'My Profile',
                          onTap: () {
                            _editProfile(context);
                          },
                        ),
                        _menuItem(
                          context,
                          icon: Icons.bookmark_border_rounded,
                          title: 'Saved Events',
                          onTap: () {
                            _closeAndRun(
                              context,
                              onSavedEvents,
                              'Saved Events screen is not connected yet.',
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          icon: Icons.eco_outlined,
                          title: 'Open Source Path',
                          onTap: () {
                            _closeAndRun(
                              context,
                              onOpenSourcePath,
                              'Open Source Path is not connected yet.',
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          icon: Icons.bar_chart_rounded,
                          title: 'Skill Readiness',
                          onTap: () {
                            _closeAndRun(
                              context,
                              onSkillReadiness,
                              'Skill Readiness is not connected yet.',
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {
                            _closeAndRun(
                              context,
                              onSettings,
                              'Settings screen is not connected yet.',
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: _logoutButton(
                            context,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        14,
        0,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: CampusPilotLogo(height: 32),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.text,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE BLOCK
  // ============================================================

  Widget _profileBlock(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                bottom: 45,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(25),
                    ),
                    child: const CustomPaint(
                      painter: _CampusBannerPainter(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                bottom: 3,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 105,
                      height: 105,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.hue,
                            AppColors.dustyRose,
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkShade.withOpacity(.12),
                            blurRadius: 18,
                            offset: const Offset(
                              0,
                              7,
                            ),
                          ),
                        ],
                      ),
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -3,
                      bottom: 2,
                      child: Material(
                        color: AppColors.surface,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _editProfile(
                              context,
                            );
                          },
                          child: const SizedBox(
                            width: 35,
                            height: 35,
                            child: Icon(
                              Icons.edit_outlined,
                              size: 17,
                              color: AppColors.hue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_college • $_courseLine',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _socialLink(
                    context,
                    iconText: 'GH',
                    label: 'GitHub',
                    value: profile.github,
                    background: AppColors.text,
                    foreground: Colors.white,
                  ),
                  _socialLink(
                    context,
                    iconText: 'in',
                    label: 'LinkedIn',
                    value: profile.linkedin,
                    background: const Color(
                      0xFF51646B,
                    ),
                    foreground: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialLink(
    BuildContext context, {
    required String iconText,
    required String label,
    required String value,
    required Color background,
    required Color foreground,
  }) {
    final connected = value.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openLink(
            context,
            value,
            label,
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 27,
                height: 27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: connected ? background : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(
                    7,
                  ),
                ),
                child: Text(
                  iconText,
                  style: TextStyle(
                    color: connected ? foreground : AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: connected ? AppColors.text : AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                connected
                    ? Icons.open_in_new_rounded
                    : Icons.add_circle_outline_rounded,
                size: 14,
                color: connected ? AppColors.hue : AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkShade.withOpacity(.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'My Student Summary',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _editProfile(
                    context,
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                ),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.hue,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _summaryRow(
            icon: Icons.code_rounded,
            iconColor: AppColors.hue,
            title: 'Skills',
            values: profile.skills,
          ),
          const Divider(
            color: AppColors.border,
            height: 18,
          ),
          _summaryRow(
            icon: Icons.favorite_border_rounded,
            iconColor: AppColors.dustyRose,
            title: 'Interests',
            values: profile.interests,
          ),
          const Divider(
            color: AppColors.border,
            height: 18,
          ),
          _summaryRow(
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.cocoa,
            title: 'Preferred Tracks',
            values: profile.preferredEventTypes,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> values,
  }) {
    final shown = values.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.09),
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                if (shown.isEmpty)
                  Text(
                    'Not added yet',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10.5,
                    ),
                  )
                else
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: shown
                        .map(
                          (value) => _miniChip(
                            value,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              top: 11,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.hue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.textSoft,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.hover,
          splashColor: AppColors.pressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 13,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Icon(
                    icon,
                    color: AppColors.text,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.hue,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _logoutButton(
    BuildContext context,
  ) {
    return Material(
      color: AppColors.lightTint,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _logout(context);
        },
        hoverColor: AppColors.hover,
        splashColor: AppColors.pressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.hue,
                size: 25,
              ),
              SizedBox(width: 13),
              Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.shade,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// CAMPUS BANNER PAINTER
// Gives the top section a campus / blossom atmosphere without an asset.
// ====================================================================

class _CampusBannerPainter extends CustomPainter {
  const _CampusBannerPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final bg = Paint()..color = AppColors.lightTint;

    canvas.drawRect(
      Offset.zero & size,
      bg,
    );

    final ground = Paint()..color = AppColors.tint;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * .73,
        size.width,
        size.height * .27,
      ),
      ground,
    );

    // Main building
    final building = Paint()
      ..color = const Color(
        0xFFE4B6AC,
      );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .38,
        size.height * .47,
        size.width * .40,
        size.height * .30,
      ),
      building,
    );

    // Tower
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .57,
        size.height * .19,
        size.width * .11,
        size.height * .58,
      ),
      building,
    );

    final roof = Path()
      ..moveTo(
        size.width * .55,
        size.height * .19,
      )
      ..lineTo(
        size.width * .625,
        size.height * .08,
      )
      ..lineTo(
        size.width * .70,
        size.height * .19,
      )
      ..close();

    canvas.drawPath(
      roof,
      Paint()..color = AppColors.dustyRose.withOpacity(.55),
    );

    final dark = Paint()..color = AppColors.shade.withOpacity(.18);

    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * (.43 + i * .08),
          size.height * .56,
          7,
          20,
        ),
        dark,
      );
    }

    // Trees / blossoms
    final trunk = Paint()
      ..color = AppColors.cocoa.withOpacity(.35)
      ..strokeWidth = 3;

    final blossom = Paint()..color = AppColors.dustyRose.withOpacity(.42);

    final treeXs = [
      .08,
      .18,
      .28,
      .80,
      .89,
      .95,
    ];

    for (final factor in treeXs) {
      final x = size.width * factor;

      canvas.drawLine(
        Offset(
          x,
          size.height * .62,
        ),
        Offset(
          x,
          size.height * .80,
        ),
        trunk,
      );

      canvas.drawCircle(
        Offset(
          x,
          size.height * .55,
        ),
        18,
        blossom,
      );

      canvas.drawCircle(
        Offset(
          x - 12,
          size.height * .61,
        ),
        13,
        blossom,
      );

      canvas.drawCircle(
        Offset(
          x + 12,
          size.height * .60,
        ),
        13,
        blossom,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
