import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserDirectoryApi {
  final _userRef = FirebaseFirestore.instance.collection('users');

  /// 🔁 Stream all student profiles in real time
  Stream<List<AppUser>> streamAllStudents() {
    return _userRef.where('type', isEqualTo: 'student').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  /// 🔁 Stream all instructor profiles in real time
  Stream<List<AppUser>> streamAllInstructors() {
    return _userRef.where('type', isEqualTo: 'instructor').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  /// 🧩 Optional: stream both at once grouped by type
  Stream<Map<String, List<AppUser>>> streamAllUsersGrouped() {
    return _userRef.snapshots().map((snapshot) {
      final students = <AppUser>[];
      final instructors = <AppUser>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final user = AppUser.fromJson({...data, 'id': doc.id});

        if (user.type.toLowerCase() == 'student') {
          students.add(user);
        } else if (user.type.toLowerCase() == 'instructor') {
          instructors.add(user);
        }
      }

      return {'students': students, 'instructors': instructors};
    });
  }
}
