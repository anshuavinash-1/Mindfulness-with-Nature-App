import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodSettingsService {
  static DocumentReference<Map<String, dynamic>>? get _moodDocRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('mood');
  }

  static Future<Map<String, String?>> loadSettings() async {
    final ref = _moodDocRef;
    if (ref == null) return {'background': null, 'sound': null};

    final snapshot = await ref.get();
    if (!snapshot.exists) return {'background': null, 'sound': null};

    final data = snapshot.data()!;
    return {
      'background': data['background'] as String?,
      'sound': data['sound'] as String?,
    };
  }

  static Future<void> saveSettings({
    required String? background,
    required String? sound,
  }) async {
    final ref = _moodDocRef;
    if (ref == null) throw Exception('User not signed in.');

    await ref.set(
      {
        'background': background,
        'sound': sound,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
