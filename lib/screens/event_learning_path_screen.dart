import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EventLearningPathScreen extends StatefulWidget {
  final String eventTitle;
  final List<String> missingSkills;
  final int currentReadiness;

  const EventLearningPathScreen({
    super.key,
    required this.eventTitle,
    required this.missingSkills,
    required this.currentReadiness,
  });

  @override
  State<EventLearningPathScreen> createState() =>
      _EventLearningPathScreenState();
}

class _EventLearningPathScreenState extends State<EventLearningPathScreen> {
  int? selectedStep;

  String get primarySkill {
    if (widget.missingSkills.isNotEmpty) {
      return widget.missingSkills.first;
    }

    return 'Flutter';
  }

  String get secondarySkill {
    if (widget.missingSkills.length > 1) {
      return widget.missingSkills[1];
    }

    return 'Problem Solving';
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

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
                _topBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      4,
                      18,
                      18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _pageHeading(),
                        const SizedBox(height: 18),
                        for (int i = 0; i < steps.length; i++)
                          _timelineItem(
                            index: i,
                            step: steps[i],
                            isLast: i == steps.length - 1,
                          ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomButton(),
    );
  }

  // ---------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        10,
        5,
        13,
        4,
      ),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              height: 23,
              width: 96,
              child: Image.asset(
                'assets/images/campuspilot_logo.png',
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'CampusPilot',
                    style: TextStyle(
                      color: AppColors.shade,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 7,
                  top: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.hue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // PAGE TITLE
  // ---------------------------------------------------------

  Widget _pageHeading() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Preparation Path',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.45,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'A personalized plan to help you fill skill gaps\n'
                'and get ready for ${widget.eventTitle}.',
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 10.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 2,
          top: -4,
          child: Transform.rotate(
            angle: -.09,
            child: Column(
              children: [
                const Text(
                  'Small\nsteps,\nbig\nopportunities!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.tone,
                    fontSize: 8,
                    height: 1.05,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Transform.rotate(
                  angle: .55,
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    size: 12,
                    color: AppColors.tone,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // DATA
  // ---------------------------------------------------------

  List<_PathStep> _buildSteps() {
    return [
      _PathStep(
        number: 1,
        icon: Icons.code_rounded,
        title: 'Strengthen $primarySkill Basics',
        description: 'Complete hands-on tutorials and build a mini project.',
        duration: '3–5 days',
        accent: AppColors.hue,
        resource: _LearningResource(
          title: _primaryResourceTitle(),
          type: 'Tutorial',
          meta: '20 min',
          thumbnailType: _ResourceThumbnailType.video,
        ),
      ),
      _PathStep(
        number: 2,
        icon: Icons.lightbulb_outline_rounded,
        title: 'Practice $secondarySkill',
        description: 'Solve curated problems from real hackathons.',
        duration: '2 weeks',
        accent: AppColors.antiqueBrass,
        resource: const _LearningResource(
          title: '50 DSA Problems for Interviews',
          type: 'Practice',
          meta: 'Medium',
          thumbnailType: _ResourceThumbnailType.practice,
        ),
      ),
      _PathStep(
        number: 3,
        icon: Icons.code_rounded,
        title: 'Contribute to Open Source',
        description:
            'Make meaningful contributions to build your GitHub profile.',
        duration: '1–2 weeks',
        accent: AppColors.hue,
        resource: const _LearningResource(
          title: 'Good First Issues for Students',
          type: 'Open Source',
          meta: 'Beginner',
          thumbnailType: _ResourceThumbnailType.github,
        ),
      ),
      _PathStep(
        number: 4,
        icon: Icons.groups_rounded,
        title: 'Join a Community',
        description: 'Connect with peers, find a team, and get mentorship.',
        duration: 'Ongoing',
        accent: AppColors.dustyRose,
        resource: _LearningResource(
          title: _communityTitle(),
          type: 'Community',
          meta: '2.4K members',
          thumbnailType: _ResourceThumbnailType.community,
        ),
      ),
    ];
  }

  String _primaryResourceTitle() {
    final normalized = primarySkill.toLowerCase();

    if (normalized.contains('flutter')) {
      return 'Build a Flutter Notes App';
    }

    if (normalized.contains('machine') || normalized.contains('ai')) {
      return 'Build a Mini AI Project';
    }

    if (normalized.contains('ui') || normalized.contains('ux')) {
      return 'Design a Mobile UI Project';
    }

    if (normalized.contains('firebase')) {
      return 'Build with Firebase';
    }

    return 'Build a $primarySkill Mini Project';
  }

  String _communityTitle() {
    if (widget.eventTitle.toLowerCase().contains('treehack')) {
      return 'Stanford TreeHacks Discord';
    }

    return '${widget.eventTitle} Community';
  }

  // ---------------------------------------------------------
  // TIMELINE
  // ---------------------------------------------------------

  Widget _timelineItem({
    required int index,
    required _PathStep step,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 29,
            child: Column(
              children: [
                _numberCircle(step.number),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _stepCard(
                index: index,
                step: step,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberCircle(int number) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.hue,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP CARD
  // ---------------------------------------------------------

  Widget _stepCard({
    required int index,
    required _PathStep step,
  }) {
    final selected = selectedStep == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? AppColors.lightTint : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? AppColors.dustyRose.withOpacity(.45)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkShade.withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  step.icon,
                  color: step.accent,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 11.5,
                        height: 1.16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      step.description,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 8.5,
                        height: 1.32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              _durationChip(
                step.duration,
              ),
            ],
          ),
          const SizedBox(height: 9),
          _resourceTile(
            index: index,
            step: step,
          ),
        ],
      ),
    );
  }

  Widget _durationChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightTint,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.hue,
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // RESOURCE
  // ---------------------------------------------------------

  Widget _resourceTile({
    required int index,
    required _PathStep step,
  }) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _openPreparationAction(
            index: index,
            step: step,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              _resourceThumbnail(
                step.resource.thumbnailType,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.resource.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _resourceTag(
                          step.resource.type,
                        ),
                        Container(
                          width: 2.5,
                          height: 2.5,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          step.resource.meta,
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 7.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.open_in_new_rounded,
                size: 13,
                color: AppColors.hue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resourceTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.hue,
          fontSize: 6.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _resourceThumbnail(
    _ResourceThumbnailType type,
  ) {
    switch (type) {
      case _ResourceThumbnailType.video:
        return Container(
          width: 53,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF211D20),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 7,
                right: 7,
                bottom: 6,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dustyRose.withOpacity(.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Container(
                width: 19,
                height: 19,
                decoration: const BoxDecoration(
                  color: AppColors.hue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case _ResourceThumbnailType.practice:
        return Container(
          width: 53,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE9DDD4),
                Color(0xFFCAB8AE),
              ],
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Icon(
            Icons.laptop_mac_rounded,
            size: 22,
            color: AppColors.textSoft,
          ),
        );

      case _ResourceThumbnailType.github:
        return Container(
          width: 53,
          height: 34,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1D28),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Image.asset(
            'assets/images/social/github.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.code_rounded,
                color: Colors.white,
              );
            },
          ),
        );

      case _ResourceThumbnailType.community:
        return ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            width: 53,
            height: 34,
            child: Image.asset(
              'assets/images/events/treehacks_banner.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.lightTint,
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.hue,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        );
    }
  }

  // ---------------------------------------------------------
  // BOTTOM BUTTON
  // ---------------------------------------------------------

  Widget _bottomButton() {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          10,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 410,
            ),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: _beginPreparation,
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.hue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Begin Preparation',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _beginPreparation() {
    final steps = _buildSteps();

    setState(() {
      selectedStep = 0;
    });

    _openPreparationAction(
      index: 0,
      step: steps.first,
    );
  }

  void _openPreparationAction({
    required int index,
    required _PathStep step,
  }) {
    setState(() {
      selectedStep = index;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PreparationActionScreen(
          stepNumber: step.number,
          eventTitle: widget.eventTitle,
          title: step.title,
          description: step.description,
          duration: step.duration,
          resourceTitle: step.resource.title,
          resourceType: step.resource.type,
          resourceMeta: step.resource.meta,
          accent: step.accent,
        ),
      ),
    );
  }
}

class _PreparationActionScreen extends StatefulWidget {
  final int stepNumber;
  final String eventTitle;
  final String title;
  final String description;
  final String duration;
  final String resourceTitle;
  final String resourceType;
  final String resourceMeta;
  final Color accent;

  const _PreparationActionScreen({
    required this.stepNumber,
    required this.eventTitle,
    required this.title,
    required this.description,
    required this.duration,
    required this.resourceTitle,
    required this.resourceType,
    required this.resourceMeta,
    required this.accent,
  });

  @override
  State<_PreparationActionScreen> createState() =>
      _PreparationActionScreenState();
}

class _PreparationActionScreenState extends State<_PreparationActionScreen> {
  bool started = false;
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Preparation Step ${widget.stepNumber}',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(.10),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          widget.duration,
                          style: TextStyle(
                            color: widget.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'For ${widget.eventTitle}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _resourceIcon(widget.stepNumber),
                          color: widget.accent,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resourceTitle,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.resourceType} • ${widget.resourceMeta}',
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: completed
                      ? null
                      : () {
                          setState(() {
                            started = true;
                          });

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ActivePreparationScreen(
                                stepNumber: widget.stepNumber,
                                eventTitle: widget.eventTitle,
                                title: widget.title,
                                resourceTitle: widget.resourceTitle,
                                resourceType: widget.resourceType,
                                accent: widget.accent,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    started ? 'Continue Preparation' : 'Start This Step',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.hue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      started = true;
                      completed = !completed;
                    });
                  },
                  icon: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    completed ? 'Completed' : 'Mark as Completed',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.hue,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                if (started) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightTint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      completed
                          ? 'Step completed. You can return to your preparation path.'
                          : 'This step is now active. Complete the resource and mark it finished when you are done.',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _resourceIcon(int step) {
    switch (step) {
      case 1:
        return Icons.school_outlined;
      case 2:
        return Icons.psychology_alt_outlined;
      case 3:
        return Icons.code_rounded;
      case 4:
        return Icons.groups_rounded;
      default:
        return Icons.route_rounded;
    }
  }
}

class _ActivePreparationScreen extends StatefulWidget {
  final int stepNumber;
  final String eventTitle;
  final String title;
  final String resourceTitle;
  final String resourceType;
  final Color accent;

  const _ActivePreparationScreen({
    required this.stepNumber,
    required this.eventTitle,
    required this.title,
    required this.resourceTitle,
    required this.resourceType,
    required this.accent,
  });

  @override
  State<_ActivePreparationScreen> createState() =>
      _ActivePreparationScreenState();
}

class _ActivePreparationScreenState extends State<_ActivePreparationScreen> {
  final Set<int> completedTasks = <int>{};

  List<String> get tasks {
    switch (widget.stepNumber) {
      case 1:
        return [
          'Review the core concepts for this skill.',
          'Complete the recommended learning resource.',
          'Build one small practice project.',
        ];
      case 2:
        return [
          'Review the problem-solving approach.',
          'Complete a focused practice set.',
          'Retry the problems you found difficult.',
        ];
      case 3:
        return [
          'Choose a beginner-friendly open-source issue.',
          'Read the repository contribution guide.',
          'Make and test a small contribution.',
          'Prepare your pull request.',
        ];
      case 4:
        return [
          'Join the recommended community.',
          'Introduce yourself and your interests.',
          'Find teammates, mentors, or useful discussions.',
        ];
      default:
        return [
          'Open the recommended resource.',
          'Complete the learning activity.',
          'Mark the step as finished.',
        ];
    }
  }

  double get progress =>
      tasks.isEmpty ? 0 : completedTasks.length / tasks.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Step ${widget.stepNumber} • Active',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'For ${widget.eventTitle}',
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: widget.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resourceTitle,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.resourceType,
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progress,
                    backgroundColor: AppColors.surfaceSoft,
                    color: AppColors.hue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${completedTasks.length}/${tasks.length} tasks completed',
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                ...List.generate(
                  tasks.length,
                  (index) {
                    final done = completedTasks.contains(index);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: CheckboxListTile(
                        value: done,
                        activeColor: AppColors.hue,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          tasks[index],
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight:
                                done ? FontWeight.w700 : FontWeight.w600,
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            if (done) {
                              completedTasks.remove(index);
                            } else {
                              completedTasks.add(index);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: completedTasks.length == tasks.length
                      ? () {
                          Navigator.pop(context, true);
                        }
                      : null,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Finish This Step'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.hue,
                    foregroundColor: Colors.white,
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

// ===========================================================
// LOCAL MODELS
// ===========================================================

class _PathStep {
  final int number;
  final IconData icon;
  final String title;
  final String description;
  final String duration;
  final Color accent;
  final _LearningResource resource;

  const _PathStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.duration,
    required this.accent,
    required this.resource,
  });
}

class _LearningResource {
  final String title;
  final String type;
  final String meta;
  final _ResourceThumbnailType thumbnailType;

  const _LearningResource({
    required this.title,
    required this.type,
    required this.meta,
    required this.thumbnailType,
  });
}

enum _ResourceThumbnailType {
  video,
  practice,
  github,
  community,
}
