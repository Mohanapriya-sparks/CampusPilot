import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'skill_sprint_result_screen.dart';

class SkillSprintChallengeScreen extends StatefulWidget {
  final String eventTitle;
  final int previousReadiness;

  const SkillSprintChallengeScreen({
    super.key,
    this.eventTitle = 'Stanford TreeHacks 2025',
    this.previousReadiness = 68,
  });

  @override
  State<SkillSprintChallengeScreen> createState() =>
      _SkillSprintChallengeScreenState();
}

class _SkillSprintChallengeScreenState
    extends State<SkillSprintChallengeScreen> {
  int currentIndex = 0;

  int points = 0;
  int streak = 0;
  int remainingSeconds = 180;

  bool showWhy = false;

  Timer? timer;

  final Map<int, int> selectedAnswers = {};
  final Map<int, bool> checkedAnswers = {};

  final List<SprintQuestion> questions = const [
    SprintQuestion(
      skill: 'Flutter Basics',
      difficulty: 'Easy',
      question:
          'Which widget is used when the UI needs to change after user interaction?',
      code: '''
class CounterPage extends _____ {
  int count = 0;

  // UI changes when count changes
}''',
      options: [
        'StatefulWidget',
        'StatelessWidget',
        'Container',
        'MaterialApp',
      ],
      correctIndex: 0,
      explanation:
          'StatefulWidget is used when data can change and the UI needs to rebuild.',
    ),
    SprintQuestion(
      skill: 'Flutter UI',
      difficulty: 'Medium',
      question:
          'Which Flutter widget would you use to create a scrollable list of items with better performance for large datasets?',
      code: '''
return Scaffold(
  body: [
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(items[index]),
      );
    },
  ],
);''',
      options: [
        'ListView.builder()',
        'ListView()',
        'SingleChildScrollView()',
        'Column()',
      ],
      correctIndex: 0,
      explanation:
          'ListView.builder creates list items only when they are needed, making it more efficient for large or dynamic lists.',
    ),
    SprintQuestion(
      skill: 'GitHub',
      difficulty: 'Medium',
      question:
          'You want to contribute a feature without changing the main branch directly. What should you do first?',
      code: '''
git clone repository

# Work safely without
# editing main directly
''',
      options: [
        'Create a new branch',
        'Delete the main branch',
        'Open a pull request immediately',
        'Create a new repository',
      ],
      correctIndex: 0,
      explanation:
          'A separate branch lets you develop and test your change safely before opening a pull request.',
    ),
    SprintQuestion(
      skill: 'Problem Solving',
      difficulty: 'Medium',
      question:
          'Your event API works on some requests but crashes when data is missing. What is the best first improvement?',
      code: '''
final response = await fetchEvent();

Text(response['title']);
''',
      options: [
        'Validate and handle missing values',
        'Increase the font size',
        'Remove the API request',
        'Restart the application',
      ],
      correctIndex: 0,
      explanation:
          'Validating incoming data and handling missing values prevents unexpected runtime failures.',
    ),
    SprintQuestion(
      skill: 'Teamwork',
      difficulty: 'Medium',
      question:
          'During a hackathon, two teammates are building the same feature. What is the best response?',
      code: '''
8 hours remaining

Team member A → Payment UI
Team member B → Payment UI

Critical API work → Not assigned
''',
      options: [
        'Reassign tasks and agree on clear ownership',
        'Let both continue doing the same work',
        'Stop communicating until the deadline',
        'Delete one teammate\'s work',
      ],
      correctIndex: 0,
      explanation:
          'Clear ownership prevents duplicated effort and allows the team to focus on the most important remaining work.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        if (remainingSeconds > 0) {
          setState(() {
            remainingSeconds--;
          });
        } else {
          timer?.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  SprintQuestion get currentQuestion => questions[currentIndex];

  bool get answered => selectedAnswers.containsKey(currentIndex);

  bool get checked => checkedAnswers[currentIndex] ?? false;

  double get progress => (currentIndex + 1) / questions.length;

  String get timerText {
    final minutes = remainingSeconds ~/ 60;

    final seconds = remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ===========================================================
  // ANSWER
  // ===========================================================

  void selectAnswer(int index) {
    if (checked) return;

    setState(() {
      selectedAnswers[currentIndex] = index;
    });
  }

  void checkCurrentAnswer() {
    if (!answered || checked) {
      return;
    }

    final correct =
        selectedAnswers[currentIndex] == currentQuestion.correctIndex;

    setState(() {
      checkedAnswers[currentIndex] = correct;

      if (correct) {
        points += 75;
        streak++;
      } else {
        streak = 0;
      }
    });
  }

  // ===========================================================
  // NEXT
  // ===========================================================

  void nextQuestion() {
    if (!answered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose an answer first.',
          ),
        ),
      );
      return;
    }

    if (!checked) {
      checkCurrentAnswer();
      return;
    }

    if (currentIndex == questions.length - 1) {
      finishSprint();
      return;
    }

    setState(() {
      currentIndex++;
      showWhy = false;
    });
  }

  void previousQuestion() {
    if (currentIndex == 0) {
      Navigator.maybePop(context);
      return;
    }

    setState(() {
      currentIndex--;
      showWhy = false;
    });
  }

  void finishSprint() {
    timer?.cancel();

    final skillResults = <String, bool>{};

    for (var i = 0; i < questions.length; i++) {
      final answer = selectedAnswers[i];

      skillResults[questions[i].skill] = answer == questions[i].correctIndex;
    }

    final correctAnswers = skillResults.values.where((value) => value).length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SkillSprintResultScreen(
          eventTitle: widget.eventTitle,
          correctAnswers: correctAnswers,
          totalChallenges: questions.length,
          score: points,
          skillResults: skillResults,
          previousReadiness: widget.previousReadiness,
        ),
      ),
    );
  }

  // ===========================================================
  // SCREEN
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  100,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 620,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stats(),
                        const SizedBox(
                          height: 13,
                        ),
                        _questionCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ===========================================================
  // HEADER
  // ===========================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        8,
        7,
        12,
        8,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 43,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.maybePop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.text,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Skill Sprint',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      '${currentIndex + 1} / ${questions.length}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                99,
              ),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.tint,
                color: AppColors.hue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // STATS
  // ===========================================================

  Widget _stats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.dustyRose,
            value: timerText,
            label: 'time left',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            icon: Icons.local_fire_department_outlined,
            iconColor: AppColors.antiqueBrass,
            value: '$streak',
            label: 'streak',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.antiqueBrass,
            value: '$points',
            label: 'points',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // QUESTION CARD
  // ===========================================================

  Widget _questionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionBadges(),
          const SizedBox(height: 11),
          Text(
            currentQuestion.question,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              height: 1.25,
              fontWeight: FontWeight.w900,
              letterSpacing: -.25,
            ),
          ),
          const SizedBox(height: 12),
          _codeBlock(),
          const SizedBox(height: 12),
          ...List.generate(
            currentQuestion.options.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 7,
                ),
                child: _answerOption(
                  index,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          _whyPanel(),
        ],
      ),
    );
  }

  // ===========================================================
  // BADGES
  // ===========================================================

  Widget _questionBadges() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightTint,
            borderRadius: BorderRadius.circular(
              99,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.code_rounded,
                size: 11,
                color: AppColors.hue,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                currentQuestion.skill,
                style: const TextStyle(
                  color: AppColors.hue,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.antiqueBrass.withOpacity(.10),
            borderRadius: BorderRadius.circular(
              99,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_outline_rounded,
                size: 11,
                color: AppColors.antiqueBrass,
              ),
              const SizedBox(
                width: 3,
              ),
              Text(
                currentQuestion.difficulty,
                style: const TextStyle(
                  color: AppColors.antiqueBrass,
                  fontSize: 8.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // CODE
  // ===========================================================

  Widget _codeBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkShade,
        borderRadius: BorderRadius.circular(
          11,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          currentQuestion.code,
          style: const TextStyle(
            color: Color(0xFFF8EBE8),
            fontSize: 9,
            height: 1.45,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // ANSWERS
  // ===========================================================

  Widget _answerOption(int index) {
    final selected = selectedAnswers[currentIndex] == index;

    final correctOption = index == currentQuestion.correctIndex;

    Color background = AppColors.background;

    Color border = AppColors.border;

    Color circle = AppColors.secondary;

    if (selected && !checked) {
      background = AppColors.lightTint;
      border = AppColors.hue;
      circle = AppColors.hue;
    }

    if (checked) {
      if (correctOption) {
        background = AppColors.lichen.withOpacity(.09);

        border = AppColors.lichen;

        circle = AppColors.lichen;
      } else if (selected) {
        background = AppColors.dustyCoral.withOpacity(.07);

        border = AppColors.dustyCoral;

        circle = AppColors.dustyCoral;
      }
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(
        11,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: checked
            ? null
            : () {
                selectAnswer(
                  index,
                );
              },
        hoverColor: AppColors.hoverSurface,
        splashColor: AppColors.pressedSurface,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              11,
            ),
            border: Border.all(
              color: border,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: circle,
                    width: 1.3,
                  ),
                  color:
                      selected && !checked ? AppColors.hue : Colors.transparent,
                ),
                child: Center(
                  child: checked && correctOption
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.lichen,
                          size: 13,
                        )
                      : checked && selected && !correctOption
                          ? const Icon(
                              Icons.close_rounded,
                              color: AppColors.dustyCoral,
                              size: 12,
                            )
                          : selected
                              ? const Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.white,
                                )
                              : null,
                ),
              ),
              const SizedBox(
                width: 9,
              ),
              Text(
                String.fromCharCode(
                  65 + index,
                ),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  currentQuestion.options[index],
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 9.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (checked && correctOption)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.lichen,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // WHY
  // ===========================================================

  Widget _whyPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.focusSurface,
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                10,
              ),
              onTap: () {
                setState(() {
                  showWhy = !showWhy;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 15,
                      color: AppColors.antiqueBrass,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const Expanded(
                      child: Text(
                        'Why?',
                        style: TextStyle(
                          color: AppColors.antiqueBrass,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      showWhy
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.antiqueBrass,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showWhy)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                0,
                10,
                10,
              ),
              child: Text(
                currentQuestion.explanation,
                style: const TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 9,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================
  // BOTTOM NAVIGATION
  // ===========================================================

  Widget _bottomBar() {
    final last = currentIndex == questions.length - 1;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14,
          8,
          14,
          10,
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
            TextButton.icon(
              onPressed: previousQuestion,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 15,
              ),
              label: const Text(
                'Previous',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: nextQuestion,
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                    const Size(
                      0,
                      48,
                    ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      !checked
                          ? 'Check Answer'
                          : last
                              ? 'See Results'
                              : 'Next Question',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Icon(
                      last && checked
                          ? Icons.analytics_outlined
                          : Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
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
}

// ===============================================================
// QUESTION MODEL
// ===============================================================

class SprintQuestion {
  final String skill;
  final String difficulty;
  final String question;
  final String code;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const SprintQuestion({
    required this.skill,
    required this.difficulty,
    required this.question,
    required this.code,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
