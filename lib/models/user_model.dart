enum UserRole { USER, ADMIN, DELIVERY }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String number;
  final UserRole role;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.number,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      number: map['number'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.USER,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': number,
      'role': role.name, // If using Dart >=2.15
    };
  }
}
