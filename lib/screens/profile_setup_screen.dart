import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/student_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/campus_card.dart';
import 'events_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool editing;

  const ProfileSetupScreen({
    super.key,
    this.editing = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0;
  bool _saving = false;

  final nameController = TextEditingController();
  final cityController = TextEditingController(text: 'Chennai');
  final stateController = TextEditingController(text: 'Tamil Nadu');

  final collegeController = TextEditingController();
  final degreeController = TextEditingController();
  final departmentController = TextEditingController();
  final yearController = TextEditingController(text: '3rd Year');

  final selectedSkills = <String>{'Flutter', 'Python', 'Git'};
  final selectedInterests = <String>{'AI/ML', 'Open Source', 'Mobile App'};
  final selectedEventTypes = <String>{'Hackathons', 'Open Source Programs'};

  bool githubConnected = false;
  bool linkedinConnected = false;

  final _steps = const [
    'About You',
    'Education',
    'Skills',
    'Interests',
    'Preferences',
  ];

  @override
  void initState() {
    super.initState();

    final profile = AppState.instance.profile;
    final user = FirebaseAuth.instance.currentUser;

    nameController.text = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : (user?.displayName ?? 'Mohan');

    if (profile != null) {
      cityController.text = profile.city.isNotEmpty ? profile.city : 'Chennai';
      stateController.text =
          profile.state.isNotEmpty ? profile.state : 'Tamil Nadu';
      collegeController.text = profile.college;
      degreeController.text = profile.degree;
      departmentController.text = profile.department;
      yearController.text = profile.year.isNotEmpty ? profile.year : '3rd Year';

      selectedSkills.addAll(profile.skills);
      selectedInterests.addAll(profile.interests);
      selectedEventTypes.addAll(profile.preferredEventTypes);
      githubConnected = profile.github.isNotEmpty;
      linkedinConnected = profile.linkedin.isNotEmpty;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    stateController.dispose();
    collegeController.dispose();
    degreeController.dispose();
    departmentController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileAndFinish() async {
    setState(() => _saving = true);

    final current = AppState.instance.profile ?? StudentProfile();
    current.fullName = nameController.text.trim();
    current.city = cityController.text.trim();
    current.state = stateController.text.trim();
    current.college = collegeController.text.trim();
    current.degree = degreeController.text.trim();
    current.department = departmentController.text.trim();
    current.year = yearController.text.trim();
    current.skills = selectedSkills.toList();
    current.interests = selectedInterests.toList();
    current.preferredEventTypes = selectedEventTypes.toList();
    current.github = githubConnected ? 'https://github.com/user' : '';
    current.linkedin = linkedinConnected ? 'https://linkedin.com/in/user' : '';

    await AppState.instance.saveProfile(current);

    if (!mounted) return;
    setState(() => _saving = false);

    if (widget.editing) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => EventsScreen()),
      );
    }
  }

  void _next() {
    if (_step == _steps.length - 1) {
      _saveProfileAndFinish();
      return;
    }

    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.editing,
        title: Text(widget.editing ? 'Edit profile' : 'Profile setup'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_step + 1}/${_steps.length}',
                style: const TextStyle(
                  color: AppColors.hue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / _steps.length,
              minHeight: 4,
              backgroundColor: AppColors.tint,
              color: AppColors.hue,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildStep(),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                child: Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('Back'),
                      ),
                    if (_step > 0) const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _next,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _step == _steps.length - 1
                                    ? widget.editing
                                        ? 'Save Changes'
                                        : 'Finish Setup'
                                    : 'Next  →',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _section(
          key: const ValueKey(0),
          title: "Let's set up your profile",
          subtitle: 'This helps CampusPilot give better recommendations.',
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stateController,
              decoration: const InputDecoration(labelText: 'State'),
            ),
          ],
        );

      case 1:
        return _section(
          key: const ValueKey(1),
          title: 'Academic details',
          subtitle: 'Used for eligibility, year filters and academic fit.',
          children: [
            TextField(
              controller: collegeController,
              decoration: const InputDecoration(labelText: 'College'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: degreeController,
              decoration: const InputDecoration(labelText: 'Degree'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Year / Semester'),
            ),
          ],
        );

      case 2:
        return _choiceSection(
          key: const ValueKey(2),
          title: 'Your Skills',
          subtitle:
              'Select what you already know. CampusPilot will later look for evidence.',
          values: const [
            'Flutter',
            'Python',
            'Java',
            'C++',
            'Firebase',
            'Git',
            'REST API',
            'HTML/CSS',
            'AI/ML',
          ],
          selected: selectedSkills,
        );

      case 3:
        return _choiceSection(
          key: const ValueKey(3),
          title: 'Your Interests',
          subtitle: 'Choose at least three to improve matching.',
          values: const [
            'AI/ML',
            'Web Development',
            'Mobile App',
            'Open Source',
            'Cybersecurity',
            'IoT',
            'Data Science',
            'UI/UX',
            'Robotics',
          ],
          selected: selectedInterests,
        );

      default:
        return _section(
          key: const ValueKey(4),
          title: 'Preferences & accounts',
          subtitle: 'Tell CampusPilot what opportunities to prioritize.',
          children: [
            const Text(
              'Opportunity types',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Hackathons',
                'Open Source Programs',
                'Workshops',
                'Competitions',
                'Meetups',
              ].map((value) {
                return FilterChip(
                  label: Text(value),
                  selected: selectedEventTypes.contains(value),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedEventTypes.add(value);
                      } else {
                        selectedEventTypes.remove(value);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            CampusCard(
              color: AppColors.lightTint,
              borderColor: AppColors.tint,
              child: Column(
                children: [
                  _accountRow(
                    'GitHub',
                    Icons.code_rounded,
                    githubConnected,
                    () => setState(
                      () => githubConnected = !githubConnected,
                    ),
                  ),
                  const Divider(height: 22),
                  _accountRow(
                    'LinkedIn',
                    Icons.business_center_outlined,
                    linkedinConnected,
                    () => setState(
                      () => linkedinConnected = !linkedinConnected,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _accountRow(
    String label,
    IconData icon,
    bool connected,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.hue, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(connected ? 'Connected' : 'Connect'),
        ),
      ],
    );
  }

  Widget _section({
    required Key key,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSoft,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _choiceSection({
    required Key key,
    required String title,
    required String subtitle,
    required List<String> values,
    required Set<String> selected,
  }) {
    return _section(
      key: key,
      title: title,
      subtitle: subtitle,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            return FilterChip(
              label: Text(value),
              selected: selected.contains(value),
              onSelected: (on) {
                setState(() {
                  if (on) {
                    selected.add(value);
                  } else {
                    selected.remove(value);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
