import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/campus_pilot_logo.dart';
import '../widgets/profile_drawer.dart';
import 'event_details_screen.dart';
import 'profile_setup_screen.dart';
import 'skill_sprint_challenge_screen.dart';

class OpportunityExplorerScreen extends StatefulWidget {
  const OpportunityExplorerScreen({
    super.key,
  });

  @override
  State<OpportunityExplorerScreen> createState() =>
      _OpportunityExplorerScreenState();
}

class _OpportunityExplorerScreenState extends State<OpportunityExplorerScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final searchController = TextEditingController();

  String selectedCategory = 'All';

  final categories = const [
    'All',
    'Hackathons',
    'Workshops',
    'Open Source',
    'Competitions',
  ];

  final opportunities = const [
    OpportunityData(
      category: 'Hackathons',
      type: 'Hackathon',
      title: 'Stanford TreeHacks 2025',
      organizer: 'Stanford University, CA',
      date: 'Mar 14 – Mar 16, 2025',
      deadline: 'Jan 31, 2025',
      location: 'Stanford University, CA',
      mode: 'Offline',
      description:
          'A global student hackathon to build a more human-centered future.',
      fit: 96,
      featured: true,
      icon: Icons.emoji_events_rounded,
    ),
    OpportunityData(
      category: 'Workshops',
      type: 'Workshop',
      title: 'UI/UX Design for Social Impact',
      organizer: 'Design Community',
      date: 'Apr 5, 2025',
      deadline: 'Apr 3, 2025',
      location: 'Chennai',
      mode: 'Offline',
      description:
          'Hands-on session to design digital solutions for real-world problems.',
      fit: 92,
      icon: Icons.palette_outlined,
    ),
    OpportunityData(
      category: 'Workshops',
      type: 'Workshop',
      title: 'Product Management 101',
      organizer: 'Campus Innovation Cell',
      date: 'Mar 22, 2025',
      deadline: 'Mar 20, 2025',
      location: 'Online',
      mode: 'Online',
      description:
          'Learn core PM skills from industry experts through real case studies.',
      fit: 88,
      icon: Icons.lightbulb_outline_rounded,
    ),
    OpportunityData(
      category: 'Open Source',
      type: 'Open Source Program',
      title: 'Google Summer of Code 2025',
      organizer: 'Open Source Organizations',
      date: 'May – Aug 2025',
      deadline: 'Applications vary',
      location: 'Remote',
      mode: 'Online',
      description:
          'Contribute to open source projects with mentorship from global orgs.',
      fit: 94,
      icon: Icons.code_rounded,
    ),
    OpportunityData(
      category: 'Open Source',
      type: 'Open Source Program',
      title: 'MLH Fellowship',
      organizer: 'Major League Hacking',
      date: 'Jun – Aug 2025',
      deadline: 'Applications vary',
      location: 'Remote',
      mode: 'Online',
      description:
          'Work on meaningful projects, gain mentorship, and build in public.',
      fit: 90,
      icon: Icons.hub_outlined,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<OpportunityData> get filtered {
    final query = searchController.text.trim().toLowerCase();

    return opportunities.where((item) {
      final categoryMatches =
          selectedCategory == 'All' || item.category == selectedCategory;

      final searchMatches = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.organizer.toLowerCase().contains(query) ||
          item.type.toLowerCase().contains(query);

      return categoryMatches && searchMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: ProfileDrawer(
        onProfileTap: _openProfile,
        onSavedEvents: _openSavedEvents,
        onOpenSourcePath: _openOpenSourcePath,
        onSkillReadiness: _openSkillReadiness,
        onSettings: _openSettings,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _hero(),
                        const SizedBox(height: 20),
                        _searchBar(),
                        const SizedBox(height: 13),
                        _categories(),
                        const SizedBox(height: 28),
                        if (selectedCategory == 'All') ...[
                          _categorySection(
                            title: 'Hackathons',
                            subtitle: 'Build. Innovate. Make an impact.',
                            items: _itemsFor('Hackathons'),
                            largeFirstCard: true,
                          ),
                          const SizedBox(height: 29),
                          _categorySection(
                            title: 'Workshops',
                            subtitle: 'Learn new skills. Get hands-on.',
                            items: _itemsFor('Workshops'),
                          ),
                          const SizedBox(height: 29),
                          _categorySection(
                            title: 'Open Source Programs',
                            subtitle: 'Contribute. Collaborate. Grow.',
                            items: _itemsFor('Open Source'),
                          ),
                        ] else ...[
                          _sectionHeader(
                            selectedCategory,
                            '${filtered.length} opportunities found',
                          ),
                          const SizedBox(height: 13),
                          ...filtered.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _wideCard(item),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(Icons.menu_rounded, size: 27),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: CampusPilotLogo(
                height: 38,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 25),
                Positioned(
                  right: 1,
                  top: 0,
                  child: Container(
                    width: 7,
                    height: 7,
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

  Widget _hero() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 11, bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E X P L O R E   ·   L E A R N   ·   B U I L D   ·   B E L O N G',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Discover your next',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -.9,
                ),
              ),
              const Text(
                'opportunity.',
                style: TextStyle(
                  color: AppColors.dustyRose,
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1.05,
                  letterSpacing: -.7,
                ),
              ),
              const SizedBox(height: 11),
              const SizedBox(
                width: 300,
                child: Text(
                  'Find opportunities that fit your interests, skills and growth goals.',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -28,
          top: 0,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.tint.withOpacity(.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'More\nthan a degree',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.hue,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Search events, skills, or organizations...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () {
            _showFilterSheet();
          },
          icon: const Icon(Icons.tune_rounded),
        ),
      ),
    );
  }

  Widget _categories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final active = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(
              label: Text(category),
              selected: active,
              showCheckmark: false,
              selectedColor: AppColors.hue,
              backgroundColor: AppColors.tint,
              side: BorderSide(
                color: active ? AppColors.hue : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: active ? Colors.white : AppColors.textSoft,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _categorySection({
    required String title,
    required String subtitle,
    required List<OpportunityData> items,
    bool largeFirstCard = false,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _sectionHeader(title, subtitle),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory =
                      title == 'Open Source Programs' ? 'Open Source' : title;
                });
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See all'),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (largeFirstCard) ...[
          _featuredCard(items.first),
          if (items.length > 1) ...[
            const SizedBox(height: 10),
            ...items.skip(1).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _wideCard(item),
                  ),
                ),
          ],
        ] else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 620
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth * .80;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 11),
                      child: SizedBox(
                        width: cardWidth,
                        child: _compactCard(item),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _featuredCard(OpportunityData item) {
    return Material(
      color: AppColors.darkShade,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openOpportunity(item);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 245),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkShade,
                AppColors.shade,
                AppColors.tone,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -25,
                bottom: -25,
                child: Icon(
                  item.icon,
                  color: Colors.white.withOpacity(.06),
                  size: 190,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.featured) _darkBadge('★  FEATURED'),
                        const Spacer(),
                        _fitBadge(item.fit, dark: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 13),
                    _darkMeta(Icons.calendar_today_outlined, item.date),
                    const SizedBox(height: 7),
                    _darkMeta(Icons.location_on_outlined, item.location),
                    const SizedBox(height: 11),
                    SizedBox(
                      width: 330,
                      child: Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.78),
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 47,
                        height: 47,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.hue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactCard(OpportunityData item) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openOpportunity(item);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 95,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.tint, AppColors.lightTint],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        item.icon,
                        size: 44,
                        color: AppColors.hue.withOpacity(.55),
                      ),
                    ),
                    Positioned(
                      top: 9,
                      right: 9,
                      child: _fitBadge(item.fit),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _smallMeta(Icons.calendar_today_outlined, item.date),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.lightTint,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.hue,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wideCard(OpportunityData item) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openOpportunity(item);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.lightTint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  item.icon,
                  color: AppColors.hue,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.type} · ${item.date}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _fitBadge(item.fit),
                  const SizedBox(height: 10),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.hue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openOpportunity(OpportunityData item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          title: item.title,
          type: item.type,
          organizer: item.organizer,
          date: item.date,
          location: item.location,
          mode: item.mode,
          description: item.description,
        ),
      ),
    );
  }

  List<OpportunityData> _itemsFor(String category) {
    final query = searchController.text.trim().toLowerCase();

    return opportunities.where((item) {
      final categoryMatches = item.category == category;
      final searchMatches = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.organizer.toLowerCase().contains(query);

      return categoryMatches && searchMatches;
    }).toList();
  }

  Widget _fitBadge(int fit, {bool dark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.cocoa : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 13,
            color: dark ? Colors.white : AppColors.cocoa,
          ),
          const SizedBox(width: 4),
          Text(
            '$fit% Fit',
            style: TextStyle(
              color: dark ? Colors.white : AppColors.cocoa,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: Colors.white.withOpacity(.15),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _darkMeta(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.tint, size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(.82),
              fontSize: 10.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallMeta(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.dustyRose),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 9.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(
          editing: true,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _openSavedEvents() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _SavedEventsMvpScreen(),
      ),
    );
  }

  void _openOpenSourcePath() {
    if (!mounted) return;

    setState(() {
      selectedCategory = 'Open Source';
    });
  }

  void _openSkillReadiness() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SkillSprintChallengeScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _CampusPilotSettingsScreen(),
      ),
    );
  }

  void _openCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _CommunityMvpScreen(),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Opportunity Filters',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Select category to filter opportunities.',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    return ActionChip(
                      label: Text(category),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomNavigation() {
    return SafeArea(
      child: Container(
        height: 66,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            _bottomItem(
              Icons.home_rounded,
              'Explore',
              true,
              () {
                setState(() {
                  selectedCategory = 'All';
                });
              },
            ),
            _bottomItem(
              Icons.bookmark_border_rounded,
              'Saved',
              false,
              _openSavedEvents,
            ),
            _bottomItem(
              Icons.explore_outlined,
              'Opportunities',
              false,
              () {
                setState(() {
                  selectedCategory = 'All';
                });
              },
            ),
            _bottomItem(
              Icons.groups_outlined,
              'Community',
              false,
              _openCommunity,
            ),
            _bottomItem(
              Icons.person_outline,
              'Profile',
              false,
              () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active ? AppColors.hue : AppColors.secondary,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.hue : AppColors.secondary,
                  fontSize: 9,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedEventsMvpScreen extends StatelessWidget {
  const _SavedEventsMvpScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CampusPilotLogo(height: 32),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 54,
                    color: AppColors.hue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Saved Events',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your saved opportunities will appear here. '
                    'The next MVP step is connecting the event save button '
                    'to your existing AppState / Firestore saved-events data.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CampusPilotSettingsScreen extends StatefulWidget {
  const _CampusPilotSettingsScreen();

  @override
  State<_CampusPilotSettingsScreen> createState() =>
      _CampusPilotSettingsScreenState();
}

class _CampusPilotSettingsScreenState
    extends State<_CampusPilotSettingsScreen> {
  bool opportunityAlerts = true;
  bool deadlineReminders = true;
  bool personalizedSuggestions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CampusPilotLogo(height: 42),
              const SizedBox(height: 22),
              _settingTile(
                title: 'Opportunity alerts',
                subtitle: 'Show alerts for new matching opportunities.',
                value: opportunityAlerts,
                onChanged: (value) {
                  setState(() {
                    opportunityAlerts = value;
                  });
                },
              ),
              _settingTile(
                title: 'Deadline reminders',
                subtitle: 'Remind me before registration deadlines.',
                value: deadlineReminders,
                onChanged: (value) {
                  setState(() {
                    deadlineReminders = value;
                  });
                },
              ),
              _settingTile(
                title: 'Personalized suggestions',
                subtitle: 'Use my profile to improve recommendations.',
                value: personalizedSuggestions,
                onChanged: (value) {
                  setState(() {
                    personalizedSuggestions = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSoft,
          ),
        ),
      ),
    );
  }
}

class _CommunityMvpScreen extends StatelessWidget {
  const _CommunityMvpScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 54,
                    color: AppColors.hue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'CampusPilot Community',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Community is available as an MVP navigation page. '
                    'Team finding, peer discussions and mentorship can be '
                    'added after the core opportunity flow is complete.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OpportunityData {
  final String category;
  final String type;
  final String title;
  final String organizer;
  final String date;
  final String deadline;
  final String location;
  final String mode;
  final String description;
  final int fit;
  final bool featured;
  final IconData icon;

  const OpportunityData({
    required this.category,
    required this.type,
    required this.title,
    required this.organizer,
    required this.date,
    required this.deadline,
    required this.location,
    required this.mode,
    required this.description,
    required this.fit,
    required this.icon,
    this.featured = false,
  });
}
