import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_profile.dart';

class ProfileStorage {
  ProfileStorage._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _profileKey(String uid) => 'campuspilot_profile_$uid';
  static String _savedKey(String uid) => 'campuspilot_saved_events_$uid';

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  // Local cache is checked first so login/profile loading stays fast.
  static Future<StudentProfile?> loadProfile(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final localRaw = prefs.getString(_profileKey(uid));

    if (localRaw != null && localRaw.isNotEmpty) {
      try {
        final localProfile = StudentProfile.fromJson(
          jsonDecode(localRaw) as Map<String, dynamic>,
        );

        // Refresh the local cache from Firestore without blocking the UI.
        unawaited(_refreshProfileFromCloud(uid));

        return localProfile;
      } catch (e) {
        debugPrint('Local profile read error: $e');
      }
    }

    // No local copy (for example, a new device/browser): load from Firestore.
    try {
      final snapshot = await _userDoc(uid).get();

      if (!snapshot.exists) return null;

      final data = snapshot.data();
      final profileData = data?['profile'];

      if (profileData is! Map) return null;

      final profile = StudentProfile.fromJson(
        Map<String, dynamic>.from(profileData),
      );

      await prefs.setString(
        _profileKey(uid),
        jsonEncode(profile.toJson()),
      );

      return profile;
    } catch (e) {
      debugPrint('Cloud profile load error: $e');
      return null;
    }
  }

  // Save locally first. This is what makes Save & Continue feel instant.
  // Firestore sync then runs in the background.
  static Future<void> saveProfile(
    String uid,
    StudentProfile profile,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _profileKey(uid),
      jsonEncode(profile.toJson()),
    );

    unawaited(
      _userDoc(uid).set(
        {
          'profile': profile.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).catchError((Object error) {
        debugPrint('Cloud profile sync error: $error');
      }),
    );
  }

  static Future<Set<String>> loadSavedEvents(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_savedKey(uid));

    if (local != null) {
      unawaited(_refreshSavedEventsFromCloud(uid));
      return local.toSet();
    }

    try {
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      final cloudIds = data?['savedEventIds'];

      if (cloudIds is! List) return <String>{};

      final ids = cloudIds.map((item) => item.toString()).toSet();

      await prefs.setStringList(_savedKey(uid), ids.toList());

      return ids;
    } catch (e) {
      debugPrint('Cloud saved-events load error: $e');
      return <String>{};
    }
  }

  static Future<void> saveEvents(
    String uid,
    Set<String> ids,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _savedKey(uid),
      ids.toList(),
    );

    unawaited(
      _userDoc(uid).set(
        {
          'savedEventIds': ids.toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ).catchError((Object error) {
        debugPrint('Cloud saved-events sync error: $error');
      }),
    );
  }

  static Future<void> _refreshProfileFromCloud(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      final profileData = data?['profile'];

      if (profileData is! Map) return;

      final profile = StudentProfile.fromJson(
        Map<String, dynamic>.from(profileData),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _profileKey(uid),
        jsonEncode(profile.toJson()),
      );
    } catch (e) {
      debugPrint('Background profile refresh error: $e');
    }
  }

  static Future<void> _refreshSavedEventsFromCloud(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      final cloudIds = data?['savedEventIds'];

      if (cloudIds is! List) return;

      final ids = cloudIds.map((item) => item.toString()).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_savedKey(uid), ids);
    } catch (e) {
      debugPrint('Background saved-events refresh error: $e');
    }
  }
}
