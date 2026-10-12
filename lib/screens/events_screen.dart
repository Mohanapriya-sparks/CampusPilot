import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/campus_pilot_logo.dart';
import 'event_details_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final searchController = TextEditingController();

  String selectedCategory = 'All';

  final categories = const [
    'All',
    'Hackathons',
    'Workshops',
    'Competitions',
    'Open Source',
  ];

  final events = const [
    EventUiData(
      type: 'Hackathon',
      title: 'Smart India Hackathon 2026',
      organizer: 'Ministry of Education',
      date: 'Nov 14 – 16, 2026',
      location: 'National',
      mode: 'Hybrid',
      description: 'Solve real-world problems and build innovative solutions.',
      tags: ['AI/ML', 'Web Dev', 'Problem Solving'],
      featured: true,
      fit: 92,
    ),
    EventUiData(
      type: 'Open Source',
      title: 'GirlScript Summer of Code',
      organizer: 'GirlScript Foundation',
      date: 'Applications open soon',
      location: 'India',
      mode: 'Remote',
      description: 'Contribute to open source and build your portfolio.',
      tags: ['Open Source', 'Git', 'Collaboration'],
      fit: 88,
    ),
    EventUiData(
      type: 'Workshop',
      title: 'Flutter App Development Bootcamp',
      organizer: 'Developer Community',
      date: 'Oct 19, 2026',
      location: 'Chennai',
      mode: 'Offline',
      description:
          'Hands-on Flutter workshop covering UI, Firebase and deployment.',
      tags: ['Flutter', 'Firebase', 'Mobile'],
      fit: 84,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<EventUiData> get filteredEvents {
    final query = searchController.text.trim().toLowerCase();

    return events.where((event) {
      final searchMatch = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.organizer.toLowerCase().contains(query) ||
          event.tags.any(
            (tag) => tag.toLowerCase().contains(query),
          );

      final categoryMatch = selectedCategory == 'All' ||
          event.type == selectedCategory ||
          (selectedCategory == 'Hackathons' && event.type == 'Hackathon') ||
          (selectedCategory == 'Workshops' && event.type == 'Workshop');

      return searchMatch && categoryMatch;
    }).toList();
  }

  void openEvent(EventUiData event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          title: event.title,
          organizer: event.organizer,
          type: event.type,
          date: event.date,
          location: event.location,
          mode: event.mode,
          description: event.description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CampusPilotLogo(
          height: 34,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.tint,
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: AppColors.hue,
              ),
            ),
          ),
          const SizedBox(width: 7),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore Opportunities',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hackathons, workshops, competitions and open-source opportunities for students.',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 17),
                  TextField(
                    controller: searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search events, skills, organisations...',
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: Icon(Icons.tune_rounded),
                    ),
                  ),
                  const SizedBox(height: 13),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map(
                        (category) {
                          final selected = selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                            ),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: selected,
                              showCheckmark: false,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...filteredEvents.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _EventCard(
                        event: event,
                        onTap: () => openEvent(event),
                      ),
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.darkShade,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                24,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CampusPilotLogo(
                  height: 42,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.event_rounded,
              label: 'Events',
              selected: true,
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.code_rounded,
              label: 'Open Source',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.alt_route_rounded,
              label: 'Preparation Path',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.bookmark_border_rounded,
              label: 'Saved',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {},
            ),
            const Spacer(),
            const Divider(
              color: Colors.white12,
              indent: 20,
              endIndent: 20,
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventUiData event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _badge(event.type),
                  if (event.featured) ...[
                    const SizedBox(width: 6),
                    _badge(
                      'Featured',
                      pale: true,
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(
                        99,
                      ),
                    ),
                    child: Text(
                      '${event.fit}% Fit',
                      style: const TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.bookmark_border_rounded,
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                event.organizer,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _meta(
                    Icons.calendar_today_outlined,
                    event.date,
                  ),
                  _meta(
                    Icons.location_on_outlined,
                    event.location,
                  ),
                  _meta(
                    Icons.language_outlined,
                    event.mode,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.description,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: event.tags.map(
                  (tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(
                          99,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.shade,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 42),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(
    String value, {
    bool pale = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: pale ? AppColors.lightTint : AppColors.tint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.hue,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
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
          size: 13,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 3,
      ),
      child: Material(
        color: selected
            ? AppColors.dustyRose.withOpacity(.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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

class EventUiData {
  final String type;
  final String title;
  final String organizer;
  final String date;
  final String location;
  final String mode;
  final String description;
  final List<String> tags;
  final bool featured;
  final int fit;

  const EventUiData({
    required this.type,
    required this.title,
    required this.organizer,
    required this.date,
    required this.location,
    required this.mode,
    required this.description,
    required this.tags,
    required this.fit,
    this.featured = false,
  });
}
