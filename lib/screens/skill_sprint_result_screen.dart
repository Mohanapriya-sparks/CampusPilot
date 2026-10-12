import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'event_learning_path_screen.dart';

class SkillSprintResultScreen extends StatelessWidget {
  final String eventTitle;
  final int correctAnswers;
  final int totalChallenges;
  final int score;
  final Map<String, bool> skillResults;
  final int previousReadiness;

  const SkillSprintResultScreen({
    super.key,
    required this.eventTitle,
    required this.correctAnswers,
    required this.totalChallenges,
    required this.score,
    required this.skillResults,
    required this.previousReadiness,
  });

  // ============================================================
  // READINESS
  // ============================================================

  int get readiness {
    final improvement = (correctAnswers * 2).clamp(0, 10).toInt();

    return (previousReadiness + improvement).clamp(0, 95).toInt();
  }

  double get sprintAccuracy {
    if (totalChallenges == 0) {
      return 0;
    }

    return correctAnswers / totalChallenges;
  }

  // ============================================================
  // SKILL BREAKDOWN
  // ============================================================

  List<_SkillResultItem> get _breakdown {
    final flutterBasics = skillResults['Flutter Basics'] ?? false;

    final flutterUi = skillResults['Flutter UI'] ?? false;

    final github = skillResults['GitHub'] ?? false;

    final problem = skillResults['Problem Solving'] ?? false;

    final teamwork = skillResults['Teamwork'] ?? false;

    return [
      _SkillResultItem(
        title: 'Flutter Development',
        icon: Icons.flutter_dash_rounded,
        value: flutterBasics && flutterUi
            ? .92
            : flutterBasics || flutterUi
                ? .64
                : .34,
        requiredValue: .80,
        status: flutterBasics && flutterUi
            ? _ResultStatus.strong
            : _ResultStatus.partial,
      ),
      _SkillResultItem(
        title: 'Problem Solving',
        icon: Icons.auto_awesome_outlined,
        value: problem ? .65 : .39,
        requiredValue: .82,
        status: problem ? _ResultStatus.partial : _ResultStatus.missing,
      ),
      _SkillResultItem(
        title: 'Git & GitHub',
        icon: Icons.account_tree_outlined,
        value: github ? .68 : .36,
        requiredValue: .77,
        status: github ? _ResultStatus.partial : _ResultStatus.missing,
      ),
      _SkillResultItem(
        title: 'Team Collaboration',
        icon: Icons.groups_outlined,
        value: teamwork ? .59 : .31,
        requiredValue: .72,
        status: teamwork ? _ResultStatus.partial : _ResultStatus.missing,
      ),
      _SkillResultItem(
        title: 'UI/UX Design',
        icon: Icons.palette_outlined,
        value: flutterUi ? .48 : .27,
        requiredValue: .67,
        status: flutterUi ? _ResultStatus.partial : _ResultStatus.missing,
      ),
    ];
  }

  int get strongCount => _breakdown
      .where(
        (item) => item.status == _ResultStatus.strong,
      )
      .length;

  int get partialCount => _breakdown
      .where(
        (item) => item.status == _ResultStatus.partial,
      )
      .length;

  int get missingCount => _breakdown
      .where(
        (item) => item.status == _ResultStatus.missing,
      )
      .length;

  List<String> get missingSkills => _breakdown
      .where(
        (item) => item.status != _ResultStatus.strong,
      )
      .map((item) => item.title)
      .toList();

