import 'package:flutter/material.dart';

class PreparationStep {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;

  const PreparationStep({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
  });
}

const preparationSteps = <PreparationStep>[
  PreparationStep(
    title: 'Contribute to an API-based open-source project',
    subtitle:
        'Choose a beginner-friendly issue requiring a real API integration.',
    duration: '3–5 days',
    icon: Icons.hub_outlined,
  ),
  PreparationStep(
    title: 'Complete one collaborative issue',
    subtitle: 'Use a branch, review comments and a pull request.',
    duration: '5–7 days',
    icon: Icons.account_tree_outlined,
  ),
  PreparationStep(
    title: 'Improve ScamShield AI prototype',
    subtitle: 'Add one real integration and validate it with users.',
    duration: '5–7 days',
    icon: Icons.auto_awesome_outlined,
  ),
  PreparationStep(
    title: 'Re-run CampusPilot analysis',
    subtitle: 'Use the new evidence to measure readiness again.',
    duration: '1 day',
    icon: Icons.analytics_outlined,
  ),
];
