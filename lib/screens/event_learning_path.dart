import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EventLearningPath extends StatefulWidget {
  const EventLearningPath({
    super.key,
  });

  @override
  State<EventLearningPath> createState() => _EventLearningPathState();
}

class _EventLearningPathState extends State<EventLearningPath> {
  final completed = <int>{};

  final steps = const [
    LearningStep(
      title: 'Learn Machine Learning Basics',
      description:
          'Complete a beginner-friendly track covering models, training and evaluation.',
      duration: '4 weeks',
      source: 'Course',
      icon: Icons.psychology_outlined,
    ),
    LearningStep(
      title: 'Master UI/UX Design',
      description:
          'Learn design principles and build a practical interface project.',
      duration: '3 weeks',
      source: 'Practice',
      icon: Icons.palette_outlined,
    ),
    LearningStep(
      title: 'Practice System Design',
      description:
          'Study scalable application architecture and simple case studies.',
      duration: '4 weeks',
      source: 'Learning',
      icon: Icons.account_tree_outlined,
    ),
    LearningStep(
      title: 'Build a Mini Project',
      description:
          'Apply your new skills by building a project similar to the hackathon domain.',
      duration: '2 weeks',
      source: 'Project',
      icon: Icons.build_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personalized Learning Path',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Based on your missing skills, here is a step-by-step preparation path.',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              ...steps.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final step = entry.value;

                  return _LearningStepCard(
                    number: index + 1,
                    step: step,
                    completed: completed.contains(
                      index,
                    ),
                    onComplete: () {
                      setState(() {
                        completed.contains(
                          index,
                        )
                            ? completed.remove(
                                index,
                              )
                            : completed.add(
                                index,
                              );
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.darkShade,
                      AppColors.shade,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expected readiness',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'After completing this path',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '72% → 89%',
                      style: TextStyle(
                        color: AppColors.tint,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
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
}

class _LearningStepCard extends StatelessWidget {
  final int number;
  final LearningStep step;
  final bool completed;
  final VoidCallback onComplete;

  const _LearningStepCard({
    required this.number,
    required this.step,
    required this.completed,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Material(
                color: completed ? AppColors.cocoa : AppColors.tint,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onComplete,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: Center(
                      child: completed
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 17,
                            )
                          : Text(
                              '$number',
                              style: const TextStyle(
                                color: AppColors.hue,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              if (number < 4)
                Container(
                  width: 2,
                  height: 74,
                  color: AppColors.tint,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                15,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onComplete,
                child: Container(
                  padding: const EdgeInsets.all(
                    14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.lightTint,
                          borderRadius: BorderRadius.circular(
                            11,
                          ),
                        ),
                        child: Icon(
                          step.icon,
                          color: AppColors.hue,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                color: completed
                                    ? AppColors.secondary
                                    : AppColors.text,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              step.description,
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 10.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                _pill(
                                  step.source,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 12,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  step.duration,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightTint,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.hue,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LearningStep {
  final String title;
  final String description;
  final String duration;
  final String source;
  final IconData icon;

  const LearningStep({
    required this.title,
    required this.description,
    required this.duration,
    required this.source,
    required this.icon,
  });
}
