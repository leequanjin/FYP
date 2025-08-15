import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static Future<bool> isPremiumUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return false;

    final data = doc.data() ?? {};
    final expiry = (data['premiumExpiry'] as Timestamp?)?.toDate();
    if (expiry == null) return false;

    return DateTime.now().isBefore(expiry);
  }

  static Future<DateTime?> getPremiumExpiry() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return (doc.data()?['premiumExpiry'] as Timestamp?)?.toDate();
  }

  static Future<void> upgradeToPremium() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("Not signed in");

    final expiry = DateTime.now().add(const Duration(days: 30));

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'isPremium': true,
      'premiumExpiry': expiry,
    }, SetOptions(merge: true));
  }
}
