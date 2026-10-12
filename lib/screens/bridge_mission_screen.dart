import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BridgeMissionScreen extends StatefulWidget {
  final String projectName;
  final String issueTitle;
  final String skill;
  final String difficulty;
  final String estimatedTime;

  final String? repositoryUrl;
  final String? issueUrl;

  final VoidCallback? onOpenRepository;
  final VoidCallback? onOpenIssue;

  const BridgeMissionScreen({
    super.key,
    this.projectName = 'CampusConnect Open Source',
    this.issueTitle = 'Improve event filtering API and error handling',
    this.skill = 'REST API',
    this.difficulty = 'Beginner',
    this.estimatedTime = '3–5 hours',
    this.repositoryUrl,
    this.issueUrl,
    this.onOpenRepository,
    this.onOpenIssue,
  });

  @override
  State<BridgeMissionScreen> createState() => _BridgeMissionScreenState();
}

class _BridgeMissionScreenState extends State<BridgeMissionScreen> {
  final Set<int> completedSteps = {};

  bool missionStarted = false;
  bool addedToPath = false;

  final steps = const [
    ContributionStep(
      title: 'Understand the issue',
      description:
          'Read the issue description, expected behaviour and contribution notes.',
      icon: Icons.search_rounded,
    ),
    ContributionStep(
      title: 'Explore the repository',
      description:
          'Understand the project structure and locate the files related to the issue.',
      icon: Icons.folder_open_outlined,
    ),
    ContributionStep(
      title: 'Create your branch',
      description:
          'Work on a separate branch so your contribution remains clean and reviewable.',
      icon: Icons.account_tree_outlined,
    ),
    ContributionStep(
      title: 'Build and test the fix',
      description:
          'Implement the change and verify that the existing functionality still works.',
      icon: Icons.build_outlined,
    ),
    ContributionStep(
      title: 'Open a pull request',
      description:
          'Explain what you changed, why you changed it and how you tested it.',
      icon: Icons.merge_type_rounded,
    ),
  ];

