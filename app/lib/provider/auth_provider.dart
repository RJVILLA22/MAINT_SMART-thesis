import 'package:app/api/user_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/firebase_auth_api.dart';
import '../api/user_api.dart';
import '../models/user.dart' as AppUser;

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late UserApi userApi;
  late Stream<User?> uStream; // FirebaseAuth.User stream
  User? userObj;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    userApi = UserApi();
    fetchAuthentication();
  }

  Stream<User?> get userStream => uStream;

  AppUser.AppUser? _currentUserProfile; // your Firestore profile
  AppUser.AppUser? get currentUserProfile => _currentUserProfile;

  void fetchAuthentication() {
    uStream = authService.getUser();
    notifyListeners();
  }

  /// Sign up: Firebase + Firestore profile
  Future<String> signUp(
    String email,
    String password,
    AppUser.AppUser appUser,
  ) async {
    String response = await authService.signUp(email, password);

    if (response.isNotEmpty) {
      appUser.id = response; // set UID from FirebaseAuth
      await userApi.addUser(appUser); // store profile in Firestore
    }

    notifyListeners();
    return response;
  }

  /// Sign in
  Future<String> signIn(String email, String password) async {
    String response = await authService.signIn(email, password);

    // Fetch Firestore profile immediately after login
    if (response.isNotEmpty) {
      await getProfile(response);
    }

    notifyListeners();
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await authService.signOut();
    _currentUserProfile = null;
    notifyListeners();
  }

  /// Get Firestore profile
  Future<AppUser.AppUser?> getProfile(String uid) async {
    try {
      final user = await userApi.getUserProfile(uid);
      _currentUserProfile = user;
      return user;
    } catch (e) {
      _currentUserProfile = null;
      print("Error fetching profile: $e");
      return null;
    }
  }
}
