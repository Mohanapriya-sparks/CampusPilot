import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'skill_sprint_challenge_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String title;
  final String organizer;
  final String type;
  final String date;
  final String location;
  final String mode;
  final String description;
  final int fit;

  const EventDetailsScreen({
    super.key,
    this.title = 'Stanford TreeHacks 2025',
    this.organizer = 'Stanford University',
    this.type = 'Hackathon',
    this.date = 'Mar 14 – Mar 16, 2025',
    this.location = 'Stanford, CA',
    this.mode = 'Offline',
    this.description =
        'Join 2,000+ students worldwide to build innovative solutions, '
            'learn from industry mentors, and make a real impact.',
    this.fit = 78,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int selectedTab = 0;
  bool saved = false;

  static const Color antiqueBrass = Color(0xFFA88758);

  final tabs = const [
    'Overview',
    'Requirements',
    'Prizes',
    'FAQs',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 410,
            ),
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heroImage(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _eventTitle(),
                              const SizedBox(height: 10),
                              _eventMeta(),
                              const SizedBox(height: 13),
                              _tabs(),
                              const SizedBox(height: 16),
                              _about(),
                              const SizedBox(height: 17),
                              _skillSprint(),
                              const SizedBox(height: 12),
                              _attendeeCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _topBar() {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.text,
              size: 19,
            ),
          ),
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Φ',
              style: TextStyle(
                color: AppColors.hue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'CampusPilot',
              style: TextStyle(
                color: AppColors.shade,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.text,
                  size: 20,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.dustyRose,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAMPUS IMAGE
  // ============================================================

  Widget _heroImage() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      height: 138,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkShade.withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // REAL IMAGE
          Image.asset(
            'assets/images/events/treehacks_banner.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE6B7B1),
                      Color(0xFFD4938F),
                      Color(0xFF9F5C64),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              );
            },
          ),

          // WARM ROSE FILTER
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.lightTint.withOpacity(.10),
                  AppColors.dustyRose.withOpacity(.12),
                  AppColors.darkShade.withOpacity(.30),
                ],
              ),
            ),
          ),

          // HACKATHON BADGE
          Positioned(
            left: 11,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(.94),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 10,
                    color: AppColors.hue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.type.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.hue,
                      fontSize: 7.5,
                      letterSpacing: .45,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SHARE + SAVE
          Positioned(
            right: 10,
            bottom: 8,
            child: Row(
              children: [
                _heroAction(
                  Icons.ios_share_outlined,
                  () {},
                ),
                const SizedBox(width: 6),
                _heroAction(
                  saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  () {
                    setState(() {
                      saved = !saved;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroAction(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.surface.withOpacity(.94),
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.hover,
        splashColor: AppColors.pressed,
        child: SizedBox(
          width: 31,
          height: 31,
          child: Icon(
            icon,
            size: 15,
            color: AppColors.hue,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EVENT TITLE
  // ============================================================

  Widget _eventTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 23,
            height: 1,
            letterSpacing: -.55,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'A global student hackathon to build a more\nhuman-centered future.',
          style: TextStyle(
            color: AppColors.textSoft,
            fontSize: 9,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EVENT META
  // ============================================================

  Widget _eventMeta() {
    return Wrap(
      spacing: 13,
      runSpacing: 6,
      children: [
        _meta(
          Icons.calendar_month_outlined,
          widget.date,
        ),
        _meta(
          Icons.location_on_outlined,
          widget.location,
        ),
      ],
    );
  }

  Widget _meta(
    IconData icon,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.dustyRose,
          size: 13,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 8.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _tabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final active = selectedTab == index;

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? AppColors.hue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? AppColors.hue : AppColors.secondary,
                        fontSize: 7.8,
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _about() {
    if (selectedTab != 0) {
      return _tabPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the event',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.description,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 8.8,
            height: 1.42,
          ),
        ),
      ],
    );
  }

  Widget _tabPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        selectedTab == 1
            ? 'Event requirements will appear here.'
            : selectedTab == 2
                ? 'Prize information will appear here.'
                : 'Frequently asked questions will appear here.',
        style: const TextStyle(
          color: AppColors.textSoft,
          fontSize: 9,
        ),
      ),
    );
  }

  // ============================================================
  // SKILL SPRINT
  // ============================================================

  Widget _skillSprint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        13,
        12,
        13,
        13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8E7E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dustyRose.withOpacity(.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: AppColors.hue.withOpacity(.09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.hue,
                  size: 17,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Skill Sprint',
                  style: TextStyle(
                    color: AppColors.hue,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  '~3 minutes',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Test your readiness in 3 minutes',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Answer a few quick questions to see how your real skills '
            'match this event\'s requirements.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 8,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _skillChip(
                title: 'Problem Solving',
                icon: Icons.lightbulb_outline_rounded,
                color: AppColors.hue,
              ),
              _skillChip(
                title: 'Flutter',
                icon: Icons.code_rounded,
                color: const Color(0xFF65747B),
              ),
              _skillChip(
                title: 'GitHub',
                asset: 'assets/images/social/github.png',
                color: AppColors.text,
              ),
              _skillChip(
                title: 'Teamwork',
                icon: Icons.groups_outlined,
                color: antiqueBrass,
              ),
              _skillChip(
                title: 'UI/UX',
                icon: Icons.palette_outlined,
                color: AppColors.dustyRose,
              ),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SkillSprintChallengeScreen(
                      eventTitle: widget.title,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(
                  const Size(0, 45),
                ),
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(
                      WidgetState.pressed,
                    )) {
                      return AppColors.pressed;
                    }

                    if (states.contains(
                      WidgetState.hovered,
                    )) {
                      return AppColors.hover;
                    }

                    return AppColors.hue;
                  },
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Skill Sprint',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillChip({
    required String title,
    IconData? icon,
    String? asset,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.78),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withOpacity(.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (asset != null)
            SizedBox(
              width: 13,
              height: 13,
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            )
          else if (icon != null)
            Icon(
              icon,
              size: 12,
              color: color,
            ),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 7.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENDEE CARD
  // ============================================================

  Widget _attendeeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6ECE8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              color: AppColors.hue,
              size: 17,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2.4K+ students attending',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'From 500+ universities worldwide',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 7.2,
                  ),
                ),
                SizedBox(height: 6),
                _MiniAvatars(),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.lightTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.hue,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// SMALL AVATARS
// ===============================================================

class _MiniAvatars extends StatelessWidget {
  const _MiniAvatars();

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.dustyRose,
      Color(0xFFA88758),
      Color(0xFF65747B),
      Color(0xFF74806A),
    ];

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          SizedBox(
            width: 63,
            child: Stack(
              children: List.generate(
                colors.length,
                (index) {
                  return Positioned(
                    left: index * 13,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Text(
            '+2.4K',
            style: TextStyle(
              color: AppColors.hue,
              fontSize: 7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
