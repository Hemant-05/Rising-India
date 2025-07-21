import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/address_model.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String number;
  final String role;
  final GeoPoint? currentLocation;
  final String? address;
  final List<AddressModel> addressList;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.number,
    required this.role,
    this.currentLocation,
    this.address,
    required this.addressList,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': number,
      'role': role,
      'currentLocation': currentLocation,
      'address': address,
      'addressList' : addressList,
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
      addressList: _convertAddressList(map['addressList']),
    );
  }
  // Helper method to safely convert address list
  static List<AddressModel> _convertAddressList(dynamic addressData) {
    if (addressData == null) return [];

    try {
      final List<dynamic> dynamicList = addressData as List<dynamic>;
      return dynamicList
          .map((item) => AddressModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error converting address list: $e');
      return [];
    }
  }
}
