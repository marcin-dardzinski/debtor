import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User(this.uid, this.email, this.name, this.avatar);
  User.fromDocument(DocumentSnapshot document) {
    uid = document.documentID;
    name = document['name'].toString();
    email = document['email'].toString();
    avatar = document['avatar'].toString();
  }

  String uid;
  String name;
  String email;
  String avatar;

  @override
  String toString() {
    return name;
  }
}