  double get progress {
    if (steps.isEmpty) return 0;

    return completedSteps.length / steps.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bridge Mission',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Save mission',
            onPressed: () {
              setState(() {
                addedToPath = !addedToPath;
              });
            },
            icon: Icon(
              addedToPath
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: addedToPath ? AppColors.hue : AppColors.text,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            110,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _missionHero(),
                  const SizedBox(height: 22),
                  _whyRecommended(),
                  const SizedBox(height: 26),
                  _sectionHeading(
                    'Mission Details',
                    'Know what you are working on before you begin.',
                  ),
                  const SizedBox(height: 12),
                  _detailsCard(),
                  const SizedBox(height: 27),
                  _sectionHeading(
                    'Contribution Roadmap',
                    'Follow the real open-source workflow.',
                  ),
                  const SizedBox(height: 15),
                  ...steps.asMap().entries.map(
                    (entry) {
                      return _stepTile(
                        index: entry.key,
                        step: entry.value,
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  _sectionHeading(
                    'What counts as evidence?',
                    'CampusPilot values verifiable work more than quiz scores.',
                  ),
                  const SizedBox(height: 13),
                  _evidenceCard(),
                  const SizedBox(height: 24),
                  _readinessImpact(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomAction(),
    );
  }

  // =========================================================
  // HERO
  // =========================================================

  Widget _missionHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkShade,
            AppColors.shade,
            AppColors.tone,
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: AppColors.shade.withOpacity(.15),
            blurRadius: 25,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            bottom: -35,
            child: Icon(
              Icons.hub_outlined,
              size: 180,
              color: Colors.white.withOpacity(
                .05,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _heroBadge(
                    'OPEN SOURCE',
                    AppColors.tint,
                  ),
                  const SizedBox(width: 7),
                  _heroBadge(
                    widget.difficulty.toUpperCase(),
                    AppColors.antiqueBrass,
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: const Icon(
                      Icons.code_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),
              Text(
                widget.projectName,
                style: TextStyle(
                  color: AppColors.tint.withOpacity(.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.issueTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 17),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _darkMetaChip(
                    Icons.school_outlined,
                    widget.skill,
                  ),
                  _darkMetaChip(
                    Icons.schedule_outlined,
                    widget.estimatedTime,
                  ),
                  _darkMetaChip(
                    Icons.signal_cellular_alt_rounded,
                    widget.difficulty,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  99,
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white.withOpacity(.14),
                  color: AppColors.lichen,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    '${completedSteps.length}/${steps.length} steps',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 9.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.tint,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
      ),
    );
  }

  Widget _darkMetaChip(
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.tint,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(
                .82,
              ),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WHY RECOMMENDED
  // =========================================================

  Widget _whyRecommended() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.tint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.hue,
              borderRadius: BorderRadius.circular(
                13,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why CampusPilot picked this',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your target event needs ${widget.skill}. '
                  'This mission gives you a chance to practise it inside a real collaborative project instead of only completing another tutorial.',
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DETAILS
  // =========================================================

  Widget _detailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.code_rounded,
            'Project',
            widget.projectName,
            AppColors.smokedSlate,
          ),
          const Divider(
            height: 25,
            color: AppColors.border,
          ),
          _detailRow(
            Icons.task_alt_outlined,
            'Issue',
            widget.issueTitle,
            AppColors.hue,
          ),
          const Divider(
            height: 25,
            color: AppColors.border,
          ),
          _detailRow(
            Icons.school_outlined,
            'Skill',
            widget.skill,
            AppColors.lichen,
          ),
          const Divider(
            height: 25,
            color: AppColors.border,
          ),
          _detailRow(
            Icons.signal_cellular_alt_rounded,
            'Difficulty',
            widget.difficulty,
            AppColors.antiqueBrass,
          ),
          const Divider(
            height: 25,
            color: AppColors.border,
          ),
          _detailRow(
            Icons.schedule_outlined,
            'Time',
            widget.estimatedTime,
            AppColors.dustyRose,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 3,
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 2,
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ROADMAP
  // =========================================================

  Widget _stepTile({
    required int index,
    required ContributionStep step,
  }) {
    final complete = completedSteps.contains(index);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 41,
            child: Column(
              children: [
                Material(
                  color: complete ? AppColors.lichen : AppColors.hue,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      _toggleStep(index);
                    },
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: Center(
                        child: complete
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 17,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      color: complete
                          ? AppColors.lichen.withOpacity(.45)
                          : AppColors.tint,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 11,
              ),
              child: Material(
                color: complete ? AppColors.surfaceSoft : AppColors.surface,
                borderRadius: BorderRadius.circular(
                  16,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  hoverColor: AppColors.hoverSurface,
                  splashColor: AppColors.pressedSurface,
                  onTap: () {
                    _toggleStep(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(
                      13,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 41,
                          height: 41,
                          decoration: BoxDecoration(
                            color: _stepColor(
                              index,
                            ).withOpacity(
                              .10,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: Icon(
                            step.icon,
                            color: _stepColor(
                              index,
                            ),
                            size: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 11,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: TextStyle(
                                  color: complete
                                      ? AppColors.secondary
                                      : AppColors.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  decoration: complete
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                step.description,
                                style: const TextStyle(
                                  color: AppColors.textSoft,
                                  fontSize: 10.2,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Icon(
                          complete
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          color: complete ? AppColors.lichen : AppColors.hue,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _stepColor(int index) {
    const colors = [
      AppColors.smokedSlate,
      AppColors.antiqueBrass,
      AppColors.hue,
      AppColors.dustyRose,
      AppColors.lichen,
    ];

    return colors[index % colors.length];
  }

  void _toggleStep(int index) {
    setState(() {
      if (completedSteps.contains(index)) {
        completedSteps.remove(index);
      } else {
        completedSteps.add(index);
      }
    });
  }

  // =========================================================
  // EVIDENCE
  // =========================================================

  Widget _evidenceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          _EvidenceRow(
            icon: Icons.merge_type_rounded,
            title: 'Pull request',
            subtitle: 'A PR showing the work you contributed.',
            color: AppColors.hue,
          ),
          Divider(
            height: 24,
            color: AppColors.border,
          ),
          _EvidenceRow(
            icon: Icons.rate_review_outlined,
            title: 'Maintainer review',
            subtitle: 'Feedback or approval from another contributor.',
            color: AppColors.antiqueBrass,
          ),
          Divider(
            height: 24,
            color: AppColors.border,
          ),
          _EvidenceRow(
            icon: Icons.verified_outlined,
            title: 'Merged contribution',
            subtitle: 'Strong evidence that your contribution was accepted.',
            color: AppColors.lichen,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // READINESS IMPACT
  // =========================================================

  Widget _readinessImpact() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.focusSurface,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: AppColors.antiqueBrass.withOpacity(.22),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    value: .70,
                    strokeWidth: 6,
                    backgroundColor: AppColors.tint,
                    color: AppColors.lichen,
                  ),
                ),
                const Text(
                  '+6',
                  style: TextStyle(
                    color: AppColors.lichen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Potential readiness impact',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Completing and verifying this mission could strengthen your ${widget.skill} evidence.',
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'This is an evidence signal, not a guarantee of event success.',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM ACTION
  // =========================================================

  Widget _bottomAction() {
    final hasVerifiedIssue =
        widget.issueUrl != null && widget.issueUrl!.trim().isNotEmpty;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          9,
          18,
          12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            Material(
              color: addedToPath
                  ? AppColors.navSelectedSurface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(
                16,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                hoverColor: AppColors.hoverSurface,
                splashColor: AppColors.pressedSurface,
                onTap: () {
                  setState(() {
                    addedToPath = !addedToPath;
                  });
                },
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: Icon(
                    addedToPath
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_add_outlined,
                    color: AppColors.hue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: hasVerifiedIssue
                    ? () {
                        setState(() {
                          missionStarted = true;
                        });

                        if (widget.onOpenIssue != null) {
                          widget.onOpenIssue!();
                        }
                      }
                    : null,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                    const Size(
                      0,
                      54,
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) {
                      if (states.contains(
                        WidgetState.disabled,
                      )) {
                        return AppColors.tone.withOpacity(
                          .45,
                        );
                      }

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
                  overlayColor: WidgetStateProperty.all(
                    AppColors.tint.withOpacity(
                      .18,
                    ),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
                icon: Icon(
                  missionStarted
                      ? Icons.open_in_new_rounded
                      : Icons.rocket_launch_outlined,
                  color: Colors.white,
                ),
                label: Text(
                  hasVerifiedIssue
                      ? missionStarted
                          ? 'Open Issue'
                          : 'Start Bridge Mission'
                      : 'Issue Link Unavailable',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 10.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// SMALL WIDGETS / MODELS
// =============================================================

class ContributionStep {
  final String title;
  final String description;
  final IconData icon;

  const ContributionStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _EvidenceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EvidenceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 19,
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
