import 'dart:async';

import 'package:flutter/material.dart';
import '../api/user_directory_api.dart';
import '../models/user.dart';

class UserDirectoryProvider extends ChangeNotifier {
  final _api = UserDirectoryApi();

  List<AppUser> _students = [];
  List<AppUser> get students => _students;

  List<AppUser> _instructors = [];
  List<AppUser> get instructors => _instructors;

  StreamSubscription? _studentSub;
  StreamSubscription? _instructorSub;

  void startListening() {
    _studentSub = _api.streamAllStudents().listen((data) {
      _students = data;
      notifyListeners();
    });

    _instructorSub = _api.streamAllInstructors().listen((data) {
      _instructors = data;
      notifyListeners();
    });
  }

  void stopListening() {
    _studentSub?.cancel();
    _instructorSub?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
