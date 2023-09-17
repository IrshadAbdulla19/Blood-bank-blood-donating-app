import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id, username, email, phone, blood;
  UserModel({this.id, this.email, this.username, this.phone, this.blood});
  factory UserModel.fromMap(DocumentSnapshot map) {
    return UserModel(
        email: map['email'],
        username: map['username'],
        phone: map["phone"],
        blood: map["blood"],
        id: map.id);
  }

  Map<String, dynamic> tomap() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'blood': blood
    };
  }
}
