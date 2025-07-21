import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String title;
  final String address;
  final GeoPoint position;

  AddressModel({
    required this.title,
    required this.address,
    required this.position,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      title: map['title'],
      address: map['address'],
      position: map['position'],
    );
  }
  Map<String, dynamic> toMap(){
    return {
      'title' : title,
      'address' : address,
      'position' : position,
    };
  }
}
