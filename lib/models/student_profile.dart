class StudentProfile {
  String fullName;
  String city;
  String state;
  String college;
  String degree;
  String department;
  String year;
  String semester;
  String graduationYear;
  List<String> skills;
  List<String> interests;
  List<String> preferredEventTypes;
  String preferredLocation;
  String preferredMode;
  String feePreference;
  String github;
  String linkedin;
  String resumeFileName;
  int maxLeave;
  int usedLeave;
  String timetableFileName;
  String examFileName;

  StudentProfile({
    this.fullName = '',
    this.city = '',
    this.state = '',
    this.college = '',
    this.degree = '',
    this.department = '',
    this.year = '',
    this.semester = '',
    this.graduationYear = '',
    List<String>? skills,
    List<String>? interests,
    List<String>? preferredEventTypes,
    this.preferredLocation = '',
    this.preferredMode = 'Any',
    this.feePreference = 'Any',
    this.github = '',
    this.linkedin = '',
    this.resumeFileName = '',
    this.maxLeave = 6,
    this.usedLeave = 0,
    this.timetableFileName = '',
    this.examFileName = '',
  })  : skills = skills ?? <String>[],
        interests = interests ?? <String>[],
        preferredEventTypes = preferredEventTypes ?? <String>[];

  int get remainingLeave => (maxLeave - usedLeave).clamp(0, 999).toInt();

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'city': city,
        'state': state,
        'college': college,
        'degree': degree,
        'department': department,
        'year': year,
        'semester': semester,
        'graduationYear': graduationYear,
        'skills': skills,
        'interests': interests,
        'preferredEventTypes': preferredEventTypes,
        'preferredLocation': preferredLocation,
        'preferredMode': preferredMode,
        'feePreference': feePreference,
        'github': github,
        'linkedin': linkedin,
        'resumeFileName': resumeFileName,
        'maxLeave': maxLeave,
        'usedLeave': usedLeave,
        'timetableFileName': timetableFileName,
        'examFileName': examFileName,
      };

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    List<String> listOf(dynamic value) => value is List
        ? value.map((item) => item.toString()).toList()
        : <String>[];

    return StudentProfile(
      fullName: json['fullName']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      college: json['college']?.toString() ?? '',
      degree: json['degree']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      graduationYear: json['graduationYear']?.toString() ?? '',
      skills: listOf(json['skills']),
      interests: listOf(json['interests']),
      preferredEventTypes: listOf(json['preferredEventTypes']),
      preferredLocation: json['preferredLocation']?.toString() ?? '',
      preferredMode: json['preferredMode']?.toString() ?? 'Any',
      feePreference: json['feePreference']?.toString() ?? 'Any',
      github: json['github']?.toString() ?? '',
      linkedin: json['linkedin']?.toString() ?? '',
      resumeFileName: json['resumeFileName']?.toString() ?? '',
      maxLeave: int.tryParse(json['maxLeave']?.toString() ?? '') ?? 6,
      usedLeave: int.tryParse(json['usedLeave']?.toString() ?? '') ?? 0,
      timetableFileName: json['timetableFileName']?.toString() ?? '',
      examFileName: json['examFileName']?.toString() ?? '',
    );
  }
}