  // ============================================================
  // BUILD
  // ============================================================

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
                _topBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      2,
                      15,
                      22,
                    ),
                    child: Column(
                      children: [
                        _completionHeader(),
                        const SizedBox(height: 11),
                        _readinessCard(),
                        const SizedBox(height: 9),
                        _summaryRow(),
                        const SizedBox(height: 10),
                        _skillBreakdown(),
                        const SizedBox(height: 10),
                        _insightCard(context),
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

  Widget _topBar(
    BuildContext context,
  ) {
    return SizedBox(
      height: 49,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 19,
              color: AppColors.text,
            ),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Φ',
                  style: TextStyle(
                    color: AppColors.hue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'CampusPilot',
                  style: TextStyle(
                    color: AppColors.shade,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Result sharing will be available later.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.ios_share_outlined,
              size: 19,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPLETION HEADER
  // ============================================================

  Widget _completionHeader() {
    return Column(
      children: [
        SizedBox(
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _confetti(
                left: 52,
                top: 11,
                color: AppColors.dustyRose,
              ),
              _confetti(
                left: 83,
                top: 3,
                color: AppColors.antiqueBrass,
              ),
              _confetti(
                right: 51,
                top: 9,
                color: AppColors.lichen,
              ),
              _confetti(
                right: 83,
                bottom: 4,
                color: AppColors.hue,
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.antiqueBrass.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.antiqueBrass,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Skill Sprint Complete!',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -.35,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Here\'s how you performed for this event.',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  Widget _confetti({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: .65,
        child: Container(
          width: 3,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // READINESS HERO CARD
  // ============================================================

  Widget _readinessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: CustomPaint(
              painter: _ReadinessRingPainter(
                value: readiness / 100,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$readiness%',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 25,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Event Readiness',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Great potential!',
                  style: TextStyle(
                    color: AppColors.lichen,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'You have a strong foundation. '
                  'A few key skills will help you '
                  'become more prepared.',
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 8.3,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightTint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$correctAnswers / $totalChallenges correct',
                    style: const TextStyle(
                      color: AppColors.hue,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
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
  // SUMMARY
  // ============================================================

  Widget _summaryRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _miniSummaryCard(
            title: 'Your Skills',
            values: [
              _SummaryItem(
                color: AppColors.lichen,
                value: strongCount,
                label: 'Strong',
              ),
              _SummaryItem(
                color: AppColors.antiqueBrass,
                value: partialCount,
                label: 'Partial',
              ),
              _SummaryItem(
                color: AppColors.dustyCoral,
                value: missingCount,
                label: 'Missing',
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _miniSummaryCard(
            title: 'Event Requirements',
            values: const [
              _SummaryItem(
                color: AppColors.lichen,
                value: 5,
                label: 'Required',
              ),
              _SummaryItem(
                color: AppColors.antiqueBrass,
                value: 2,
                label: 'Nice to have',
              ),
              _SummaryItem(
                color: AppColors.dustyCoral,
                value: 1,
                label: 'Optional',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniSummaryCard({
    required String title,
    required List<_SummaryItem> values,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        10,
        9,
        10,
        7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 9.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          ...values.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 14,
                    child: Text(
                      '${item.value}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 7.3,
                      ),
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

  // ============================================================
  // SKILL BREAKDOWN CARD
  // ============================================================

  Widget _skillBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        11,
        10,
        11,
        9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Skill Breakdown',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              _legend(
                AppColors.hue,
                'Your level',
              ),
              const SizedBox(width: 7),
              _legend(
                AppColors.tint,
                'Required level',
              ),
            ],
          ),
          const SizedBox(height: 11),
          ..._breakdown.map(_skillRow),
        ],
      ),
    );
  }

  Widget _legend(
    Color color,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 6,
          ),
        ),
      ],
    );
  }

  Widget _skillRow(
    _SkillResultItem item,
  ) {
    final color = _statusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Icon(
              item.icon,
              size: 13,
              color: color,
            ),
          ),
          SizedBox(
            width: 91,
            child: Text(
              item.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 7.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 7,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: item.requiredValue,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(
                          99,
                        ),
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: item.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(
                          99,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(
              vertical: 3,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              _statusText(item.status),
              style: TextStyle(
                color: color,
                fontSize: 6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSIGHT
  // ============================================================

  Widget _insightCard(
    BuildContext context,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventLearningPathScreen(
                eventTitle: eventTitle,
                missingSkills: missingSkills,
                currentReadiness: readiness,
              ),
            ),
          );
        },
        hoverColor: AppColors.hover,
        splashColor: AppColors.pressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.lightTint,
                Color(0xFFF6E5DF),
              ],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.tint,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.antiqueBrass.withOpacity(.11),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.antiqueBrass,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'re $readiness% ready!',
                      style: const TextStyle(
                        color: AppColors.hue,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Focus on the missing skills to maximize your preparation for this event.',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 7.7,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.hue,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(
    _ResultStatus status,
  ) {
    switch (status) {
      case _ResultStatus.strong:
        return AppColors.lichen;

      case _ResultStatus.partial:
        return AppColors.antiqueBrass;

      case _ResultStatus.missing:
        return AppColors.dustyCoral;
    }
  }

  String _statusText(
    _ResultStatus status,
  ) {
    switch (status) {
      case _ResultStatus.strong:
        return 'Strong';

      case _ResultStatus.partial:
        return 'Partial';

      case _ResultStatus.missing:
        return 'Missing';
    }
  }
}

// ================================================================
// CUSTOM READINESS RING
// ================================================================

class _ReadinessRingPainter extends CustomPainter {
  final double value;

  _ReadinessRingPainter({
    required this.value,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = math.min(size.width, size.height) / 2 - 8;

    const stroke = 11.0;

    final background = Paint()
      ..color = AppColors.tint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      background,
    );

    final progress = Paint()
      ..color = AppColors.hue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      progress,
    );

    final green = Paint()
      ..color = AppColors.lichen
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * .32,
      false,
      green,
    );
  }

  @override
  bool shouldRepaint(
    covariant _ReadinessRingPainter oldDelegate,
  ) {
    return oldDelegate.value != value;
  }
}

// ================================================================
// MODELS
// ================================================================

enum _ResultStatus {
  strong,
  partial,
  missing,
}

class _SkillResultItem {
  final String title;
  final IconData icon;
  final double value;
  final double requiredValue;
  final _ResultStatus status;

  const _SkillResultItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.requiredValue,
    required this.status,
  });
}

class _SummaryItem {
  final Color color;
  final int value;
  final String label;

  const _SummaryItem({
    required this.color,
    required this.value,
    required this.label,
  });
}
