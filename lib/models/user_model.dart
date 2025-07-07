import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String number;
  final String role;
  final GeoPoint? currentLocation;
  final String? address;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.number,
    required this.role,
    this.currentLocation,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': number,
      'role': role,
      'currentLocation': currentLocation,
      'address': address,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'],
      email: map['email'],
      number: map['number'],
      role: map['role'],
      currentLocation: map['currentLocation'],
      address: map['address'],
    );
  }
}
