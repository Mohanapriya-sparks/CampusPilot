import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'student_profile.dart';

enum OpportunityKind { event, program, project }

class Opportunity {
  final String id;
  final String title;
  final String category;
  final String organizer;
  final String location;
  final String mode;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String fee;
  final String teamSize;
  final String prize;
  final String eligibility;
  final String description;
  final List<String> tags;
  final String sourceName;
  final String sourceUrl;
  final String officialUrl;
  final String registrationUrl;
  final String contactDetails;
  final String schedule;
  final int estimatedClassesAffected;
  final int estimatedLabsAffected;
  final int estimatedLeaveDays;
  final bool examConflict;

  const Opportunity({
    required this.id,
    required this.title,
    required this.category,
    required this.organizer,
    required this.location,
    required this.mode,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.fee,
    required this.teamSize,
    required this.prize,
    required this.eligibility,
    required this.description,
    required this.tags,
    required this.sourceName,
    required this.sourceUrl,
    this.officialUrl = '',
    this.registrationUrl = '',
    this.contactDetails = '',
    this.schedule = '',
    required this.estimatedClassesAffected,
    required this.estimatedLabsAffected,
    required this.estimatedLeaveDays,
    required this.examConflict,
  });

  OpportunityKind get kind => OpportunityKind.event;
  String get type => category;
  int get fit => 92;
  int get readiness => 68;
  int get competitiveReadiness => 73;

  String get date =>
      '${startDate.day} ${_monthName(startDate.month)}${durationDays > 1 ? '–${endDate.day} ${_monthName(endDate.month)}' : ''} ${startDate.year}';

  String get registrationText =>
      'Registration by ${registrationDeadline.day} ${_monthName(registrationDeadline.month)}';

  String get reason =>
      'Matches your skills, interests and academic location preference.';

  IconData get icon => AppColors.categoryIcon(category);

  int get durationDays => endDate.difference(startDate).inDays + 1;

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  int matchScore(StudentProfile profile) {
    var score = 35;
    final userSignals = <String>{
      ...profile.skills.map((e) => e.toLowerCase()),
      ...profile.interests.map((e) => e.toLowerCase()),
    };
    final tagMatches =
        tags.where((tag) => userSignals.contains(tag.toLowerCase())).length;
    score += (tagMatches * 12).clamp(0, 36).toInt();

    if (profile.preferredEventTypes
        .any((type) => type.toLowerCase() == category.toLowerCase())) {
      score += 10;
    }
    final preferredLocation = profile.preferredLocation.trim().toLowerCase();
    if (preferredLocation.isNotEmpty &&
        location.toLowerCase().contains(preferredLocation)) {
      score += 9;
    } else if (profile.city.isNotEmpty &&
        location.toLowerCase().contains(profile.city.toLowerCase())) {
      score += 7;
    }
    if (profile.preferredMode == 'Any' || profile.preferredMode == mode) {
      score += 5;
    }
    if (profile.feePreference == 'Any' ||
        (profile.feePreference == 'Free only' && fee.toLowerCase() == 'free')) {
      score += 5;
    }
    if (!examConflict) {
      score += 4;
    }
    return score.clamp(45, 99).toInt();
  }

  List<String> whyRecommended(StudentProfile profile) {
    final reasons = <String>[];
    final userSignals = <String>{
      ...profile.skills.map((e) => e.toLowerCase()),
      ...profile.interests.map((e) => e.toLowerCase()),
    };
    final matched = tags
        .where((tag) => userSignals.contains(tag.toLowerCase()))
        .take(2)
        .toList();
    if (matched.isNotEmpty) {
      reasons.add('Matches ${matched.join(' + ')} in your profile');
    }
    if (profile.preferredEventTypes
        .any((e) => e.toLowerCase() == category.toLowerCase())) {
      reasons.add('Matches your preferred event type');
    }
    if (profile.city.isNotEmpty &&
        location.toLowerCase().contains(profile.city.toLowerCase())) {
      reasons.add('Matches your city preference');
    }
    if (!examConflict && estimatedLeaveDays <= 1) {
      reasons.add('Low academic disruption');
    }
    if (reasons.isEmpty) {
      reasons.add('Useful growth opportunity for your profile');
    }
    return reasons.take(3).toList();
  }
}

final sampleOpportunities = <Opportunity>[
  Opportunity(
    id: 'eco-iot-hackstorm',
    title: 'CodeGyaan\'26',
    category: 'Hackathon',
    organizer: 'M.O.P. Vaishnav College',
    location: 'Chennai',
    mode: 'Online',
    startDate: DateTime(2026, 9, 24),
    endDate: DateTime(2026, 9, 26),
    registrationDeadline: DateTime(2026, 9, 24),
    fee: 'Free',
    teamSize: '2-4',
    prize: 'Prizes announced by organizer',
    eligibility: 'College students',
    description:
        'A student hackathon focused on AI, Web Dev, innovation and building practical prototypes.',
    tags: ['AI', 'Web Dev', 'Innovation'],
    sourceName: 'Knowafest',
    sourceUrl: 'https://knowafest.com',
    officialUrl: 'https://mopvaishnav.ac.in',
    registrationUrl: 'https://mopvaishnav.ac.in/register',
    estimatedClassesAffected: 3,
    estimatedLabsAffected: 0,
    estimatedLeaveDays: 1,
    examConflict: false,
  ),
  Opportunity(
    id: 'gssoc-2027',
    title: 'GSSoC 2027',
    category: 'Open Source Program',
    organizer: 'GirlScript Foundation',
    location: 'Remote',
    mode: 'Online',
    startDate: DateTime(2027, 2, 2),
    endDate: DateTime(2027, 5, 31),
    registrationDeadline: DateTime(2027, 1, 18),
    fee: 'Free',
    teamSize: 'Individual',
    prize: 'Certificate & Swag',
    eligibility: 'Open to all students',
    description:
        'A beginner-friendly open source program providing contributors, mentors and projects across multiple domains.',
    tags: ['Open Source', 'Beginner', 'Community'],
    sourceName: 'GirlScript',
    sourceUrl: 'https://gssoc.girlscript.tech',
    officialUrl: 'https://gssoc.girlscript.tech',
    registrationUrl: 'https://gssoc.girlscript.tech/register',
    estimatedClassesAffected: 0,
    estimatedLabsAffected: 0,
    estimatedLeaveDays: 0,
    examConflict: false,
  ),
  Opportunity(
    id: 'flutter-south',
    title: 'Flutter South India',
    category: 'Workshop',
    organizer: 'Namma Flutter',
    location: 'Chennai',
    mode: 'Offline',
    startDate: DateTime(2026, 10, 19),
    endDate: DateTime(2026, 10, 19),
    registrationDeadline: DateTime(2026, 10, 15),
    fee: '₹500',
    teamSize: 'Individual',
    prize: 'Networking & Certificate',
    eligibility: 'Flutter enthusiasts',
    description:
        'A technical workshop on Flutter, Dart, UI/UX and mobile development.',
    tags: ['Flutter', 'Mobile App', 'UI/UX'],
    sourceName: 'Namma Flutter',
    sourceUrl: 'https://flutter.dev',
    officialUrl: 'https://flutter.dev',
    registrationUrl: 'https://flutter.dev',
    estimatedClassesAffected: 2,
    estimatedLabsAffected: 1,
    estimatedLeaveDays: 1,
    examConflict: false,
  ),
];
