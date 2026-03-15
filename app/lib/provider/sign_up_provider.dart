import 'package:flutter/material.dart';
import 'package:app/models/user.dart' as AppUser;

class SignUpProvider with ChangeNotifier {
  String? _userType; // student or faculty
  String? _firstName;
  String? _lastName;
  String? _idNumber;
  String? _department;
  String? _course;
  String? _email;

  String? get userType => _userType;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get idNumber => _idNumber;
  String? get department => _department;
  String? get course => _course;
  String? get email => _email;

  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  void setPersonalInfo({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    notifyListeners();
  }

  void setAcademicInfo({String? idNumber, String? department, String? course}) {
    _idNumber = idNumber;
    _department = department;
    _course = course;
    notifyListeners();
  }

  /// Convert all collected data into a User model
  AppUser.AppUser toUserModel() {
    return AppUser.AppUser(
      id: null, // Firebase UID will be set later
      first_name: _firstName ?? "",
      last_name: _lastName ?? "",
      id_number: _idNumber,
      department: _userType == "instructor" ? _department : null,
      course: _userType == "student" ? _course : null,
      type: _userType ?? "student",
      email: _email ?? "",
    );
  }

  /// Reset data after successful sign-up
  void clear() {
    _userType = null;
    _firstName = null;
    _lastName = null;
    _idNumber = null;
    _department = null;
    _course = null;
    _email = null;
    notifyListeners();
  }
}
