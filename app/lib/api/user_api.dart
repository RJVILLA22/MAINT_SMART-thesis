import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/models/user.dart' as AppUser;
import 'package:firebase_auth/firebase_auth.dart' as AppUser;

class UserApi {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection("users");

  Future<void> addUser(AppUser.AppUser user) async {
    try {
      // Store the user with uid as the document ID
      await usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception("Failed to add user: $e");
    }
  }

  Future<AppUser.AppUser?> getUserById(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return AppUser.AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch user: $e");
    }
  }

  Future<AppUser.AppUser?> getUserProfile(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (doc.exists) {
        print("✅ Fetched user profile: ${doc.data()}");
        return AppUser.AppUser.fromJson({...doc.data()!, 'id': doc.id});
      } else {
        print("⚠️ No user found for UID: $uid");
      }
      return null;
    } catch (e, st) {
      print("❌ Error fetching profile for $uid: $e\n$st");
      return null;
    }
  }
}
