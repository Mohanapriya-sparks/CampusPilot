import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/url_helper.dart';
import 'profile_setup_screen.dart';

// ============================================================
// MAIN CAMPUSPILOT PORTAL
// ============================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;
  final Set<String> savedEvents = {'ai-hack-26', 'gssoc-27'};
  String searchQuery = '';

  void _changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _search(String value) {
    setState(() {
      searchQuery = value.trim();
      selectedIndex = 1;
    });
  }

  void _toggleSaved(DemoOpportunity event) {
    setState(() {
      if (savedEvents.contains(event.id)) {
        savedEvents.remove(event.id);
      } else {
        savedEvents.add(event.id);
      }
    });
  }

  Future<void> _openProfileEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
          editing: AppState.instance.profile != null,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _openEvent(DemoOpportunity event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          event: event,
          initiallySaved: savedEvents.contains(event.id),
          onSavedChanged: (saved) {
            setState(() {
              if (saved) {
                savedEvents.add(event.id);
              } else {
                savedEvents.remove(event.id);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _currentPage() {
    switch (selectedIndex) {
      case 0:
        return HomeView(
          savedEvents: savedEvents,
          onOpenEvent: _openEvent,
          onToggleSaved: _toggleSaved,
          onOpenDiscover: () => _changePage(1),
          onOpenMyPath: () => _changePage(2),
          onOpenTimeline: () => _changePage(3),
          onOpenProfile: _openProfileEditor,
          onOpenAcademic: () => _changePage(2),
        );

      case 1:
        return DiscoverView(
          initialSearch: searchQuery,
          savedEvents: savedEvents,
          onOpenEvent: _openEvent,
          onToggleSaved: _toggleSaved,
        );

      case 2:
        return MyPathView(
          onOpenEvent: _openEvent,
        );

      case 3:
        return TimelineView(
          onOpenEvent: _openEvent,
        );

      case 4:
        return ProfileView(
          onEdit: _openProfileEditor,
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;

        if (desktop) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Row(
                children: [
                  CampusSidebar(
                    selectedIndex: selectedIndex,
                    onChanged: _changePage,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CampusTopBar(
                          onSearch: _search,
                          onProfile: () => _changePage(4),
                        ),
                        Expanded(
                          child: _currentPage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: AppColors.surface,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'CampusPilot',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                ),
              ),
              IconButton(
                tooltip: 'Profile',
                onPressed: () => _changePage(4),
                icon: const Icon(
                  Icons.account_circle_outlined,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: _currentPage(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: _changePage,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.alt_route_outlined),
                selectedIcon: Icon(Icons.alt_route_rounded),
                label: 'My Path',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_timeline_outlined),
                selectedIcon: Icon(Icons.view_timeline_rounded),
                label: 'Timeline',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// SIDEBAR (DESKTOP)
// ============================================================

class CampusSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CampusSidebar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavData('Home', Icons.home_outlined, Icons.home_rounded),
      _NavData('Discover', Icons.explore_outlined, Icons.explore_rounded),
      _NavData('My Path', Icons.alt_route_outlined, Icons.alt_route_rounded),
      _NavData('Timeline', Icons.view_timeline_outlined,
          Icons.view_timeline_rounded),
      _NavData('Profile', Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return Container(
      width: 246,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 18, 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CampusPilot',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'AI Opportunity Hub',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Text(
                    'NAVIGATE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                _item(context, items[0], 0),
                _item(context, items[1], 1),
                _item(context, items[2], 2),
                _item(context, items[3], 3),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 8),
                _item(context, items[4], 4),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CampusPilot AI',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Discover • Prepare • Compete',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, _NavData item, int index) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(index),
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.04),
          hoverColor: AppColors.primary.withOpacity(0.035),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 21,
                  color: selected ? AppColors.primary : const Color(0xFF64748B),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFF334155),
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
}

class _NavData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavData(this.label, this.icon, this.selectedIcon);
}

// ============================================================
// TOP BAR
// ============================================================

class CampusTopBar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onProfile;

  const CampusTopBar({
    super.key,
    required this.onSearch,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final profile = AppState.instance.profile;
    final user = FirebaseAuth.instance.currentUser;

    String initials = 'CP';
    final name = profile?.fullName.trim();

    if (name != null && name.isNotEmpty) {
      initials = name
          .split(' ')
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => part[0].toUpperCase())
          .join();
    } else if (user?.email?.isNotEmpty == true) {
      initials = user!.email![0].toUpperCase();
    }

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search opportunities, skills or programs...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 21,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) async {
              if (value == 'profile') {
                onProfile();
              }
              if (value == 'logout') {
                await AppState.instance.clearSession();
                await FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                  value: 'profile', child: Text('View profile')),
              PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
            child: CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: Text(
                initials,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME DASHBOARD VIEW
// ============================================================

class HomeView extends StatelessWidget {
  final Set<String> savedEvents;
  final ValueChanged<DemoOpportunity> onOpenEvent;
  final ValueChanged<DemoOpportunity> onToggleSaved;
  final VoidCallback onOpenDiscover;
  final VoidCallback onOpenMyPath;
  final VoidCallback onOpenTimeline;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenAcademic;

  const HomeView({
    super.key,
    required this.savedEvents,
    required this.onOpenEvent,
    required this.onToggleSaved,
    required this.onOpenDiscover,
    required this.onOpenMyPath,
    required this.onOpenTimeline,
    required this.onOpenProfile,
    required this.onOpenAcademic,
  });

  String _name() {
    final profile = AppState.instance.profile;
    if (profile != null && profile.fullName.trim().isNotEmpty) {
      return profile.fullName.trim().split(' ').first;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName?.trim().isNotEmpty == true) {
      return user!.displayName!.trim().split(' ').first;
    }
    return 'Mohan';
  }

  @override
  Widget build(BuildContext context) {
    final heroEvent = demoOpportunities.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 50),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, ${_name()}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your AI Opportunity Navigation System',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primarySoft,
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                onSubmitted: (q) => onOpenDiscover(),
                decoration: InputDecoration(
                  hintText: 'Search opportunities, skills or programs...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Hero Card ("Your Next Move")
              _HeroMoveCard(
                event: heroEvent,
                onViewDetails: () => onOpenEvent(heroEvent),
                onStartPreparation: onOpenMyPath,
              ),
              const SizedBox(height: 24),

              // Shortcuts Grid
              const Text(
                'Shortcuts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ShortcutTile(
                      label: 'Discover',
                      icon: Icons.explore_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: onOpenDiscover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShortcutTile(
                      label: 'My Path',
                      icon: Icons.alt_route_rounded,
                      color: const Color(0xFF3B82F6),
                      onTap: onOpenMyPath,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShortcutTile(
                      label: 'Timeline',
                      icon: Icons.view_timeline_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: onOpenTimeline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShortcutTile(
                      label: 'Saved',
                      icon: Icons.bookmark_rounded,
                      color: const Color(0xFF10B981),
                      onTap: onOpenDiscover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Linked Accounts Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Linked Accounts',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.primary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Connect GitHub & LinkedIn to get more accurate recommendations.',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      onPressed: onOpenProfile,
                      child:
                          const Text('Connect', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Recommended Section
              _SectionHeading(
                title: 'Recommended for you',
                subtitle: 'Opportunities matched to your skills and goals',
                action: 'View all',
                onPressed: onOpenDiscover,
              ),
              const SizedBox(height: 14),
              _OpportunityGrid(
                events: demoOpportunities.take(3).toList(),
                savedEvents: savedEvents,
                onOpenEvent: onOpenEvent,
                onToggleSaved: onToggleSaved,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HERO MOVE CARD ("Your Next Move")
// ============================================================

class _HeroMoveCard extends StatelessWidget {
  final DemoOpportunity event;
  final VoidCallback onViewDetails;
  final VoidCallback onStartPreparation;

  const _HeroMoveCard({
    required this.event,
    required this.onViewDetails,
    required this.onStartPreparation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.heroNavy,
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Your Next Move',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () {},
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white54, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${event.date} • ${event.location} • ${event.mode}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3 Radial Progress Meters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _GaugeMetric(percent: event.match, label: 'Event Fit'),
              _GaugeMetric(percent: 68, label: 'Readiness'),
              _GaugeMetric(percent: 73, label: 'Competitive'),
            ],
          ),
          const SizedBox(height: 22),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGlow,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onStartPreparation,
                  child: const Text('Start Preparation'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(true),
                const SizedBox(width: 5),
                _dot(false),
                const SizedBox(width: 5),
                _dot(false),
                const SizedBox(width: 5),
                _dot(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool active) => Container(
        width: active ? 16 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white30,
          borderRadius: BorderRadius.circular(3),
        ),
      );
}

class _GaugeMetric extends StatelessWidget {
  final int percent;
  final String label;

  const _GaugeMetric({required this.percent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percent / 100,
                strokeWidth: 5,
                backgroundColor: Colors.white12,
                color: percent >= 80
                    ? AppColors.success
                    : (percent >= 65
                        ? const Color(0xFF60A5FA)
                        : AppColors.warning),
              ),
              Center(
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DISCOVER VIEW
// ============================================================

class DiscoverView extends StatefulWidget {
  final String initialSearch;
  final Set<String> savedEvents;
  final ValueChanged<DemoOpportunity> onOpenEvent;
  final ValueChanged<DemoOpportunity> onToggleSaved;

  const DiscoverView({
    super.key,
    required this.initialSearch,
    required this.savedEvents,
    required this.onOpenEvent,
    required this.onToggleSaved,
  });

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  late final TextEditingController searchController;

  String quickFilter = 'For You';
  String selectedCity = 'Chennai';
  String selectedEventType = 'All';
  String selectedMode = 'Any';
  String selectedFee = 'Any';
  String selectedDepartment = 'All';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(covariant DiscoverView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearch != widget.initialSearch) {
      searchController.text = widget.initialSearch;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openFilters(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    if (desktop) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Filters'),
          content: SizedBox(
              width: 460,
              child: SingleChildScrollView(child: _buildFilterForm())),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCity = 'Chennai';
                  selectedEventType = 'All';
                  selectedMode = 'Any';
                  selectedFee = 'Any';
                  selectedDepartment = 'All';
                });
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Filters',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCity = 'Chennai';
                          selectedEventType = 'All';
                          selectedMode = 'Any';
                          selectedFee = 'Any';
                          selectedDepartment = 'All';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilterForm(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildFilterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('City',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedCity,
          items: [
            'Chennai',
            'Bengaluru',
            'Coimbatore',
            'Online',
            'Nagapattinam'
          ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => selectedCity = v!),
        ),
        const SizedBox(height: 16),
        const Text('Event Type',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            'All',
            'Hackathon',
            'Workshop',
            'Competition',
            'Open Source Program',
            'Conference',
            'Meetup',
            'Internship',
            'Other'
          ]
              .map((type) => ChoiceChip(
                    label: Text(type),
                    selected: selectedEventType == type,
                    onSelected: (_) => setState(() => selectedEventType = type),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text('Mode',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: ['Any', 'Online', 'Offline', 'Hybrid']
              .map((m) => ChoiceChip(
                    label: Text(m),
                    selected: selectedMode == m,
                    onSelected: (_) => setState(() => selectedMode = m),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text('Fee',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: ['Any', 'Free', 'Paid']
              .map((f) => ChoiceChip(
                    label: Text(f),
                    selected: selectedFee == f,
                    onSelected: (_) => setState(() => selectedFee = f),
                  ))
              .toList(),
        ),
      ],
    );
  }

  List<DemoOpportunity> get filtered {
    final query = searchController.text.trim().toLowerCase();

    return demoOpportunities.where((event) {
      bool quickOk = true;
      if (quickFilter == 'Nearby') {
        quickOk = event.location.toLowerCase().contains('chennai') ||
            event.mode.toLowerCase() == 'online';
      } else if (quickFilter == 'Online') {
        quickOk = event.mode.toLowerCase() == 'online';
      } else if (quickFilter == 'This Month') {
        quickOk = true;
      }

      final typeOk = selectedEventType == 'All' ||
          event.type.toLowerCase() == selectedEventType.toLowerCase();
      final modeOk = selectedMode == 'Any' ||
          event.mode.toLowerCase() == selectedMode.toLowerCase();
      final feeOk = selectedFee == 'Any' ||
          event.fee.toLowerCase().contains(selectedFee.toLowerCase());

      final queryOk = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.organizer.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.tags.any((t) => t.toLowerCase().contains(query));

      return quickOk && typeOk && modeOk && feeOk && queryOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const quickChips = ['For You', 'Nearby', 'Online', 'This Month'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Discover',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openFilters(context),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search events, programs, or projects...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: quickChips.map((item) {
                    final active = quickFilter == item;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item),
                        selected: active,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => quickFilter = item),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Text(
                    '${filtered.length} opportunities',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => _openFilters(context),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Filters'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _OpportunityGrid(
                events: filtered,
                savedEvents: widget.savedEvents,
                onOpenEvent: widget.onOpenEvent,
                onToggleSaved: widget.onToggleSaved,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MY PATH VIEW
// ============================================================

class MyPathView extends StatelessWidget {
  final ValueChanged<DemoOpportunity> onOpenEvent;

  const MyPathView({super.key, required this.onOpenEvent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Path',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),

              // Goal Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Goal',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 6),
                          Text(
                            'Perform strongly in AI Hackathons',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        fit: StackFit.expand,
                        children: const [
                          CircularProgressIndicator(
                            value: 0.68,
                            strokeWidth: 6,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                          Center(
                            child: Text(
                              '68%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Your Preparation Path',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),

              _PathStepTile(
                step: '1',
                title: 'Contribute to an API-based open source project',
                duration: '3–5 days',
                icon: Icons.code_rounded,
              ),
              const SizedBox(height: 12),
              _PathStepTile(
                step: '2',
                title:
                    'Complete one collaborative issue (GSSoC / Good First Issue)',
                duration: '5–7 days',
                icon: Icons.group_work_rounded,
              ),
              const SizedBox(height: 12),
              _PathStepTile(
                step: '3',
                title: 'Improve ScamShield AI prototype',
                duration: '5–7 days',
                icon: Icons.auto_awesome_rounded,
              ),
              const SizedBox(height: 12),
              _PathStepTile(
                step: '4',
                title: 'Re-run CampusPilot analysis',
                duration: '1 day',
                icon: Icons.refresh_rounded,
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up_rounded,
                        color: AppColors.success, size: 28),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expected Readiness',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        SizedBox(height: 2),
                        Text('68% → 85%',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Start Preparation Path'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathStepTile extends StatelessWidget {
  final String step;
  final String title;
  final String duration;
  final IconData icon;

  const _PathStepTile({
    required this.step,
    required this.title,
    required this.duration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: Text(step,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 3),
                Text(duration,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(icon, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}

// ============================================================
// TIMELINE VIEW
// ============================================================

class TimelineView extends StatelessWidget {
  final ValueChanged<DemoOpportunity> onOpenEvent;

  const TimelineView({super.key, required this.onOpenEvent});

  @override
  Widget build(BuildContext context) {
    const timelineItems = [
      ('Announcement', 'Completed', true),
      ('Project Applications', 'Completed', true),
      ('Mentor Applications Open', '12 Jan – 25 Jan', false),
      ('Participant Applications', '2 Feb – 18 Feb', false),
      ('Contributor Selection', '24 Feb', false),
      ('Contribution Period', '1 Mar – 31 May', false),
      ('Final Evaluation', 'June', false),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Program Timeline',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('GSSoC 2027 Milestone Roadmap',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ...List.generate(timelineItems.length, (index) {
                final item = timelineItems[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: item.$3
                              ? AppColors.success
                              : (index == 2
                                  ? AppColors.primary
                                  : const Color(0xFFCBD5E1)),
                          child: Icon(
                            item.$3
                                ? Icons.check_rounded
                                : Icons.circle_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        if (index < timelineItems.length - 1)
                          Container(
                              width: 2,
                              height: 38,
                              color: const Color(0xFFE2E8F0)),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(item.$2,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: item.$3
                                        ? AppColors.success
                                        : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SAVED VIEW
// ============================================================

class SavedView extends StatelessWidget {
  final Set<String> savedEvents;
  final ValueChanged<DemoOpportunity> onOpenEvent;
  final ValueChanged<DemoOpportunity> onToggleSaved;
  final VoidCallback onDiscover;

  const SavedView({
    super.key,
    required this.savedEvents,
    required this.onOpenEvent,
    required this.onToggleSaved,
    required this.onDiscover,
  });

  @override
  Widget build(BuildContext context) {
    final events =
        demoOpportunities.where((e) => savedEvents.contains(e.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Opportunities',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Keep track of bookmarked opportunities and programs.',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              if (events.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      children: [
                        const Icon(Icons.bookmark_border_rounded,
                            size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 14),
                        const Text('No saved opportunities yet',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        FilledButton(
                            onPressed: onDiscover,
                            child: const Text('Explore Opportunities')),
                      ],
                    ),
                  ),
                )
              else
                _OpportunityGrid(
                  events: events,
                  savedEvents: savedEvents,
                  onOpenEvent: onOpenEvent,
                  onToggleSaved: onToggleSaved,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE VIEW
// ============================================================

class ProfileView extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileView({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final profile = AppState.instance.profile;
    final user = FirebaseAuth.instance.currentUser;

    final name = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (user?.displayName ?? 'Mohan');
    final education = profile == null
        ? 'Profile incomplete'
        : '${profile.degree} • ${profile.department} • ${profile.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primarySoft,
                      foregroundColor: AppColors.primary,
                      child: Text(name.isEmpty ? 'M' : name[0].toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 22)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(user?.email ?? 'mohan@example.com',
                              style: const TextStyle(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(education,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    FilledButton(
                        onPressed: onEdit, child: const Text('Edit Profile')),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileCard(
                title: 'Interests & Skills',
                items: [
                  (
                    'Interests',
                    profile?.interests.join(', ') ??
                        'AI/ML, Web Development, Open Source'
                  ),
                  (
                    'Skills',
                    profile?.skills.join(', ') ??
                        'Flutter, Python, Java, Firebase, Git'
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _ProfileCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          const Divider(height: 1),
          ...items.map((row) => Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 120,
                        child: Text(row.$1,
                            style: const TextStyle(
                                color: AppColors.textSecondary))),
                    Expanded(
                        child: Text(row.$2,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ============================================================
// OPPORTUNITY GRID & CARDS
// ============================================================

class _OpportunityGrid extends StatelessWidget {
  final List<DemoOpportunity> events;
  final Set<String> savedEvents;
  final ValueChanged<DemoOpportunity> onOpenEvent;
  final ValueChanged<DemoOpportunity> onToggleSaved;

  const _OpportunityGrid({
    required this.events,
    required this.savedEvents,
    required this.onOpenEvent,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = 3;
        if (constraints.maxWidth < 1050) count = 2;
        if (constraints.maxWidth < 650) count = 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: count == 1 ? 1.25 : (count == 2 ? 0.92 : 0.88),
          ),
          itemBuilder: (context, index) {
            final event = events[index];
            return OpportunityCard(
              event: event,
              saved: savedEvents.contains(event.id),
              onOpen: () => onOpenEvent(event),
              onSaved: () => onToggleSaved(event),
            );
          },
        );
      },
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final DemoOpportunity event;
  final bool saved;
  final VoidCallback onOpen;
  final VoidCallback onSaved;

  const OpportunityCard({
    super.key,
    required this.event,
    required this.saved,
    required this.onOpen,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.categoryAccent(event.type);
    final surface = AppColors.categorySurface(event.type);
    final icon = AppColors.categoryIcon(event.type);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 19),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${event.match}% Fit',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onSaved,
                    icon: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: saved ? accent : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.type.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w900, height: 1.25),
              ),
              const SizedBox(height: 4),
              Text(
                event.organizer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: accent),
                  const SizedBox(width: 5),
                  Text(event.date,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_outlined, size: 14, color: accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${event.location} (${event.mode})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                children: event.tags.take(3).map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accent.withOpacity(0.15)),
                    ),
                    child: Text(tag,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EVENT DETAILS SCREEN
// ============================================================

class EventDetailsScreen extends StatefulWidget {
  final DemoOpportunity event;
  final bool initiallySaved;
  final ValueChanged<bool> onSavedChanged;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.initiallySaved,
    required this.onSavedChanged,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late bool saved;

  @override
  void initState() {
    super.initState();
    saved = widget.initiallySaved;
  }

  void _toggleSave() {
    setState(() {
      saved = !saved;
    });
    widget.onSavedChanged(saved);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final hasUrl = isValidOfficialUrl(event.officialUrl);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: [
          IconButton(
            onPressed: _toggleSave,
            icon: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: saved ? AppColors.primary : null),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(AppColors.categoryIcon(event.type),
                          color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.type.toUpperCase(),
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(event.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w900)),
                          Text(event.organizer,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${event.match}% Fit',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // AI Analysis Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Analysis',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 14),
                      const Text('Why this event for you:',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...event.reasons.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.success, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(r,
                                        style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                          )),
                      const Divider(height: 24),
                      const Text('Skill Gap Analysis',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 10),
                      _gapBar('REST API development (Developing)', 0.60),
                      const SizedBox(height: 8),
                      _gapBar('Team collaboration (Limited)', 0.50),
                      const SizedBox(height: 8),
                      _gapBar('Real AI project experience (Moderate)', 0.65),
                      const Divider(height: 24),
                      Row(
                        children: const [
                          Text('Competitive Readiness',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13)),
                          Spacer(),
                          Text('68% → 85%',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.success,
                                  fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Links
                if (event.sourceName.isNotEmpty) ...[
                  Text('Source: ${event.sourceName}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleSave,
                        icon: Icon(saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded),
                        label: Text(saved ? 'Saved' : 'Save'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: hasUrl
                            ? () => openOfficialEventPage(context,
                                url: event.officialUrl)
                            : null,
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: Text(hasUrl
                            ? 'Visit Official Page'
                            : 'Link Unavailable'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gapBar(String label, double value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const Spacer(),
              Text('${(value * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2E8F0),
                color: AppColors.primary),
          ),
        ],
      );
}

// ============================================================
// GENERAL UI COMPONENTS & DEMO DATA
// ============================================================

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onPressed;

  const _SectionHeading({
    required this.title,
    this.subtitle,
    this.action,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        if (action != null)
          TextButton(onPressed: onPressed, child: Text(action!)),
      ],
    );
  }
}

class DemoOpportunity {
  final String id;
  final String title;
  final String organizer;
  final String type;
  final String date;
  final String location;
  final String mode;
  final String fee;
  final String teamSize;
  final String deadline;
  final int match;
  final String reason;

  final List<String> tags;
  final List<String> reasons;

  final int classesAffected;
  final int labsAffected;
  final int leaveRequired;
  final String examConflict;
  final String impact;
  final String sourceName;
  final String sourceUrl;
  final String officialUrl;
  final String registrationUrl;
  final String contactDetails;
  final String schedule;

  const DemoOpportunity({
    required this.id,
    required this.title,
    required this.organizer,
    required this.type,
    required this.date,
    required this.location,
    required this.mode,
    required this.fee,
    required this.teamSize,
    required this.deadline,
    required this.match,
    required this.reason,
    required this.tags,
    required this.reasons,
    required this.classesAffected,
    required this.labsAffected,
    required this.leaveRequired,
    required this.examConflict,
    required this.impact,
    this.sourceName = '',
    this.sourceUrl = '',
    this.officialUrl = '',
    this.registrationUrl = '',
    this.contactDetails = '',
    this.schedule = '',
  });
}

const demoOpportunities = [
  DemoOpportunity(
    id: 'ai-hack-26',
    title: 'CodeGyaan\'26',
    organizer: 'M.O.P. Vaishnav College',
    type: 'Hackathon',
    date: '24–26 Sept',
    location: 'Chennai',
    mode: 'Online',
    fee: 'Free',
    teamSize: 'Team 3',
    deadline: '24 Sept',
    match: 92,
    reason: 'Matches your AI, Flutter and Python skills.',
    tags: ['AI', 'Web Dev', 'Innovation'],
    reasons: [
      'Matches your AI interest',
      'Relevant to your skills (Flutter, Python)',
      'Chennai location preference',
      'Eligible for your year',
    ],
    classesAffected: 3,
    labsAffected: 0,
    leaveRequired: 1,
    examConflict: 'None',
    impact: 'LOW',
  ),
  DemoOpportunity(
    id: 'gssoc-27',
    title: 'GSSoC 2027',
    organizer: 'GirlScript Foundation',
    type: 'Open Source Program',
    date: 'Opens in 12 days',
    location: 'Online',
    mode: 'Online',
    fee: 'Free',
    teamSize: 'Individual',
    deadline: '18 Jan',
    match: 91,
    reason: 'Participant Applications Open',
    tags: ['Open Source', 'Beginner', 'Community'],
    reasons: [
      'Top-rated open-source contributor program',
      'Matches your Git and Flutter interests',
      'No travel required',
    ],
    classesAffected: 0,
    labsAffected: 0,
    leaveRequired: 0,
    examConflict: 'None',
    impact: 'LOW',
  ),
  DemoOpportunity(
    id: 'flutter-south',
    title: 'Flutter South India',
    organizer: 'Namma Flutter',
    type: 'Workshop',
    date: '15 Oct',
    location: 'Chennai',
    mode: 'Offline',
    fee: 'Free',
    teamSize: 'Individual',
    deadline: '12 Oct',
    match: 87,
    reason: 'Directly matches your Flutter technical focus.',
    tags: ['Flutter', 'Dart', 'Mobile App'],
    reasons: [
      'Flutter community networking',
      'Matches mobile development skills',
    ],
    classesAffected: 2,
    labsAffected: 1,
    leaveRequired: 1,
    examConflict: 'None',
    impact: 'MODERATE',
  ),
];
