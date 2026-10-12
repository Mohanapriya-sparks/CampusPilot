import 'package:flutter/foundation.dart';

import '../models/opportunity.dart';
import '../models/student_profile.dart';
import '../storage/profile_storage.dart';

class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  String? userId;
  StudentProfile? profile;
  final Set<String> savedEventIds = <String>{};
  bool initialized = false;

  bool get profileCompleted =>
      profile != null &&
      profile!.fullName.trim().isNotEmpty &&
      profile!.college.trim().isNotEmpty;

  Future<void> loadForUser(String uid) async {
    if (initialized && userId == uid) return;

    userId = uid;

    profile = await ProfileStorage.loadProfile(uid);

    savedEventIds
      ..clear()
      ..addAll(await ProfileStorage.loadSavedEvents(uid));

    initialized = true;
    notifyListeners();
  }

  Future<void> saveProfile(StudentProfile value) async {
    // Update the UI immediately.
    profile = value;
    notifyListeners();

    final uid = userId;
    if (uid == null) return;

    // ProfileStorage performs a fast local save first and cloud sync second.
    await ProfileStorage.saveProfile(uid, value);
  }

  Future<void> toggleSaved(Opportunity event) async {
    if (savedEventIds.contains(event.id)) {
      savedEventIds.remove(event.id);
    } else {
      savedEventIds.add(event.id);
    }

    // Update the UI immediately.
    notifyListeners();

    final uid = userId;
    if (uid == null) return;

    await ProfileStorage.saveEvents(uid, savedEventIds);
  }

  bool isSaved(Opportunity event) => savedEventIds.contains(event.id);

  Future<void> clearSession() async {
    userId = null;
    profile = null;
    savedEventIds.clear();
    initialized = false;
    notifyListeners();
  }
}
