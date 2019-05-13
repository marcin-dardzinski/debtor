import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User(this.uid, this.email, this.name, this.avatar, this.isCurrentUser);
  User.fromDocument(DocumentSnapshot document, String currentUserId) {
    uid = document.documentID;
    name = document['name'].toString();
    email = document['email'].toString();
    avatar = document['avatar'].toString();
    isCurrentUser = uid == currentUserId;
  }

  String uid;
  String name;
  String email;
  String avatar;
  bool isCurrentUser;

  @override
  String toString() {
    return name;
  }
}
