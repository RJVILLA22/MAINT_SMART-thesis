class AppUser {
  String? id;
  String last_name;
  String first_name;
  String? id_number;
  String email;
  String? department;
  String? course;
  String type;

  AppUser({
    this.id,
    required this.last_name,
    required this.first_name,
    this.department,
    this.course,
    this.id_number,
    required this.type,
    required this.email,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      last_name: json['last_name'],
      first_name: json['first_name'],
      id_number: json['id_number'],
      department: json['department'],
      course: json['course'],
      type: json['type'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_name': last_name,
      'first_name': first_name,
      'id_number': id_number,
      'department': department,
      'course': course,
      'type': type,
      'email': email,
    };
  }
}
